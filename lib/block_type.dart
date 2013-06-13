part of angular;

class BlockTypeFactory {
  BlockFactory blockFactory;

  BlockTypeFactory(BlockFactory this.blockFactory);

  BlockType call(templateElements, directivePositions, [group]) {
    return new BlockType(blockFactory, templateElements, directivePositions,
                         ?group && group != null ? group : '');
  }
}

class BlockType {
  BlockFactory blockFactory;
  List directivePositions;
  List<dom.Node> templateElements;
  String group;

  BlockType(this.blockFactory, this.templateElements, this.directivePositions,
            this.group) {
    ASSERT(blockFactory != null);
    ASSERT(templateElements != null);
    ASSERT(directivePositions != null);
    ASSERT(group != null);
  }

  Block call([List<dom.Node> elements, List<BlockCache> blockCaches]) {
    if (!?elements) {
      elements = cloneElements(templateElements);
    }
    if (!?blockCaches || blockCaches == null) {
      blockCaches = [];
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
