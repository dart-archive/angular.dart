part of angular;

class BlockType {
  List directivePositions;
  List<Element> templateElements;

  BlockType(this.templateElements, this.directivePositions);

  Block instantiate([elements]) {
    if (elements == null) {
      elements = cloneElements(templateElements);
    }

    // HACK
    DirectiveDef directiveDef = directivePositions[1];
    Directive directive = directiveDef.directiveType(elements[0], directiveDef.value);

    return new Block(elements, [directive]);
  }

  ClassMirror _getClassMirror(Type type) {
    // terrible hack because we can't get a qualified name from a Type
    var name = type.toString();
    name = new RegExp(r"^Instance of '(.*)'$").firstMatch(name).group(1);
    for (var lib in currentMirrorSystem().libraries.values) {
      if (lib.classes.containsKey(name)) {
        return lib.classes[name];
      }
    }
    throw new ArgumentError();
  }

}
