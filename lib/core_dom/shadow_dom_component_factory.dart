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

  static async.Future<ViewFactory> _viewFuture(
        Component component, ViewCache viewCache, DirectiveMap directives,
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
  final ViewCache viewCache;
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
    final styleElementCache = _registerCache(cacheRegister);
    cssLoader = new ComponentCssLoader(http, templateCache, platformShim,
        componentCssRewriter, treeSanitizer, styleElementCache, resourceResolver);
  }

  bind(DirectiveRef ref, directives, injector) =>
      new BoundShadowDomComponentFactory(this, ref, directives, injector);

  Map _registerCache(CacheRegister cacheRegister) {
    if (! cacheRegister.hasCache("TranscludingComponentFactoryStyles")) {
      cacheRegister.registerCache("TranscludingComponentFactoryStyles", new HashMap());
    }
    return cacheRegister.getCache("TranscludingComponentFactoryStyles");
  }
}

class BoundShadowDomComponentFactory implements BoundComponentFactory {

  final ShadowDomComponentFactory _componentFactory;
  final DirectiveRef _ref;
  final Injector _injector;

  Component get _component => _ref.annotation as Component;

  String _tag;
  async.Future<Iterable<dom.StyleElement>> _styleElementsFuture;
  async.Future<ViewFactory> _viewFuture;

  BoundShadowDomComponentFactory(this._componentFactory, this._ref,
      DirectiveMap directives, this._injector) {
    _tag = _ref.annotation.selector.toLowerCase();
    _styleElementsFuture = _componentFactory.cssLoader(_tag, _component.cssUrls, type: _ref.type);

    final viewCache = new ShimmingViewCache(_componentFactory.viewCache,
        _tag, _componentFactory.platformShim);
    _viewFuture = BoundComponentFactory._viewFuture(_component, viewCache, directives,
        _componentFactory.uriMapper, _componentFactory.resourceResolver, _ref.type);
  }

  List<Key> get callArgs => _CALL_ARGS;
  static final _CALL_ARGS = [DIRECTIVE_INJECTOR_KEY, SCOPE_KEY, VIEW_KEY, NG_BASE_CSS_KEY,
      SHADOW_BOUNDARY_KEY];
  Function call(dom.Element element) {
    return (DirectiveInjector injector, Scope scope, View view, NgBaseCss baseCss,
        ShadowBoundary parentShadowBoundary) {
      var s = traceEnter(View_createComponent);
      try {
        var shadowDom = element.createShadowRoot()
          ..applyAuthorStyles = _component.applyAuthorStyles
          ..resetStyleInheritance = _component.resetStyleInheritance;

        var shadowBoundary;
        if (_componentFactory.platformShim.shimRequired) {
          shadowBoundary = parentShadowBoundary;
        } else {
          shadowBoundary = new ShadowRootBoundary(shadowDom);
        }

        //_styleFuture(cssUrl, resolveUri: false)
        var shadowScope = scope.createChild(new HashMap()); // Isolate
        ComponentDirectiveInjector shadowInjector;

        final baseUrls = (_component.useNgBaseCss) ? baseCss.urls : [];
        final baseUrlsFuture = _componentFactory.cssLoader(_tag, baseUrls);
        final cssFuture = mergeFutures(baseUrlsFuture, _styleElementsFuture);

        async.Future<dom.Node> initShadowDom(_) {
          if (_viewFuture == null) return new async.Future.value(shadowDom);
          return _viewFuture.then((ViewFactory viewFactory) {
            if (shadowScope.isAttached) {
              shadowDom.nodes.addAll(
                  viewFactory.call(shadowInjector.scope, shadowInjector).nodes);
            }
            return shadowDom;
          });
        }

        TemplateLoader templateLoader = new TemplateLoader(
            cssFuture.then(shadowBoundary.insertStyleElements).then(initShadowDom));

        var probe;
        var eventHandler = new ShadowRootEventHandler(
            shadowDom, injector.getByKey(EXPANDO_KEY), injector.getByKey(EXCEPTION_HANDLER_KEY));
        shadowInjector = new ComponentDirectiveInjector(injector, _injector, eventHandler, shadowScope,
            templateLoader, shadowDom, null, view, shadowBoundary);


        shadowInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys, _ref.annotation.visibility);

        if (_componentFactory.config.elementProbeEnabled) {
          probe = _componentFactory.expando[shadowDom] = shadowInjector.elementProbe;
          shadowScope.on(ScopeEvent.DESTROY).listen((ScopeEvent) => _componentFactory.expando[shadowDom] = null);
        }

        var controller = shadowInjector.getByKey(_ref.typeKey);
        if (controller is ScopeAware) controller.scope = shadowScope;
        BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
        shadowScope.context[_component.publishAs] = controller;

        return controller;
      } finally {
        traceLeave(s);
      }
    };
  }
}

@Injectable()
class ComponentCssRewriter {
  String call(String css, { String selector, String cssUrl} ) {
    return css;
  }
}
