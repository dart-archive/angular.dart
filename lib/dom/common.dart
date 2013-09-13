library angular.dom.common;

import "dart:html" as dom;

List<dom.Node> cloneElements(elements) {
  var clones = [];
  for(var i = 0, ii = elements.length; i < ii; i++) {
    clones.add(elements[i].clone(true));
  }
  return clones;
}
