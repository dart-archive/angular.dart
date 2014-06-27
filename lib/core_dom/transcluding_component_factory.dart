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

  bind(DirectiveRef ref, directives) =>
      new BoundTranscludingComponentFactory(this, ref, directives);
}

class BoundTranscludingComponentFactory implements BoundComponentFactory {
  final TranscludingComponentFactory _f;
  final DirectiveRef _ref;
  final DirectiveMap _directives;

  Component get _component => _ref.annotation as Component;
  async.Future<ViewFactory> _viewFuture;

  BoundTranscludingComponentFactory(this._f, this._ref, this._directives) {
    _viewFuture = BoundComponentFactory._viewFuture(
        _component,
        _f.viewCache,
        _directives);
  }

  FactoryFn call(dom.Node node) {
    // CSS is not supported.
    assert(_component.cssUrls == null ||
           _component.cssUrls.isEmpty);

    var element = node as dom.Element;
    return (Injector injector) {

      var childInjector;
      var childInjectorCompleter; // Used if the ViewFuture is available before the childInjector.

      var component = _component;
      Scope scope = injector.getByKey(SCOPE_KEY);
      ViewCache viewCache = injector.getByKey(VIEW_CACHE_KEY);
      Http http = injector.getByKey(HTTP_KEY);
      TemplateCache templateCache = injector.getByKey(TEMPLATE_CACHE_KEY);
      DirectiveMap directives = injector.getByKey(DIRECTIVE_MAP_KEY);
      NgBaseCss baseCss = injector.getByKey(NG_BASE_CSS_KEY);

      var contentPort = new ContentPort(element);

      // Append the component's template as children
      var elementFuture;

      if (_viewFuture != null) {
        elementFuture = _viewFuture.then((ViewFactory viewFactory) {
          contentPort.pullNodes();
          if (childInjector != null) {
            element.nodes.addAll(viewFactory(childInjector).nodes);
            return element;
          } else {
            childInjectorCompleter = new async.Completer();
            return childInjectorCompleter.future.then((childInjector) {
              element.nodes.addAll(viewFactory(childInjector).nodes);
              return element;
            });
          }
        });
      } else {
        elementFuture = new async.Future.microtask(() => contentPort.pullNodes());
      }
      TemplateLoader templateLoader = new TemplateLoader(elementFuture);

      Scope shadowScope = scope.createChild({});

      var probe;
      var childModule = new Module()
          ..bind(_ref.type)
          ..bind(NgElement)
          ..bind(ContentPort, toValue: contentPort)
          ..bind(Scope, toValue: shadowScope)
          ..bind(TemplateLoader, toValue: templateLoader)
          ..bind(dom.ShadowRoot, toValue: new ShadowlessShadowRoot(element));

      if (_f.config.elementProbeEnabled) {
       childModule.bind(ElementProbe, toFactory: (_) => probe);
      }
      childInjector = injector.createChild([childModule], name: SHADOW_DOM_INJECTOR_NAME);
      if (childInjectorCompleter != null) {
        childInjectorCompleter.complete(childInjector);
      }

      var controller = childInjector.get(_ref.type);
      shadowScope.context[component.publishAs] = controller;
      BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
      return controller;
    };
  }
}
