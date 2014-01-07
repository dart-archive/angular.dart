part of angular.core.dom;

List<dom.Node> cloneElements(elements) {
  return elements.map((el) => el.clone(true)).toList();
}

typedef ApplyMapping(NodeAttrs attrs, Scope scope, Object dst);

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final NgAnnotation annotation;
  final String value;
  final List<ApplyMapping> mappings = new List<ApplyMapping>();

  BlockFactory blockFactory;

  DirectiveRef(this.element, this.type, this.annotation, [ this.value ]);

  String toString() {
    var html = element is dom.Element ? (element as dom.Element).outerHtml : element.nodeValue;
    return '{ element: $html, selector: ${annotation.selector}, value: $value }';
  }
}

