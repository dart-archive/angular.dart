part of angular;

@NgDirective(
    transclude: true,
    selector:'[ng-controller]',
    map: const {'.': '@.expression'})
class NgControllerAttrDirective {
  static RegExp CTRL_REGEXP = new RegExp(r'^(\S+)(\s+as\s+(\w+))?$');

  BoundBlockFactory boundBlockFactory;
  BlockHole blockHole;
  Injector injector;
  Scope scope;

  Symbol ctrlSymbol;
  String alias;

  set expression(value) {
    var match = CTRL_REGEXP.firstMatch(value);

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

  NgControllerAttrDirective(BoundBlockFactory this.boundBlockFactory,
                            BlockHole this.blockHole,
                            Injector this.injector,
                            Scope this.scope);
}
