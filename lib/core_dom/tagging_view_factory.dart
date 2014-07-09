part of angular.core.dom_internal;

var ngViewTag = new UserTag('NgView');

class TaggingViewFactory implements ViewFactory {
  final List<TaggedElementBinder> elementBinders;
  final List<dom.Node> templateNodes;
  final Profiler _perf;

  TaggingViewFactory(this.templateNodes, this.elementBinders, this._perf);

  @deprecated
  BoundViewFactory bind(DirectiveInjector directiveInjector, Injector appInjector) =>
      new BoundViewFactory(this, directiveInjector, appInjector);

  View call(Scope scope, DirectiveInjector directiveInjector, Injector appInjector,
            [List<dom.Node> nodes /* TODO: document fragment */]) {
    assert(scope != null);
    var lastTag = ngViewTag.makeCurrent();
    if (nodes == null) {
      nodes = cloneElements(templateNodes);
    }
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      Animate animate = appInjector.getByKey(ANIMATE_KEY);
      EventHandler eventHandler = directiveInjector == null
          ? appInjector.getByKey(EVENT_HANDLER_KEY)
          : directiveInjector.getByKey(EVENT_HANDLER_KEY);
      var view = new View(nodes, scope, eventHandler);
      _link(view, scope, nodes, eventHandler, animate, directiveInjector, appInjector);
      return view;
    } finally {
      lastTag.makeCurrent();
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  void _bindTagged(TaggedElementBinder tagged, int elementBinderIndex,
                   DirectiveInjector rootInjector, Injector appInjector,
                   List<DirectiveInjector> elementInjectors, View view, boundNode, Scope scope,
                   EventHandler eventHandler, Animate animate) {
    var binder = tagged.binder;
    DirectiveInjector parentInjector =
        tagged.parentBinderOffset == -1 ? rootInjector : elementInjectors[tagged.parentBinderOffset];

    var elementInjector;
    if (binder == null) {
      elementInjector = parentInjector;
    }  else {
      elementInjector = binder.bind(view, scope, parentInjector, appInjector, boundNode, eventHandler, animate);
      // TODO(misko): Remove this after we remove controllers. No controllers -> 1to1 Scope:View.
      scope = elementInjector.scope;
    }
    elementInjectors[elementBinderIndex] = elementInjector;

    if (tagged.textBinders != null) {
      for (var k = 0; k < tagged.textBinders.length; k++) {
        TaggedTextBinder taggedText = tagged.textBinders[k];
        var childNode = boundNode.childNodes[taggedText.offsetIndex];
        taggedText.binder.bind(view, scope, elementInjector, appInjector, childNode, eventHandler, animate);
      }
    }
  }

  View _link(View view, Scope scope, List<dom.Node> nodeList, EventHandler eventHandler,
             Animate animate, DirectiveInjector rootInjector, Injector appInjector) {
    var elementInjectors = new List<DirectiveInjector>(elementBinders.length);
    var directiveDefsByName = {};

    var elementBinderIndex = 0;
    for (int i = 0; i < nodeList.length; i++) {
      var node = nodeList[i];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      if (node.nodeType == dom.Node.ELEMENT_NODE) {
        var elts = node.querySelectorAll('.ng-binding');
        // querySelectorAll doesn't return the node itself
        if (node.classes.contains('ng-binding')) {
          var tagged = elementBinders[elementBinderIndex];
          _bindTagged(tagged, elementBinderIndex, rootInjector, appInjector,
              elementInjectors, view, node, scope, eventHandler, animate);
          elementBinderIndex++;
        }

        for (int j = 0; j < elts.length; j++, elementBinderIndex++) {
          TaggedElementBinder tagged = elementBinders[elementBinderIndex];
          _bindTagged(tagged, elementBinderIndex, rootInjector, appInjector,
              elementInjectors, view, elts[j], scope, eventHandler, animate);
        }
      } else if (node.nodeType == dom.Node.TEXT_NODE ||
                 node.nodeType == dom.Node.COMMENT_NODE) {
        TaggedElementBinder tagged = elementBinders[elementBinderIndex];
        assert(tagged.binder != null || tagged.isTopLevel);
        if (tagged.binder != null) {
          _bindTagged(tagged, elementBinderIndex, rootInjector, appInjector,
              elementInjectors, view, node, scope, eventHandler, animate);
        }
        elementBinderIndex++;
      } else {
        throw "nodeType sadness ${node.nodeType}}";
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[i] = parentNode.nodes[0];
      }
    }
    return view;
  }
}
