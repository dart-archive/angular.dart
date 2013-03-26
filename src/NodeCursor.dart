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
      nodes.push(elements[index + i]);
    }

    return nodes;
  }

  descend() {
    var childNodes = elements[index].childNodes;
    var hasChildren = !!(childNodes && childNodes.length);

    if (hasChildren) {
      stack.push(index, elements);
      elements = angular.core.dom.NodeCursor.slice.call(childNodes);
      index = 0;
    }

    return hasChildren;
  }

  ascend() {
    elements = stack.pop();
    index = stack.pop();
  }

  insertAnchorBefore(name) {
    var current = elements[index];
    var parent = current.parentNode;
    var anchor = document.createComment('ANCHOR: ' + name);

    angular.core.dom.NodeCursor.splice.call(this.elements, this.index, 0, anchor);
    index++;

    if (parent) {
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
    var parent = nodes[0].parentNode;

    angular.core.dom.NodeCursor.splice.call(this.elements, this.index, nodes.length);
    if (parent) {
      for (var i = 0, ii = nodes.length; i < ii; i++) {
        parent.removeChild(nodes[i]);
      }
    }
    return new angular.core.dom.NodeCursor(nodes);
  }

  isInstance() {
    return false;
  }
}
