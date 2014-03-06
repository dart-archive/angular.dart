part of angular.core.dom;

class TaggingViewFactory implements ViewFactory {
  final List<TaggedElementBinder> elementBinders;
  final List<dom.Node> templateElements;
  final Profiler _perf;
  final Expando _expando;

  TaggingViewFactory(this.templateElements, this.elementBinders, this._perf, this._expando);

  BoundViewFactory bind(Injector injector) =>
  new BoundViewFactory(this, injector);

  View call(Injector injector, [List<dom.Node> elements /* TODO: document fragment */]) {
    if (elements == null) {
      elements = cloneElements(templateElements);
    }
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      var view = new View(elements, injector.get(NgAnimate));
      _link(view, elements, elementBinders, injector);
      return view;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  View _link(View view, List<dom.Node> nodeList, List elementBinders, Injector parentInjector) {


    var directiveDefsByName = {};

    var elementBinderIndex = 0;
    for (int i = 0, ii = nodeList.length; i < ii; i++) {
      var node = nodeList[i];
      print("node: $node ${node.outerHtml}}");

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      if (node is dom.Element) {
        var elts = node.querySelectorAll('.ng-binding');
        // HACK: querySelectorAll doesn't return the node.
        var startIndex = node.classes.contains('ng-binding') ? -1 : 0;
        print("starting at: $startIndex");
        for (int j = startIndex, jj = elts.length; j < jj; j++, elementBinderIndex++) {
          if (j >= 0) print("elt: ${elts[j]} ${elts[j].outerHtml}");
          TaggedElementBinder tagged = elementBinders[elementBinderIndex];

          var binder = tagged.binder;

          var childInjector = binder != null ? binder.bind(view, parentInjector, j == -1 ? node : elts[j]) : parentInjector;
        }
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[i] = parentNode.nodes[0];
      }

      // querySelectorAll('.ng-binding') should return a list of nodes in the same order as the elementBinders list.

      // keep a injector array --

      /*var eb = elementBinders[i];
      int index = i;

      var binder = eb.binder;

      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.view.link', _html(node))) != false);






      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }*/
    }
    return view;
  }
}
