part of angular.core.dom_internal;

class NodeCursor {
  final stack = [];
  List<dom.Node> elements;
  int index = 0;

  NodeCursor(this.elements);

  bool moveNext() => ++index < elements.length;

  dom.Node get current => index < elements.length ? elements[index] : null;

  bool descend() {
    var hasChildren = elements[index].hasChildNodes();

    if (hasChildren) {
      stack..add(index)..add(elements);
      elements = new List.from(elements[index].nodes);
      index = 0;
    }

    return hasChildren;
  }

  void ascend() {
    elements = stack.removeLast();
    index = stack.removeLast();
  }

  void insertAnchorBefore(String name) {
    var parent = current.parentNode;
    var anchor = new dom.Comment('ANCHOR: $name');
    elements.insert(index++, anchor);
    if (parent != null) parent.insertBefore(anchor, current);
  }

  NodeCursor replaceWithAnchor(String name) {
    insertAnchorBefore(name);
    var childCursor = remove();
    index--;
    return childCursor;
  }

  NodeCursor remove() => new NodeCursor([elements.removeAt(index)..remove()]);

  String toString() => "[NodeCursor: $elements $index]";
}
