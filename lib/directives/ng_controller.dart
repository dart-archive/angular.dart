part of angular;

class NgControllerAttrDirective {
  static String $transclude = 'element';
  static RegExp CTRL_REGEXP = new RegExp(r'^(\S+)(\s+as\s+(\w+))?$');

  Symbol ctrlSymbol;
  String alias;
  Injector injector;
  BlockList blockList;

  NgControllerAttrDirective(DirectiveValue value, Injector this.injector, BlockList this.blockList) {
    var match = CTRL_REGEXP.firstMatch(value.value);

    ctrlSymbol = new Symbol(match.group(1) + 'Controller');
    alias = match.group(3);
  }

  attach(Scope scope) {
    var childScope = scope.$new();
    var module = new Module();
    module.value(Scope, childScope);

    // attach the child scope
    blockList.newBlock()..attach(childScope)..insertAfter(blockList);

    // instantiate the controller
    var controller = injector.createChild([module], [ctrlSymbol]).getBySymbol(ctrlSymbol);

    // publish the controller into the scope
    if (alias != null) {
      childScope[alias] = controller;
    }
  }
}
