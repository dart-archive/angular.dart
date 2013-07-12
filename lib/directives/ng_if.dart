part of angular;


class NgIfAttrDirective {
  static var $priority = 100;
  static String $transclude = 'element';

  NgIfAttrDirective(NodeAttrs attrs, Injector injector, BlockList blockList, dom.Node node, Scope scope) {
    var childScope = scope.$new();
    var block = blockList.newBlock(childScope);
    var isInserted = false;

    scope.$watch(attrs[this], (value) {
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
