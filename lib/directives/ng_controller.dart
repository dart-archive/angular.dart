part of angular;

class NgControllerAttrDirective {
  static String $transclude = 'element';
  static RegExp CTRL_REGEXP = new RegExp(r'^(\S+)(\s+as\s+(\w+))?$');

  Symbol ctrlSymbol;
  String alias;
  Injector injector;
  BlockList blockList;

  NgControllerAttrDirective(NodeAttrs attrs, Injector this.injector, BlockList this.blockList, Scope scope) {
    var match = CTRL_REGEXP.firstMatch(attrs[this]);

    ctrlSymbol = new Symbol(match.group(1) + 'Controller');
    alias = match.group(3);

    scope.$evalAsync(() {
      var childScope = scope.$new();

      // attach the child scope
      blockList.newBlock(childScope).insertAfter(blockList);

      // instantiate the controller
      var controller = injector.
      createChild([new ScopeModule(childScope)], [ctrlSymbol]).
      getBySymbol(ctrlSymbol);

      // publish the controller into the scope
      if (alias != null) {
        childScope[alias] = controller;
      }
    });
  }
}
