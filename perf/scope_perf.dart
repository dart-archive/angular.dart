import "../test/_specs.dart";
import "_perf.dart";

main() => describe('scope', () {
  var scope;
  beforeEach(inject((Scope _scope){
    scope = _scope;
  }));

  time('noop', () {});

  time('empty scope \$digest()', () {
    scope.$digest();
  });

  describe('primitives', () {
    beforeEach(() {
      scope.a = {
          "num": 1,
          "str": 'abc',
          "obj": {}
      };

      for(var i = 0; i < 1000; i++ ) {
        scope.$watch('a.num', () => null);
        scope.$watch('a.str', () => null);
        scope.$watch('a.obj', () => null);
      }
    });

    ttime('3000 watchers on scope', () {
      scope.$digest();
    });

  });
});
