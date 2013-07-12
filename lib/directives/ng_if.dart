part of angular;


class NgIfAttrDirective {
  static var $priority = 100;
  static String $transclude = 'element';

  NgIfAttrDirective(NodeAttrs attrs, Injector injector, BlockList blockList, dom.Node node, Scope scope) {
    var _block;
    block() {
      if (_block != null) return _block;
      var childScope = scope.$new();
      _block = blockList.newBlock(childScope);
      return _block;
    }
    var isInserted = false;

    scope.$watch(attrs[this], (value) {
      // TODO(vojta): ignore changes like null -> false
      if (value != null && toBool(value)) {
        if (!isInserted) {
          block().insertAfter(blockList);
          isInserted = true;
        }
      } else {
        if (isInserted) {
          block().remove();
          isInserted = false;
        }
      }
    });
  }
}
