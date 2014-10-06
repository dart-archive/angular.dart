part of angular.core.dom_internal;

abstract class ComponentFactory {
  BoundComponentFactory bind(DirectiveRef ref, directives, Injector injector);
}

/**
 * A Component factory with has been bound to a specific component type.
 */
abstract class BoundComponentFactory {
  List<Key> get callArgs;
  Function call(dom.Element element);

  static async.Future<ViewFactory> _viewFactoryFuture(
        Component component, ViewFactoryCache viewCache, DirectiveMap directives,
        TypeToUriMapper uriMapper, ResourceUrlResolver resourceResolver, Type type) {
    if (component.template != null) {
      // TODO(chirayu): Replace this line with
      //     var baseUri = uriMapper.uriForType(type);
      // once we have removed _NullUriMapper.
      var baseUriString = resourceResolver.combineWithType(type, null);
      var baseUri = (baseUriString != null) ? Uri.parse(baseUriString) : null;
      return new async.Future.value(viewCache.fromHtml(component.template, directives, baseUri));
    }
    if (component.templateUrl != null) {
      var url = resourceResolver.combineWithType(type,  component.templateUrl);
      var baseUri = Uri.parse(url);
      return viewCache.fromUrl(url, directives, baseUri);
    }
    return null;
  }

  static void _setupOnShadowDomAttach(component, TemplateLoader templateLoader,
                                      Scope shadowScope) {
    if (component is ShadowRootAware) {
      templateLoader.template.then((shadowDom) {
        if (!shadowScope.isAttached) return;
        (component as ShadowRootAware).onShadowRoot(shadowDom);
      });
    }
  }
}

@Injectable()
class ShadowDomComponentFactory implements ComponentFactory {
  final ViewFactoryCache viewCache;
  final PlatformJsBasedShim platformShim;
  final Expando expando;
  final CompilerConfig config;
  final TypeToUriMapper uriMapper;
  final ResourceUrlResolver resourceResolver;

  ComponentCssLoader cssLoader;

  ShadowDomComponentFactory(this.viewCache, this.platformShim, this.expando, this.config,
      this.uriMapper, this.resourceResolver, Http http, TemplateCache templateCache,
      ComponentCssRewriter componentCssRewriter, dom.NodeTreeSanitizer treeSanitizer,
      CacheRegister cacheRegister) {
    final styleElementCache = new HashMap();
    cacheRegister.registerCache("ShadowDomComponentFactoryStyles", styleElementCache);

    cssLoader = new ComponentCssLoader(http, templateCache, platformShim,
        componentCssRewriter, treeSanitizer, styleElementCache, resourceResolver);
  }

  bind(DirectiveRef ref, directives, injector) =>
      new BoundShadowDomComponentFactory(this, ref, directives, injector);
}

class BoundShadowDomComponentFactory implements BoundComponentFactory {

  final ShadowDomComponentFactory _componentFactory;
  final DirectiveRef _ref;
  final Injector _injector;

  Component get _component => _ref.annotation as Component;

  String _tag;
  async.Future<List<dom.StyleElement>> _styleElementsFuture;
  List<dom.StyleElement> _styleElements;
  async.Future<ViewFactory> _shadowViewFactoryFuture;
  ViewFactory _shadowViewFactory;

  BoundShadowDomComponentFactory(this._componentFactory, this._ref,
      DirectiveMap directives, this._injector) {
    _tag = _ref.annotation.selector.toLowerCase();
    _styleElementsFuture = _componentFactory.cssLoader(_tag, _component.cssUrls, type: _ref.type)
        .then((styleElements) => _styleElements = styleElements);

    final viewFactoryCache = new ShimmingViewFactoryCache(_componentFactory.viewCache,
        _tag, _componentFactory.platformShim);

    _shadowViewFactoryFuture = BoundComponentFactory._viewFactoryFuture(_component,
        viewFactoryCache, directives, _componentFactory.uriMapper,
        _componentFactory.resourceResolver, _ref.type);

    if (_shadowViewFactoryFuture != null) {
      _shadowViewFactoryFuture.then((viewFactory) => _shadowViewFactory = viewFactory);
    }
  }

  List<Key> get callArgs => _CALL_ARGS;
  static final _CALL_ARGS = [DIRECTIVE_INJECTOR_KEY, SCOPE_KEY, VIEW_KEY, NG_BASE_CSS_KEY,
      SHADOW_BOUNDARY_KEY];

  Function call(dom.Element element) {
    return (DirectiveInjector injector, Scope scope, View view, NgBaseCss baseCss,
        ShadowBoundary parentShadowBoundary) {
      var s = traceEnter(View_createComponent);
      try {
        var shadowRoot = element.createShadowRoot();

        var shadowBoundary;
        if (_componentFactory.platformShim.shimRequired) {
          shadowBoundary = parentShadowBoundary;
        } else {
          shadowBoundary = new ShadowRootBoundary(shadowRoot);
        }

        List<async.Future> futures = <async.Future>[];
        TemplateLoader templateLoader = new TemplateLoader(shadowRoot, futures);

        var probe;
        var eventHandler = new ShadowRootEventHandler(
            shadowRoot, injector.getByKey(EXPANDO_KEY), injector.getByKey(EXCEPTION_HANDLER_KEY));
        final shadowInjector = new ComponentDirectiveInjector(injector, _injector, eventHandler, null,
            templateLoader, shadowRoot, null, _ref.typeKey, view, shadowBoundary);
        shadowInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys, _ref.annotation.visibility);


        if (_component.useNgBaseCss && baseCss.urls.isNotEmpty) {
          if (baseCss.styles == null) {
            final f = _componentFactory.cssLoader(_tag, baseCss.urls).then((cssList) {
              baseCss.styles = cssList;
              shadowBoundary.insertStyleElements(cssList, prepend: true);
            });
            futures.add(f);
          } else {
            shadowBoundary.insertStyleElements(baseCss.styles, prepend: true);
          }
        }

        if (_styleElementsFuture != null) {
          if (_styleElements == null) {
            final f = _styleElementsFuture.then(shadowBoundary.insertStyleElements);
            futures.add(f);
          } else {
            shadowBoundary.insertStyleElements(_styleElements);
          }
        }

        if (_shadowViewFactoryFuture != null) {
          if (_shadowViewFactory == null) {
            final f = _shadowViewFactoryFuture.then((ViewFactory viewFactory) =>
                _insertView(viewFactory, shadowRoot, shadowInjector.scope, shadowInjector));
            futures.add(f);
          } else {
            final f = new Future.microtask(() {
              _insertView(_shadowViewFactory, shadowRoot, shadowInjector.scope, shadowInjector);
            });
            futures.add(f);
          }
        }

        var controller = shadowInjector.getByKey(_ref.typeKey);
        var shadowScope = shadowInjector.getByKey(SCOPE_KEY);
        if (controller is ScopeAware) controller.scope = shadowScope;
        BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);

        if (_componentFactory.config.elementProbeEnabled) {
          ElementProbe probe = _componentFactory.expando[shadowRoot] = shadowInjector.elementProbe;
          shadowScope.on(ScopeEvent.DESTROY).listen((ScopeEvent) => _componentFactory.expando[shadowRoot] = null);
        }

        return controller;
      } finally {
        traceLeave(s);
      }
    };
  }

  dom.Node _insertView(ViewFactory viewFactory,
              dom.ShadowRoot shadowRoot,
              Scope shadowScope,
              ComponentDirectiveInjector shadowInjector) {
    if (shadowScope.isAttached) {
      shadowRoot.nodes.addAll(
          viewFactory.call(shadowInjector.scope, shadowInjector).nodes);
    }
  }
}

@Injectable()
class ComponentCssRewriter {
  String call(String css, { String selector, String cssUrl} ) {
    return css;
  }
}
