part of angular.core.dom_internal;

@Injectable()
class TranscludingComponentFactory implements ComponentFactory {

  final Expando expando;
  final ViewCache viewCache;
  final CompilerConfig config;
  final TypeToUriMapper uriMapper;
  final ResourceUrlResolver resourceResolver;

  TranscludingComponentFactory(this.expando, this.viewCache, this.config,
      this.uriMapper, this.resourceResolver);

  bind(DirectiveRef ref, directives, injector) =>
      new BoundTranscludingComponentFactory(this, ref, directives, injector);
}

class BoundTranscludingComponentFactory implements BoundComponentFactory {
  final TranscludingComponentFactory _f;
  final DirectiveRef _ref;
  final DirectiveMap _directives;
  final Injector _injector;

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
  }

  List<Key> get callArgs => _CALL_ARGS;
  static var _CALL_ARGS = [ DIRECTIVE_INJECTOR_KEY, SCOPE_KEY, VIEW_KEY,
                            VIEW_CACHE_KEY, HTTP_KEY, TEMPLATE_CACHE_KEY,
                            DIRECTIVE_MAP_KEY, NG_BASE_CSS_KEY, EVENT_HANDLER_KEY];
  Function call(dom.Node node) {
    // CSS is not supported.
    assert(_component.cssUrls == null ||
           _component.cssUrls.isEmpty);

    var element = node as dom.Element;
    return (DirectiveInjector injector, Scope scope, View view,
            ViewCache viewCache, Http http, TemplateCache templateCache,
            DirectiveMap directives, NgBaseCss baseCss, EventHandler eventHandler) {

      DirectiveInjector childInjector;
      var childInjectorCompleter; // Used if the ViewFuture is available before the childInjector.

      var component = _component;
      var lightDom = new LightDom(element, scope)..pullNodes();

      // Append the component's template as children
      var elementFuture;

      if (_viewFuture != null) {
        elementFuture = _viewFuture.then((ViewFactory viewFactory) {
          lightDom.clearComponentElement();
          if (childInjector != null) {
            lightDom.shadowDomView = viewFactory.call(childInjector.scope, childInjector);
            return element;
          } else {
            childInjectorCompleter = new async.Completer();
            return childInjectorCompleter.future.then((childInjector) {
              lightDom.shadowDomView = viewFactory.call(childInjector.scope, childInjector);
              return element;
            });
          }
        });
      } else {
        elementFuture = new async.Future.microtask(lightDom.clearComponentElement);
      }
      TemplateLoader templateLoader = new TemplateLoader(elementFuture);

      Scope shadowScope = scope.createChild(new HashMap());

      childInjector = new ComponentDirectiveInjector(injector, this._injector,
          eventHandler, shadowScope, templateLoader, new EmulatedShadowRoot(element), lightDom, view);

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
