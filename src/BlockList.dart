part of angular;

class BlockListFactory {
  Scope $rootScope;
  BlockListFactory(Scope this.$rootScope);

  BlockList call(List<dom.Node> elements, Map<String, BlockType> blockTypes,
                 [List<BlockCache> blockCaches]) {
    return new BlockList($rootScope, elements, blockTypes, blockCaches);
  }
}

/**
 * An Anchor is an instance of a hole. Anchors designate where child Blocks can
 * be added in parent Block. Anchors wrap a DOM element, and act as references
 * which allows more blocks to be added.
 */
class BlockList extends ElementWrapper {
  Scope $rootScope;
  List<dom.Node> elements;
  Map<String, BlockType> blockTypes;
  BlockCache blockCache;

  ElementWrapper previous;
  ElementWrapper next;

  BlockList(Scope this.$rootScope, List<dom.Node> this.elements,
            Map<String, BlockType> this.blockTypes, [BlockCache blockCache]) {
    if (!?blockCache) {
      blockCache = new BlockCache();
    }
    this.blockCache = blockCache;

    // This is a bit of a hack.
    // We need to run after the first watch, that means we have to wait for
    // watch, and then schedule $evalAsync.
    var deregisterWatch = $rootScope.$watch(() {
      deregisterWatch();
      $rootScope.$evalAsync(() {
        blockCache.flush((block) {
          block.remove();
        });
      });
    });
  }

  Block newBlock([String type = '']) {
    Block block = this.blockCache.get(type);

    if (block == null) {
      if (!this.blockTypes.hasOwnProperty(type)) {
        throw new ArgumentError("Unknown block type: '$type'.");
      }

      block = this.blockTypes[type]();
    }

    return block;
  }
}
