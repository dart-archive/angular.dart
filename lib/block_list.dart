part of angular;

/**
 * An Anchor is an instance of a hole. Anchors designate where child Blocks can
 * be added in parent Block. Anchors wrap a DOM element, and act as references
 * which allows more blocks to be added.
 */
class BlockList extends ElementWrapper {
  List<dom.Node> elements;
  Map<String, BlockType> blockTypes;
  Injector injector;

  ElementWrapper previous;
  ElementWrapper next;

  BlockList(List<dom.Node> this.elements,
            Map<String, BlockType> this.blockTypes,
            Injector this.injector) {
  }

  Block newBlock(Scope scope, [String type = '']) {
    //TODO(misko): BlockList should not be resposible for BlockTypes. This should be simplified.
    if (!this.blockTypes.containsKey(type)) {
      throw new ArgumentError("Unknown block type: '$type'.");
    }

    return this.blockTypes[type](injector.createChild([new ScopeModule(scope)]));
  }
}
