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

    it('should allow for a scope-based compile', (Scope scope) {
      Scope childScope = scope.createChild({});

      _.compile('<div my-directive probe="i"></div>', scope: childScope);

      Probe probe = _.rootScope.context['i'];
      var directiveInst = probe.directive(MyTestBedDirective);

      childScope.destroy();

      expect(directiveInst.destroyed).toBe(true);
    });

    it('should handle whitespace cleanly', () {
      var root = _.compile('''
        <div>
          <h1
             attr="Hi">
          </h1>
        </div>
      <span  
       attr2="Bye"

      ></span>
      ''');

      expect(root).toBeAnInstanceOf(DivElement);
      expect(_.rootElements[1]).toBeAnInstanceOf(SpanElement);
      expect(_.rootElements.length).toBe(2);
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
