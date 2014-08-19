part of angular.core.dom_internal;

class NodeCursor {
  final stack = [];
  List<dom.Node> elements;  // may be a fixed length list.
  int index = 0;

  NodeCursor(this.elements);

  bool moveNext() => ++index < elements.length;

  dom.Node get current => index < elements.length ? elements[index] : null;

  bool descend() {
    var childNodes = elements[index].nodes;
    var hasChildren = childNodes.isNotEmpty;

    if (hasChildren) {
      stack..add(index)..add(elements);
      elements = childNodes;
      index = 0;
    }

    return hasChildren;
  }

  void ascend() {
    elements = stack.removeLast();
    index = stack.removeLast();
  }

  NodeCursor replaceWithAnchor(Map attrs) {
    var element = current;
    var parent = element.parentNode;
    var anchor = new dom.TemplateElement()
      ..classes.add(NG_BINDING)
      ..attributes.addAll(attrs);
    if (parent != null) parent.insertBefore(anchor, element);
    element.remove();
    elements[index] = anchor;
    return new NodeCursor([element]);
  }

  String toString() => "[NodeCursor: $elements $index]";
}
