part of angular.core.dom_internal;

class TaggingViewFactory implements ViewFactory {
  final List<TaggedElementBinder> elementBinders;
  final List<dom.Node> templateNodes;
  final Profiler _perf;

  TaggingViewFactory(this.templateNodes, this.elementBinders, this._perf);

  BoundViewFactory bind(Injector injector) =>
  new BoundViewFactory(this, injector);

  View call(Injector injector, [List<dom.Node> nodes /* TODO: document fragment */]) {
    if (nodes == null) {
      nodes = cloneElements(templateNodes);
    }
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

  _bindTagged(TaggedElementBinder tagged, rootInjector, elementBinders, View view, boundNode) {
    var binder = tagged.binder;
    var parentInjector = tagged.parentBinderOffset == -1 ? rootInjector : elementBinders[tagged.parentBinderOffset].injector;
    assert(parentInjector != null);

    tagged.injector = binder != null ? binder.bind(view, parentInjector, boundNode) : parentInjector;

    if (tagged.textBinders != null) {
      for (var k = 0, kk = tagged.textBinders.length; k < kk; k++) {
        TaggedTextBinder taggedText = tagged.textBinders[k];
        taggedText.binder.bind(view, tagged.injector, boundNode.childNodes[taggedText.offsetIndex]);
      }
    }
  }

  View _link(View view, List<dom.Node> nodeList, List elementBinders, Injector rootInjector) {
    var directiveDefsByName = {};

    var elementBinderIndex = 0;
    for (int i = 0, ii = nodeList.length; i < ii; i++) {
      var node = nodeList[i];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      if (node.nodeType == 1) {
        var elts = node.querySelectorAll('.ng-binding');
        // HACK: querySelectorAll doesn't return the node.
        var startIndex = node.classes.contains('ng-binding') ? -1 : 0;
        for (int j = startIndex, jj = elts.length; j < jj; j++, elementBinderIndex++) {
          TaggedElementBinder tagged = elementBinders[elementBinderIndex];
          var boundNode = j == -1 ? node : elts[j];

          _bindTagged(tagged, rootInjector, elementBinders, view, boundNode);
        }
      } else if (node.nodeType == 3 || node.nodeType == 8) {
        TaggedElementBinder tagged = elementBinders[elementBinderIndex];
        assert(tagged.binder != null || tagged.isTopLevel);
        if (tagged.binder != null) {
          _bindTagged(tagged, rootInjector, elementBinders, view, node);
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
