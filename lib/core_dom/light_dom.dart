part of angular.core.dom_internal;

abstract class SourceLightDom {
  void redistribute();
}

abstract class DestinationLightDom {
  void redistribute();
  void addViewPort(ViewPort viewPort);
  bool hasRoot(dom.Element element);
}

class LightDom implements SourceLightDom, DestinationLightDom {
  final dom.Element _componentElement;

  final List<dom.Node> _lightDomRootNodes = [];
  final Map<dom.Node, ViewPort> _ports = {};

  final Scope _scope;

  View _shadowDomView;

  LightDom(this._componentElement, this._scope);

  void pullNodes() {
    _lightDomRootNodes.addAll(_componentElement.nodes);

    // This is needed because _lightDomRootNodes can contains viewports,
    // which cannot be detached.
    final fakeRoot = new dom.DivElement();
    fakeRoot.nodes.addAll(_lightDomRootNodes);

    _componentElement.nodes = [];
  }

  void set shadowDomView(View view) {
    _shadowDomView = view;
    _componentElement.nodes = view.nodes;
  }

  void addViewPort(ViewPort viewPort) {
    _ports[viewPort.placeholder] = viewPort;
    redistribute();
  }

  //TODO: vsavkin Add dirty flag after implementing view-scoped dom writes.
  void redistribute() {
    _scope.rootScope.domWrite(() {
      redistributeNodes(_sortedContents, _expandedLightDomRootNodes);
    });
  }

  bool hasRoot(dom.Element element) => _lightDomRootNodes.contains(element);

  List<Content> get _sortedContents {
    final res = [];
    _collectAllContentTags(_shadowDomView, res);
    return res;
  }

  void _collectAllContentTags(item, List<Content> acc) {
    if (item is Content) {
      acc.add(item);

    } else if (item is View) {
      for (final i in item.insertionPoints) {
        _collectAllContentTags(i, acc);
      }

    } else if (item is ViewPort) {
      for (final i in item.views) {
        _collectAllContentTags(i, acc);
      }
    }
  }

  List<dom.Node> get _expandedLightDomRootNodes {
    final list = [];
    for(final root in _lightDomRootNodes) {
      if (_ports.containsKey(root)) {
        list.addAll(_ports[root].nodes);
      } else if (root is dom.ContentElement) {
        list.addAll(root.nodes);
      } else {
        list.add(root);
      }
    }
    return list;
  }
}

void redistributeNodes(Iterable<Content> contents, List<dom.Node> nodes) {
  for (final content in contents) {
    final select = content.select;
    matchSelector(n) => n.nodeType == dom.Node.ELEMENT_NODE && n.matches(select);

    if (select == null) {
      content.insert(nodes);
      nodes.clear();
    } else {
      final matchingNodes = nodes.where(matchSelector);
      content.insert(matchingNodes);
      nodes.removeWhere(matchSelector);
    }
  }
}