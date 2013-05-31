part of angular;

class NgRepeatAttrDirective  {
  static var $transclude = "element";

  String itemExpr, listExpr;
  ElementWrapper anchor;
  ElementWrapper cursor;
  BlockList blockList;

  NgRepeatAttrDirective(BlockListFactory blockListFactory,
                        BlockList this.blockList,
                        dom.Node node,
                        DirectiveValue value) {
    ASSERT(node != null);
    var splits = value.value.split(' in ');
    assert(splits.length == 2); // or not?
    itemExpr = splits[0];
    listExpr = splits[1];

    // TODO(deboer): There *must* be a better way...
    anchor = cursor = blockListFactory([node], {});
  }

  attach(Scope scope) {
    // TODO(deboer): huge hack. I can't update nicely the list yet.
    var lastListLen = 0;
    // should be watchprops
    scope.$watch(listExpr, (List value, _, __) {
      if (value.length == lastListLen) { return; }
      lastListLen = value.length;

      // List changed! Erase everything.
      while (anchor != cursor) {
        var blockToDelete = cursor;
        cursor = cursor.previous;
        blockToDelete.remove();
      }

      // for each value, create a child scope and call the compiler's linker
      // function.
      value.forEach((oneValue) {
        // TODO(deboer): child scopes!
        scope[itemExpr] = oneValue;
        var newBlock = blockList.newBlock()..attach(scope)..insertAfter(cursor);
        cursor = newBlock;
      });

    });
  }
}
