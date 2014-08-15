part of angular.core.dom_internal;

@Decorator(
   selector: 'content')
class Content implements AttachAware, DetachAware {
  final ContentPort _port;
  final dom.Element _element;
  dom.Comment _beginComment;
  Content(this._port, this._element);

  void attach() {
    if (_port == null) return;
    _beginComment = _port.content(_element);
  }
  
  void detach() {
    if (_port == null) return;
    _port.detachContent(_beginComment);
  }
}

class ContentPort {
  dom.Element _element;
  var _childNodes = [];

  ContentPort(this._element);

  void pullNodes() {
    _childNodes.addAll(_element.nodes);
    _element.nodes = [];
  }

  content(dom.Element elt) {
    var hash = elt.hashCode;
    var beginComment = null;

    if (_childNodes.isNotEmpty) {
      beginComment = new dom.Comment("content $hash");
      elt.parent.insertBefore(beginComment, elt);
      elt.parent.insertAllBefore(_childNodes, elt);
      elt.parent.insertBefore(new dom.Comment("end-content $hash"), elt);
      _childNodes = [];
    }

    elt.remove();
    return beginComment;
  }

  void detachContent(dom.Comment _beginComment) {
    // Search for endComment and extract everything in between.
    // TODO optimize -- there may be a better way of pulling out nodes.

    if (_beginComment == null) {
      return;
    }

    var endCommentText = "end-${_beginComment.text}";

    var next;
    for (next = _beginComment.nextNode;
         next.nodeType != dom.Node.COMMENT_NODE || next.text != endCommentText;
         next = _beginComment.nextNode) {
      _childNodes.add(next);
      next.remove();
    }
    assert(next.nodeType == dom.Node.COMMENT_NODE && next.text == endCommentText);
    next.remove();
  }
}

@Injectable()
class TranscludingComponentFactory implements ComponentFactory {

  final Expando expando;
  final ViewCache viewCache;
  final CompilerConfig config;

  TranscludingComponentFactory(this.expando, this.viewCache, this.config);

  bind(DirectiveRef ref, directives, injector) =>
      new BoundTranscludingComponentFactory(this, ref, directives, injector);
}

class BoundTranscludingComponentFactory implements BoundComponentFactory {
  final TranscludingComponentFactory _f;
  final DirectiveRef _ref;
  final DirectiveMap _directives;
  final Injector _injector;

  Component get _component => _ref.annotation as Component;
  async.Future<ViewFactory> _viewFactoryFuture;
  ViewFactory _viewFactory;

  BoundTranscludingComponentFactory(this._f, this._ref, this._directives, this._injector) {
    _viewFactoryFuture = BoundComponentFactory._viewFactoryFuture(_component, _f.viewCache, _directives);
    if (_viewFactoryFuture != null) {
      _viewFactoryFuture.then((viewFactory) => _viewFactory = viewFactory);
    }
  }

  List<Key> get callArgs => _CALL_ARGS;
  static var _CALL_ARGS = [ DIRECTIVE_INJECTOR_KEY, SCOPE_KEY,
                            VIEW_CACHE_KEY, HTTP_KEY, TEMPLATE_CACHE_KEY,
                            DIRECTIVE_MAP_KEY, NG_BASE_CSS_KEY, EVENT_HANDLER_KEY];
  Function call(dom.Node node) {
    // CSS is not supported.
    assert(_component.cssUrls == null ||
           _component.cssUrls.isEmpty);

    var element = node as dom.Element;
    var component = _component;
    return (DirectiveInjector injector, Scope scope,
            ViewCache viewCache, Http http, TemplateCache templateCache,
            DirectiveMap directives, NgBaseCss baseCss, EventHandler eventHandler) {

      List<async.Future> futures = [];
      var contentPort = new ContentPort(element);
      TemplateLoader templateLoader = new TemplateLoader(element, futures);
      Scope shadowScope = scope.createChild(new HashMap());
      DirectiveInjector childInjector = new ComponentDirectiveInjector(
          injector, this._injector, eventHandler, shadowScope, templateLoader,
          new ShadowlessShadowRoot(element), contentPort);
      childInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys, _ref.annotation.visibility);

      var controller = childInjector.getByKey(_ref.typeKey);
      shadowScope.context[component.publishAs] = controller;
      if (controller is ScopeAware) controller.scope = shadowScope;
      BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);

      if (_viewFactoryFuture != null && _viewFactory == null) {
        futures.add(_viewFactoryFuture.then((ViewFactory viewFactory) =>
            _insert(viewFactory, element, childInjector, contentPort)));
      } else {
        scope.rootScope.runAsync(() {
          _insert(_viewFactory, element, childInjector, contentPort);
        });
      }
      return controller;
    };
  }

  _insert(ViewFactory viewFactory, dom.Element element, DirectiveInjector childInjector,
          ContentPort contentPort) {
    contentPort.pullNodes();
    if (viewFactory != null) {
      var viewNodes = viewFactory.call(childInjector.scope, childInjector).nodes;
      for(var i = 0; i < viewNodes.length; i++) {
        element.append(viewNodes[i]);
      }
    }
  }
}
