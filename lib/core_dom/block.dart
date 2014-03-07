part of angular.core.dom;

/**
 * A Block is a fundamental building block of DOM. It is a chunk of DOM which
 * can not be structural changed. It can only have its attributes changed.
 * A Block can have [BlockHole]s embedded in its DOM.  A [BlockHole] can
 * contain other [Block]s and it is the only way in which DOM can be changed
 * structurally.
 *
 * A [Block] is a collection of DOM nodes
 *
 * A [Block] can be created from [BlockFactory].
 *
 */
class Block {
  final List<dom.Node> nodes;
  Block(this.nodes);
}

/**
 * A BlockHole is an instance of a hole. BlockHoles designate where child
 * [Block]s can be added in parent [Block]. BlockHoles wrap a DOM element,
 * and act as references which allows more blocks to be added.
 */
class BlockHole {
  final dom.Node placeholder;
  final NgAnimate _animate;
  final List<Block> _blocks = <Block>[];

  BlockHole(this.placeholder, this._animate);

  void insert(Block block, { Block insertAfter }) {
    dom.Node previousNode = _lastNode(insertAfter);
    _blocksInsertAfter(block, insertAfter);

    _animate.insert(block.nodes, placeholder.parentNode,
      insertBefore: previousNode.nextNode);
  }

  void remove(Block block) {
    _blocks.remove(block);
    _animate.remove(block.nodes);
  }

  void move(Block block, { Block moveAfter }) {
    dom.Node previousNode = _lastNode(moveAfter);
    _blocks.remove(block);
    _blocksInsertAfter(block, moveAfter);

    _animate.move(block.nodes, placeholder.parentNode,
      insertBefore: previousNode.nextNode);
  }

  void _blocksInsertAfter(Block block, Block insertAfter) {
    int index = -1;
    if(insertAfter != null) {
      index = _blocks.indexOf(insertAfter);
    }
    _blocks.insert(index + 1, block);
  }

  dom.Node _lastNode(Block insertAfter) {
    return insertAfter == null ? placeholder
    : insertAfter.nodes[insertAfter.nodes.length - 1];
  }
}
