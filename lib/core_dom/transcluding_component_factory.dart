part of angular.core.dom_internal;

@Decorator(
  selector: 'content'
)
class _Content implements AttachAware, DetachAware {
  final _ContentPort _port;
  final dom.Element _element;
  dom.Comment _beginComment;
  _Content(this._port, this._element);

  attach() {
    if (_port == null) return;
    _beginComment = _port.content(_element);
  }
  
  detach() {
    if (_port == null) return;
    _port.detachContent(_beginComment);
  }
}

class _ContentPort {
  dom.Element _element;
  var _childNodes = [];

  _ContentPort(this._element);

  pullNodes() {
    _element.nodes.forEach((n) => _childNodes.add(n));
    _element.nodes = [];
  }

  content(dom.Element elt) {
    var hash = elt.hashCode;
    var beginComment = new dom.Comment("content $hash");

    if (!_childNodes.isEmpty) {
      elt.parent.insertBefore(beginComment, elt);
      elt.parent.insertAllBefore(_childNodes, elt);
      elt.parent.insertBefore(new dom.Comment("end-content $hash"), elt);
      _childNodes = [];
    }
    elt.remove();
    return beginComment;
  }

  detachContent(dom.Node _beginComment) {
    // Search for endComment and extract everything in between.
    // TODO optimize -- there may be a better way of pulling out nodes.

    var endCommentText = "end-${_beginComment.text}";

    var next;
    for (next = _beginComment.nextNode;
         next.nodeType != dom.Node.COMMENT_NODE && next.text != endCommentText;
         next = _beginComment.nextNode) {
      _childNodes.add(next);
      next.remove();
    }
    assert(next.nodeType == dom.Node.COMMENT_NODE && next.text == endCommentText);
    next.remove();
  }
}

class TranscludingComponentFactory implements ComponentFactory {
  final Expando _expando;

  TranscludingComponentFactory(this._expando);

  FactoryFn call(dom.Node node, DirectiveRef ref) {
    // CSS is not supported.
    assert((ref.annotation as Component).cssUrls == null ||
           (ref.annotation as Component).cssUrls.isEmpty);

    var element = node as dom.Element;
    return (Injector injector) {
      var childInjector;
      var component = ref.annotation as Component;
      Scope scope = injector.get(Scope);
      ViewCache viewCache = injector.get(ViewCache);
      Http http = injector.get(Http);
      TemplateCache templateCache = injector.get(TemplateCache);
      DirectiveMap directives = injector.get(DirectiveMap);
      NgBaseCss baseCss = injector.get(NgBaseCss);

      var contentPort = new _ContentPort(element);

      // Append the component's template as children
      var viewFuture = ComponentFactory._viewFuture(component, viewCache, directives);

      if (viewFuture != null) {
        viewFuture = viewFuture.then((ViewFactory viewFactory) {
          contentPort.pullNodes();
          element.nodes.addAll(viewFactory(childInjector).nodes);
          return element;
        });
      } else {
        viewFuture = new async.Future.microtask(() => contentPort.pullNodes());
      }
      TemplateLoader templateLoader = new TemplateLoader(viewFuture);

      Scope shadowScope = scope.createChild({});

      var probe;
      var childModule = new Module()
        ..type(ref.type)
        ..type(NgElement)
        ..value(_ContentPort, contentPort)
        ..value(Scope, shadowScope)
        ..value(TemplateLoader, templateLoader)
        ..value(dom.ShadowRoot, new ShadowlessShadowRoot(element))
        ..factory(ElementProbe, (_) => probe);
      childInjector = injector.createChild([childModule], name: SHADOW_DOM_INJECTOR_NAME);

      var controller = childInjector.get(ref.type);
      shadowScope.context[component.publishAs] = controller;
      ComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);
      return controller;
    };
  }
}
