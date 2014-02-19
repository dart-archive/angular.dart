part of angular.animate;

void _domRemove(List<dom.Node> nodes) {
  // Not every element is sequential if the list of nodes only
  // includes the elements. Removing a block also includes
  // removing non-element nodes inbetween.
  for(var j = 0, jj = nodes.length; j < jj; j++) {
    dom.Node current = nodes[j];
    dom.Node next = j+1 < jj ? nodes[j+1] : null;

    while(next != null && current.nextNode != next) {
      current.nextNode.remove();
    }
    nodes[j].remove();
  }
}

List<dom.Node> _allNodesBetween(List<dom.Node> nodes) {
  var result = [];
  // Not every element is sequential if the list of nodes only
  // includes the elements. Removing a block also includes
  // removing non-element nodes inbetween.
  for(var j = 0, jj = nodes.length; j < jj; j++) {
    dom.Node current = nodes[j];
    dom.Node next = j+1 < jj ? nodes[j+1] : null;

    while(next != null && current.nextNode != next) {
      result.add(current.nextNode);
      current = current.nextNode;
    }
    result.add(nodes[j]);
  }
  return result;
}

void _domInsert(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
  parent.insertAllBefore(nodes, insertBefore);
}

void _domMove(Iterable<dom.Node> nodes, dom.Node parent, { dom.Node insertBefore }) {
  nodes.forEach((n) {
    if(n.parentNode == null) n.remove();
      parent.insertBefore(n, insertBefore);
  });
}
