library angular.dom.common;

import 'dart:html' as dom;
import 'block_factory.dart';
import 'directive.dart';

List<dom.Node> cloneElements(elements) {
  var clones = [];
  for(var i = 0, ii = elements.length; i < ii; i++) {
    clones.add(elements[i].clone(true));
  }
  return clones;
}

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final NgAnnotationBase annotation;
  final String value;

  BlockFactory blockFactory;

  DirectiveRef(dom.Node this.element, Type this.type, NgAnnotationBase this.annotation,
               [ String this.value ]);

  String toString() {
    var html = element is dom.Element ? (element as dom.Element).outerHtml : element.nodeValue;
    return '{ element: $html, selector: ${annotation.selector}, value: $value }';
  }
}

