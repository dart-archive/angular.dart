part of angular;

/**
 * An Anchor is an instance of a hole. Anchors designate where child Blocks can
 * be added in parent Block. Anchors wrap a DOM element, and act as references
 * which allows more blocks to be added.
 */
class BlockList extends ElementWrapper {
  List<dom.Node> elements;
  BlockType blockType;
  Injector injector;

  ElementWrapper previous;
  ElementWrapper next;

  BlockList(List<dom.Node> this.elements,
            BlockType this.blockType,
            Injector this.injector) {
  }

  Block newBlock(Scope scope) {
    //TODO(misko): BlockList should not be resposible for BlockTypes. This should be simplified.
    if (this.blockType == null) {
      throw new ArgumentError("Unknown block type.");
    }

    return this.blockType(injector.createChild([new ScopeModule(scope)]));
  }
}
