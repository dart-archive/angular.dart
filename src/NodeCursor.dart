part of angular;


class NodeCursor {
  var stack = [];
  var elements;
  var index;

  NodeCursor(this.elements) {
    index = 0;
  }

  isValid() {
    return index < elements.length;
  }

  cursorSize() {
    return 1;
  }

  macroNext() {
    for(var i = 0, ii = cursorSize(); i < ii; i++, index++){}

    return this.isValid();
  }

  microNext() {
    var length = elements.length;

    if (index < length) {
      index++;
    }

    return index < length;
  }

  nodeList() {
    var node = elements[index];
    var nodes = [];

    for(var i = 0, ii = cursorSize(); i < ii; i++) {
      nodes.add(elements[index + i]);
    }

    return nodes;
  }

  descend() {
    var childNodes = elements[index].children;
    var hasChildren = !!(childNodes != null && childNodes.length > 0);

    if (hasChildren) {
      stack.add(index);
      stack.add(elements);
      elements = new List.from(childNodes);
      index = 0;
    }

    return hasChildren;
  }

  ascend() {
    index = stack.removeAt(0);
    elements = stack.removeAt(0);
  }

  insertAnchorBefore(name) {
    var current = elements[index];
    var parent = current.parentNode;

    // HACK
    // var anchor = new dom.Comment('Anchore: $name');
    var anchor = ((body) {
      body.innerHtml = '<!--ANCHOR: $name-->';
      return body.nodes[0];
    })(new dom.BodyElement());

    elements.insert(index++, anchor);

    if (parent != null) {
      parent.insertBefore(anchor, current);
    }
  }

  replaceWithAnchor(name) {
    insertAnchorBefore(name);
    var childCursor = remove();
    this.index--;
    return childCursor;
  }

  remove() {
    var nodes = nodeList();

    for (var i = 0, ii = nodes.length; i < ii; i++) {
      nodes[i].remove();
      elements.removeAt(index);
    }

    return new NodeCursor(nodes);
  }

  isInstance() {
    return false;
  }
}
