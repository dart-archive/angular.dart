library angular.dom.common;

import "dart:html" as dom;
import "block_factory.dart";
import "directive.dart";

List<dom.Node> cloneElements(elements) {
  var clones = [];
  for(var i = 0, ii = elements.length; i < ii; i++) {
    clones.add(elements[i].clone(true));
  }
  return clones;
}

class NullTreeSanitizer implements dom.NodeTreeSanitizer {
  void sanitizeTree(dom.Node node) {}
}

class DirectiveRef {
  dom.Node element;
  String value;
  Directive directive;
  BlockFactory blockFactory;

  DirectiveRef(dom.Node this.element, Directive this.directive,
               [ String this.value ]);

  String toString() {
    return '{ element: ${(element as dom.Element).outerHtml}, selector: ${directive.$selector}, value: $value }';
  }
}

