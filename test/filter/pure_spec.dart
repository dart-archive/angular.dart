library pure_spec;

import '../_specs.dart';

void main() {
  describe('pure filters', () {
    beforeEach((Scope scope, Parser parse, FilterMap filters) {
      scope.context['string'] = 'abc';
      scope.context['list'] = 'abc'.split('');
      scope.context['map'] = { 'a': 1, 'b': 2, 'c': 3 };
    });

    // Note that the `observe` filter is tested in [scope_spec.dart].

    it('should return the value of the named field', 
        (Scope scope, Parser parse, FilterMap filters) {
      expect(parse("list | field:'reversed'").eval(scope.context, filters)
          ).toEqual(['c', 'b', 'a']);
      expect(parse("map | field:'keys'").eval(scope.context, filters)).toEqual(
          ['a', 'b', 'c']);
      expect(parse("map | field:'values'").eval(scope.context, filters)
          ).toEqual([1, 2, 3]);
    });

    it('should return method call result', 
        (Scope scope, Parser parse, FilterMap filters) {
      expect(parse("list | method:'toString'").eval(scope.context, filters)
          ).toEqual('[a, b, c]');
      expect(parse("list | method:'join':['']").eval(scope.context, filters)
          ).toEqual('abc');
      expect(parse("string | method:'split':['']").eval(scope.context, filters)
          ).toEqual(['a', 'b', 'c']);
    });

    it('should return method call result using namedArgs', 
        (Scope scope, Parser parse, FilterMap filters) {
      scope.context['isB'] = (s) => s == 'b';
      scope.context['zero'] = () => 0;

      // Test for no positional args but with named args.
      expect(parse("list | method:'toList':{'growable':false}").eval(
          scope.context, filters)).toEqual(['a', 'b', 'c']);

      // Test for both positional and named args.
      expect(parse("list | method:'firstWhere':[isB]:{'orElse':zero}").eval(
          scope.context, filters)).toEqual('b');
    });
  });
}
