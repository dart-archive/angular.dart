part of angular.core.dom_internal;

class NodeCursor {
  final stack = [];
  List<dom.Node> elements;
  int index = 0;

  NodeCursor(this.elements);

  bool moveNext() => ++index < elements.length;

  dom.Node get current => index < elements.length ? elements[index] : null;

  bool descend() {
    var childNodes = elements[index].nodes;
    var hasChildren = childNodes != null && childNodes.isNotEmpty;

    if (hasChildren) {
      stack..add(index)..add(elements);
      elements = new List.from(childNodes);
      index = 0;
    }

    return hasChildren;
  }

  void ascend() {
    elements = stack.removeLast();
    index = stack.removeLast();
  }

  void insertAnchorBefore(Map<String, String> attrs) {
    var parent = current.parentNode;
    var anchor = new dom.TemplateElement()
        ..classes.add(NG_BINDING)
        ..attributes.addAll(attrs);
    elements.insert(index++, anchor);
    if (parent != null) parent.insertBefore(anchor, current);
  }

  NodeCursor replaceWithAnchor(Map<String, String> attrs) {
    insertAnchorBefore(attrs);
    var childCursor = remove();
    index--;
    return childCursor;
  }

  NodeCursor remove() => new NodeCursor([elements.removeAt(index)..remove()]);

  toString() => "[NodeCursor: $elements $index]";
}
