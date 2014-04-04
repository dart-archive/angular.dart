part of angular.core.dom_internal;

/**
    - * [WalkingViewFactory] is used to create new [View]s. WalkingViewFactory is
    - * created by the [Compiler] as a result of compiling a template.
    - */
class WalkingViewFactory implements ViewFactory {
  final List<ElementBinderTreeRef> elementBinders;
  final List<dom.Node> templateElements;
  final Profiler _perf;
  final Expando _expando;

  WalkingViewFactory(this.templateElements, this.elementBinders, this._perf,
                     this._expando) {
    assert(elementBinders.every((eb) => eb is ElementBinderTreeRef));
  }

  BoundViewFactory bind(Injector injector) =>
      new BoundViewFactory(this, injector);

  View call(Injector injector, [List<dom.Node> nodes]) {
    if (nodes == null) nodes = cloneElements(templateElements);
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      var view = new View(nodes, injector.get(EventHandler));
      _link(view, nodes, elementBinders, injector);
      return view;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  View _link(View view, List<dom.Node> nodeList, List elementBinders,
             Injector parentInjector) {

    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {};

    for (int i = 0; i < elementBinders.length; i++) {
      // querySelectorAll('.ng-binding') should return a list of nodes in the
      // same order as the elementBinders list.

      // keep a injector array --

      var eb = elementBinders[i];
      int index = eb.offsetIndex;

      ElementBinderTree tree = eb.subtree;

      //List childElementBinders = eb.childElementBinders;
      int nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];
      var binder = tree.binder;

      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.view.link', _html(node))) != false);
        // if node isn't attached to the DOM, create a parent for it.
        var parentNode = node.parentNode;
        var fakeParent = false;
        if (parentNode == null) {
          fakeParent = true;
          parentNode = new dom.DivElement()..append(node);
        }

        var childInjector = binder != null ?
            binder.bind(view, parentInjector, node) :
            parentInjector;

        // extract the node from the parentNode.
        if (fakeParent) nodeList[nodeListIndex] = parentNode.nodes[0];

        if (tree.subtrees != null) {
          _link(view, node.nodes, tree.subtrees, childInjector);
        }
      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }
    }
    return view;
  }
}