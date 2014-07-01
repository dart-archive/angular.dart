part of angular.core.dom_internal;

class NodeLinkingInfo {
  /**
   * True if the Node has a 'ng-binding' class.
   */
  final bool containsNgBinding;

  /**
   * True if the Node is a [dom.Element], otherwise it is a Text or Comment node.
   * No other nodeTypes are allowed.
   */
  final bool isElement;

  /**
   * If true, some child has a 'ng-binding' class and the ViewFactory must search
   * for these children.
   */
  final bool ngBindingChildren;

  NodeLinkingInfo(this.containsNgBinding, this.isElement, this.ngBindingChildren);
}

computeNodeLinkingInfos(List<dom.Node> nodeList) {
  List<NodeLinkingInfo> list = new List<NodeLinkingInfo>(nodeList.length);

  for (int i = 0; i < nodeList.length; i++) {
    dom.Node node = nodeList[i];

    assert(node.nodeType == dom.Node.ELEMENT_NODE ||
           node.nodeType == dom.Node.TEXT_NODE ||
           node.nodeType == dom.Node.COMMENT_NODE);

    bool isElement = node.nodeType == dom.Node.ELEMENT_NODE;

    list[i] = new NodeLinkingInfo(
        isElement && (node as dom.Element).classes.contains('ng-binding'),
        isElement,
        isElement && (node as dom.Element).querySelectorAll('.ng-binding').length > 0);
  }
  return list;
}

class TaggingViewFactory implements ViewFactory {
  final List<TaggedElementBinder> elementBinders;
  final List<dom.Node> templateNodes;
  final List<NodeLinkingInfo> nodeLinkingInfos;
  final Profiler _perf;

  TaggingViewFactory(templateNodes, this.elementBinders, this._perf) :
      nodeLinkingInfos = computeNodeLinkingInfos(templateNodes),
      this.templateNodes = templateNodes;

  BoundViewFactory bind(Injector injector) => new BoundViewFactory(this, injector);

  static Key _EVENT_HANDLER_KEY = new Key(EventHandler);

  View call(Injector injector, [List<dom.Node> nodes /* TODO: document fragment */]) {
    if (nodes == null) {
      nodes = cloneElements(templateNodes);
    }
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      var view = new View(nodes, injector.getByKey(_EVENT_HANDLER_KEY));
      _link(view, nodes, injector);
      return view;
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  void _bindTagged(TaggedElementBinder tagged, int elementBinderIndex, Injector rootInjector,
                   List<Injector> elementInjectors, View view, boundNode) {
    var binder = tagged.binder;
    var parentInjector = tagged.parentBinderOffset == -1 ?
        rootInjector :
        elementInjectors[tagged.parentBinderOffset];
    assert(parentInjector != null);

    var elementInjector = elementInjectors[elementBinderIndex] =
        binder != null ? binder.bind(view, parentInjector, boundNode) : parentInjector;

    if (tagged.textBinders != null) {
      for (var k = 0; k < tagged.textBinders.length; k++) {
        TaggedTextBinder taggedText = tagged.textBinders[k];
        taggedText.binder.bind(view, elementInjector, boundNode.childNodes[taggedText.offsetIndex]);
      }
    }
  }

  View _link(View view, List<dom.Node> nodeList, Injector rootInjector) {
    var elementInjectors = new List<Injector>(elementBinders.length);
    var directiveDefsByName = {};

    var elementBinderIndex = 0;
    for (int i = 0; i < nodeList.length; i++) {
      dom.Node node = nodeList[i];
      NodeLinkingInfo linkingInfo = nodeLinkingInfos[i];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      if (linkingInfo.isElement) {
        if (linkingInfo.containsNgBinding) {
          var tagged = elementBinders[elementBinderIndex];
          _bindTagged(tagged, elementBinderIndex, rootInjector, elementInjectors, view, node);
          elementBinderIndex++;
        }

        if (linkingInfo.ngBindingChildren) {
          var elts = (node as dom.Element).querySelectorAll('.ng-binding');
          for (int j = 0; j < elts.length; j++, elementBinderIndex++) {
            TaggedElementBinder tagged = elementBinders[elementBinderIndex];
            _bindTagged(tagged, elementBinderIndex, rootInjector, elementInjectors, view, elts[j]);
          }
        }
      } else {
        TaggedElementBinder tagged = elementBinders[elementBinderIndex];
        assert(tagged.binder != null || tagged.isTopLevel);
        if (tagged.binder != null) {
          _bindTagged(tagged, elementBinderIndex, rootInjector, elementInjectors, view, node);
        }
        elementBinderIndex++;
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[i] = parentNode.nodes[0];
      }
    }
    return view;
  }
}
