part of angular.core.dom_internal;

abstract class ComponentFactory {
  BoundComponentFactory bind(DirectiveRef ref, directives);
}

/**
 * A Component factory with has been bound to a specific component type.
 */
abstract class BoundComponentFactory {
  List<Key> get callArgs;
  Function call(dom.Element element);

  static async.Future<ViewFactory> _viewFactoryFuture(
        Component component, ViewCache viewCache, DirectiveMap directives) {
    if (component.template != null) {
      return new async.Future.value(viewCache.fromHtml(component.template, directives));
    }
    if (component.templateUrl != null) {
      return viewCache.fromUrl(component.templateUrl, directives);
    }
    return null;
  }

  static void _setupOnShadowDomAttach(controller, TemplateLoader templateLoader,
                                      Scope shadowScope) {
    if (controller is ShadowRootAware) {
      templateLoader.template.then((shadowDom) {
        if (!shadowScope.isAttached) return;
        (controller as ShadowRootAware).onShadowRoot(shadowDom);
      });
    }
  }
}

@Injectable()
class ShadowDomComponentFactory implements ComponentFactory {
  final ViewCache viewCache;
  final Http http;
  final TemplateCache templateCache;
  final WebPlatform platform;
  final ComponentCssRewriter componentCssRewriter;
  final dom.NodeTreeSanitizer treeSanitizer;
  final Expando expando;
  final CompilerConfig config;

  final Map<_ComponentAssetKey, async.Future<dom.StyleElement>> styleElementCache = {};

  ShadowDomComponentFactory(this.viewCache, this.http, this.templateCache, this.platform,
                            this.componentCssRewriter, this.treeSanitizer, this.expando,
                            this.config, CacheRegister cacheRegister) {
    cacheRegister.registerCache("ShadowDomComponentFactoryStyles", styleElementCache);
  }

  bind(DirectiveRef ref, directives) =>
      new BoundShadowDomComponentFactory(this, ref, directives);
}

class BoundShadowDomComponentFactory implements BoundComponentFactory {

  final ShadowDomComponentFactory _componentFactory;
  final DirectiveRef _ref;
  final DirectiveMap _directives;

  Component get _component => _ref.annotation as Component;

  String _tag;
  async.Future<List<dom.StyleElement>> _styleElementsFuture;
  List<dom.StyleElement> _styleElements;
  async.Future<ViewFactory> _shadowViewFactoryFuture;
  ViewFactory _shadowViewFactory;

  BoundShadowDomComponentFactory(this._componentFactory, this._ref, this._directives) {
    _tag = _component.selector.toLowerCase();
    _styleElementsFuture = async.Future.wait(_component.cssUrls.map(_urlToStyle))
        ..then((stylesElements) => _styleElements = stylesElements);

    _shadowViewFactoryFuture = BoundComponentFactory._viewFactoryFuture(
        _component,
        // TODO(misko): Why do we create a new one per Component. This kind of defeats the caching.
        new PlatformViewCache(_componentFactory.viewCache, _tag, _componentFactory.platform),
        _directives);
    if (_shadowViewFactoryFuture != null) {
      _shadowViewFactoryFuture.then((viewFactory) => _shadowViewFactory = viewFactory);
    }
  }

  async.Future<dom.StyleElement> _urlToStyle(cssUrl) {
    Http http = _componentFactory.http;
    TemplateCache templateCache = _componentFactory.templateCache;
    WebPlatform platform = _componentFactory.platform;
    ComponentCssRewriter componentCssRewriter = _componentFactory.componentCssRewriter;
    dom.NodeTreeSanitizer treeSanitizer = _componentFactory.treeSanitizer;

    return _componentFactory.styleElementCache.putIfAbsent(
        new _ComponentAssetKey(_tag, cssUrl), () =>
        http.get(cssUrl, cache: templateCache)
        .then((resp) => resp.responseText,
        onError: (e) => '/*\n$e\n*/\n')
        .then((String css) {

          // Shim CSS if required
          if (platform.cssShimRequired) {
            css = platform.shimCss(css, selector: _tag, cssUrl: cssUrl);
          }

          // If a css rewriter is installed, run the css through a rewriter
          var styleElement = new dom.StyleElement()
            ..appendText(componentCssRewriter(css, selector: _tag,
          cssUrl: cssUrl));

          // ensure there are no invalid tags or modifications
          treeSanitizer.sanitizeTree(styleElement);

          // If the css shim is required, it means that scoping does not
          // work, and adding the style to the head of the document is
          // preferable.
          if (platform.cssShimRequired) {
            dom.document.head.append(styleElement);
            return null;
          }

          return styleElement;
        })
    );
  }

  List<Key> get callArgs => _CALL_ARGS;
  static final _CALL_ARGS = [DIRECTIVE_INJECTOR_KEY, SCOPE_KEY, NG_BASE_CSS_KEY,
                             EVENT_HANDLER_KEY];
  Function call(dom.Element element) {
    return (DirectiveInjector injector, Scope scope, NgBaseCss baseCss,
            EventHandler eventHandler) {
      var s = traceEnter(View_createComponent);
      try {
        var shadowScope = scope.createChild(new HashMap()); // Isolate
        ComponentDirectiveInjector shadowInjector;
        dom.ShadowRoot shadowRoot = element.createShadowRoot();
        shadowRoot
          ..applyAuthorStyles = _component.applyAuthorStyles
          ..resetStyleInheritance = _component.resetStyleInheritance;

        List<async.Future> futures = <async.Future>[];
        TemplateLoader templateLoader = new TemplateLoader(shadowRoot, futures);
        shadowInjector = new ShadowDomComponentDirectiveInjector(
            injector, injector.appInjector, shadowScope, templateLoader, shadowRoot);
        shadowInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys,
            _ref.annotation.visibility);
        dom.Node firstViewNode = null;

        // Load ngBase CSS
        if (_component.useNgBaseCss == true && baseCss.urls.isNotEmpty) {
          if (baseCss.styles == null) {
            futures.add(async.Future
                .wait(baseCss.urls.map(_urlToStyle))
                .then((List<dom.StyleElement> cssList) {
                  baseCss.styles = cssList;
                  _insertCss(cssList, shadowRoot, shadowRoot.firstChild);
                }));
          } else {
            _insertCss(baseCss.styles, shadowRoot, shadowRoot.firstChild);
          }
        }

        if (_styleElementsFuture != null) {
          if (_styleElements == null) {
            futures.add(_styleElementsFuture .then((List<dom.StyleElement> styles) =>
                _insertCss(styles, shadowRoot, firstViewNode)));
          } else {
            _insertCss(_styleElements, shadowRoot);
          }
        }


        if (_shadowViewFactoryFuture != null) {
          if (_shadowViewFactory == null) {
            futures.add(_shadowViewFactoryFuture.then((ViewFactory viewFactory) =>
                firstViewNode = _insertView(viewFactory, shadowRoot, shadowScope, shadowInjector)));
          } else {
            _insertView(_shadowViewFactory, shadowRoot, shadowScope, shadowInjector);
          }
        }

        if (_componentFactory.config.elementProbeEnabled) {
          ElementProbe probe = _componentFactory.expando[shadowRoot] = shadowInjector.elementProbe;
          shadowScope.on(ScopeEvent.DESTROY).listen((ScopeEvent) => _componentFactory.expando[shadowRoot] = null);
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

  _insertCss(List<dom.StyleElement> cssList,
             dom.ShadowRoot shadowRoot,
             [dom.Node insertBefore = null]) {
    var s = traceEnter(View_styles);
    for(int i = 0; i < cssList.length; i++) {
      var styleElement = cssList[i];
      if (styleElement != null) {
        shadowRoot.insertBefore(styleElement.clone(true), insertBefore);
      }
    }
    traceLeave(s);
  }

  dom.Node _insertView(ViewFactory viewFactory,
              dom.ShadowRoot shadowRoot,
              Scope shadowScope,
              ShadowDomComponentDirectiveInjector shadowInjector) {
    dom.Node first = null;
    if (shadowScope.isAttached) {
      View shadowView = viewFactory.call(shadowScope, shadowInjector);
      List<dom.Node> shadowViewNodes = shadowView.nodes;
      for (var j = 0; j < shadowViewNodes.length; j++) {
        var node = shadowViewNodes[j];
        if (j == 0) first = node;
        shadowRoot.append(node);
      }
    }
    return first;
  }
}

class _ComponentAssetKey {
  final String tag;
  final String assetUrl;

  final String _key;

  _ComponentAssetKey(String tag, String assetUrl)
      : _key = "$tag|$assetUrl",
        this.tag = tag,
        this.assetUrl = assetUrl;

  @override
  String toString() => _key;

  @override
  int get hashCode => _key.hashCode;

  bool operator ==(key) =>
      key is _ComponentAssetKey
      && tag == key.tag
      && assetUrl == key.assetUrl;
}

@Injectable()
class ComponentCssRewriter {
  String call(String css, { String selector, String cssUrl} ) {
    return css;
  }
}
