part of angular;


class NgIfAttrDirective {
  static String $transclude = 'element';

  String expression;
  dom.Element node;
  Injector injector;
  BlockList blockList;

  NgIfAttrDirective(DirectiveValue value, Injector this.injector, BlockList this.blockList, dom.Node this.node) {
    expression = value.value;
  }

  attach(Scope scope) {
    // TODO(vojta): detach the scope when block is removed
    var childScope = scope.$new();
    var block = blockList.newBlock();
    var isInserted = false;

    block.attach(childScope);

    scope.$watch(expression, (value, _, __) {
      // TODO(vojta): ignore changes like null -> false
      if (value != null && toBool(value)) {
        if (!isInserted) {
          block.insertAfter(blockList);
          isInserted = true;
        }
      } else {
        if (isInserted) {
          block.remove();
          isInserted = false;
        }
      }
    });
  }
}
