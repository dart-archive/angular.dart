part of angular;

class BlockTypeFactory {
  BlockFactory blockFactory;

  BlockTypeFactory(BlockFactory this.blockFactory);

  BlockType call(templateElements, directivePositions, [group]) {
    return new BlockType(blockFactory, templateElements, directivePositions,
                         ?group ? '' : group);
  }
}

class BlockType {
  BlockFactory blockFactory;
  List directivePositions;
  List<dom.Node> templateElements;
  String group;

  BlockType(this.blockFactory, this.templateElements, this.directivePositions,
            this.group);

  Block call([List<dom.Node> elements, List<BlockCache> blockCaches]) {
    if (!?elements) {
      elements = cloneElements(templateElements);
    }

    return blockFactory(elements, directivePositions, blockCaches, group);
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
