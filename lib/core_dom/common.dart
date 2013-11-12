part of angular.core.dom;

List<dom.Node> cloneElements(elements) {
  var clones = [];
  for(var i = 0, ii = elements.length; i < ii; i++) {
    clones.add(elements[i].clone(true));
  }
  return clones;
}

typedef ApplyMapping(NodeAttrs attrs, Scope scope, Object dst);

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final DirectiveMetadataWrapper metadata;
  final String value;
  final List<ApplyMapping> mappings = new List<ApplyMapping>();

  BlockFactory blockFactory;

  DirectiveRef(dom.Node this.element, Type this.type,
      DirectiveMetadataWrapper this.metadata, [ String this.value ]);

  String toString() {
    var html = element is dom.Element ? (element as dom.Element).outerHtml : element.nodeValue;
    return '{ element: $html, selector: ${metadata.annotation.selector}, value: $value }';
  }
}

