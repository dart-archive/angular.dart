part of angular.core.dom_internal;

@Injectable()
class TranscludingComponentFactory implements ComponentFactory {

  final Expando expando;
  final ViewCache viewCache;
  final CompilerConfig config;
  final DefaultPlatformShim platformShim;
  final TypeToUriMapper uriMapper;
  final ResourceUrlResolver resourceResolver;
  ComponentCssLoader cssLoader;

  TranscludingComponentFactory(this.expando, this.viewCache, this.config, this.platformShim,
      this.uriMapper, this.resourceResolver, Http http, TemplateCache templateCache,
      ComponentCssRewriter componentCssRewriter, dom.NodeTreeSanitizer treeSanitizer,
      CacheRegister cacheRegister) {
    final styleElementCache = _registerCache(cacheRegister);
    cssLoader = new ComponentCssLoader(http, templateCache, platformShim,
        componentCssRewriter, treeSanitizer, styleElementCache, resourceResolver);
  }

  bind(DirectiveRef ref, directives, injector) =>
      new BoundTranscludingComponentFactory(this, ref, directives, injector);

  Map _registerCache(CacheRegister cacheRegister) {
    if (! cacheRegister.hasCache("TranscludingComponentFactoryStyles")) {
      cacheRegister.registerCache("TranscludingComponentFactoryStyles", new HashMap());
    }
    return cacheRegister.getCache("TranscludingComponentFactoryStyles");
  }
}

class BoundTranscludingComponentFactory implements BoundComponentFactory {
  final TranscludingComponentFactory _f;
  final DirectiveRef _ref;
  final DirectiveMap _directives;
  final Injector _injector;

  String _tag;
  async.Future<Iterable<dom.StyleElement>> _styleElementsFuture;

  Component get _component => _ref.annotation as Component;
  async.Future<ViewFactory> _viewFuture;

  BoundTranscludingComponentFactory(this._f, this._ref, this._directives, this._injector) {
    _viewFuture = BoundComponentFactory._viewFuture(
        _component,
        _f.viewCache,
        _directives,
        _f.uriMapper,
        _f.resourceResolver,
        _ref.type);
    
    _tag = _ref.annotation.selector.toLowerCase();
    _styleElementsFuture = _f.cssLoader(_tag, _component.cssUrls, type: _ref.type);

    final viewCache = new ShimmingViewCache(_f.viewCache, _tag, _f.platformShim);
    _viewFuture = BoundComponentFactory._viewFuture(_component, viewCache, _directives,
        _f.uriMapper, _f.resourceResolver, _ref.type);
  }

  List<Key> get callArgs => _CALL_ARGS;
  static var _CALL_ARGS = [ DIRECTIVE_INJECTOR_KEY, SCOPE_KEY, VIEW_KEY,
                            VIEW_CACHE_KEY, HTTP_KEY, TEMPLATE_CACHE_KEY,
                            DIRECTIVE_MAP_KEY, NG_BASE_CSS_KEY, EVENT_HANDLER_KEY,
                            SHADOW_BOUNDARY_KEY];
  Function call(dom.Node node) {
    var element = node as dom.Element;
    return (DirectiveInjector injector, Scope scope, View view,
            ViewCache viewCache, Http http, TemplateCache templateCache,
            DirectiveMap directives, NgBaseCss baseCss, EventHandler eventHandler,
            ShadowBoundary shadowBoundary) {

      DirectiveInjector childInjector;
      var childInjectorCompleter; // Used if the ViewFuture is available before the childInjector.

      var component = _component;
      final shadowRoot = new EmulatedShadowRoot(element);
      var lightDom = new LightDom(element, scope)..pullNodes();

      final baseUrls = (_component.useNgBaseCss) ? baseCss.urls : [];
      final baseUrlsFuture = _f.cssLoader(_tag, baseUrls);
      final cssFuture = mergeFutures(baseUrlsFuture, _styleElementsFuture);

      initShadowDom(_) {
        if (_viewFuture != null) {
          return _viewFuture.then((ViewFactory viewFactory) {
            lightDom.clearComponentElement();
            if (childInjector != null) {
              lightDom.shadowDomView = viewFactory.call(childInjector.scope, childInjector);
              return shadowRoot;
            } else {
              childInjectorCompleter = new async.Completer();
              return childInjectorCompleter.future.then((childInjector) {
                lightDom.shadowDomView = viewFactory.call(childInjector.scope, childInjector);
                return shadowRoot;
              });
            }
          });
        } else {
          return new async.Future.microtask(lightDom.clearComponentElement);
        }
      }

      TemplateLoader templateLoader = new TemplateLoader(
          cssFuture.then(shadowBoundary.insertStyleElements).then(initShadowDom));

      Scope shadowScope = scope.createChild(new HashMap());

      childInjector = new ComponentDirectiveInjector(injector, this._injector,
          eventHandler, shadowScope, templateLoader, shadowRoot, lightDom, view);

      childInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys, _ref.annotation.visibility);

      if (childInjectorCompleter != null) {
        childInjectorCompleter.complete(childInjector);
      }

      var controller = childInjector.getByKey(_ref.typeKey);
      shadowScope.context[component.publishAs] = controller;
      if (controller is ScopeAware) controller.scope = shadowScope;
      BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
      return controller;
    };
  }
}
