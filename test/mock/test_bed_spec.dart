library angular.mock.test_bed_spec;

import '../_specs.dart';

void main() {
  describe('test bed', () {
    TestBed _;
    Compiler compile;
    Injector injector;
    Scope rootScope;

    beforeEachModule((Module module) {
      module..bind(MyTestBedDirective);
      return (TestBed tb) => _ = tb;
    });

    it('should allow for a scope-based compile', () {

      inject((Scope scope) {
        Scope childScope = scope.createChild({});
        var div = _.compile('<div my-directive></div>', scope: childScope);
        var injector = ngInjector(div);
        childScope.destroy();
        expect(injector.get(MyTestBedDirective).destroyed).toBe(true);
      });
    });

  });
}

@Decorator(selector: '[my-directive]')
class MyTestBedDirective {
  bool destroyed = false;

  MyTestBedDirective(Scope scope) {
    scope.on(ScopeEvent.DESTROY).listen((_) {
      destroyed = true;
    });
  }
}
