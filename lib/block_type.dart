part of angular;

class BlockTypeFactory {

  BlockTypeFactory();

  BlockType call(templateElements, directivePositions, [group]) {
    return new BlockType(templateElements, directivePositions,
                         group != null ? group : '');
  }
}

class BlockType {
  List directivePositions;
  List<dom.Node> templateElements;
  String group;

  BlockType(this.templateElements, this.directivePositions, this.group) {
    ASSERT(templateElements != null);
    ASSERT(directivePositions != null);
    ASSERT(group != null);
  }

  Block call(Injector injector, [List<dom.Node> elements]) {
    if (elements == null) {
      elements = cloneElements(templateElements);
    }
    return new Block(injector, elements, directivePositions, group);
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
