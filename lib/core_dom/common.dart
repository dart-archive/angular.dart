part of angular.core.dom_internal;

List<dom.Node> cloneElements(List<dom.Node> elements) {
  int length = elements.length;
  var clones = new List(length);
  for(var i=0; i < length; i++) {
    clones[i] = elements[i].clone(true);
  }
  return clones;
}

class MappingParts {
  final String attrName;
  final AST attrValueAST;
  final String mode;
  final AST dstAST;
  final String originalValue;

  MappingParts(this.attrName, this.attrValueAST, this.mode, this.dstAST, this.originalValue);
}

class DirectiveRef {
  final Type type;
  final Function factory;
  final List<Key> paramKeys;
  final Key typeKey;
  final Directive annotation;
  final String value;
  final AST valueAST;
  final mappings = <MappingParts>[];

  DirectiveRef(type, this.annotation, [ this.value, this.valueAST ])
      : type = type,
        typeKey = key(type),
        factory = Module.DEFAULT_REFLECTOR.factoryFor(type),
        paramKeys = Module.DEFAULT_REFLECTOR.parameterKeysFor(type);

  String toString() {
    return '{selector: ${annotation.selector}, value: $value, '
           'ast: ${valueAST == null ? 'null' : '$valueAST'}, '
           'type: $type }';
  }
}
