part of angular;

@NgDirective(transclude: '.')
class NgControllerAttrDirective {
  static RegExp CTRL_REGEXP = new RegExp(r'^(\S+)(\s+as\s+(\w+))?$');

  Symbol ctrlSymbol;
  String alias;

  NgControllerAttrDirective(BoundBlockFactory boundBlockFactory,
                            BlockHole blockHole,
                            Injector injector,
                            NodeAttrs attrs, Scope scope) {
    var match = CTRL_REGEXP.firstMatch(attrs[this]);

    ctrlSymbol = new Symbol(match.group(1) + 'Controller');
    alias = match.group(3);

    scope.$evalAsync(() {
      var childScope = scope.$new();

      // attach the child scope
      boundBlockFactory(childScope).insertAfter(blockHole);

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
