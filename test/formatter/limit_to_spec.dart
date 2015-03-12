library limit_to_spec;

import '../_specs.dart';

main() {
  describe('orderBy formatter', () {
    beforeEach((Scope scope, Parser parse, FormatterMap formatters) {
      scope.context['list'] = 'abcdefgh'.split('');
      scope.context['string'] = 'tuvwxyz';
    });

    it('should return the first X items when X is positive', (Scope scope, Parser parse, FormatterMap formatters) {
      scope.context['limit'] = 3;
      expect(parse('list | limitTo: 3').eval(scope.context, formatters)).toEqual(['a', 'b', 'c']);
      expect(parse('list | limitTo: limit').eval(scope.context, formatters)).toEqual(['a', 'b', 'c']);
      expect(parse('string | limitTo: 3').eval(scope.context, formatters)).toEqual('tuv');
      expect(parse('string | limitTo: limit').eval(scope.context, formatters)).toEqual('tuv');
    });

    it('should return the last X items when X is negative', (Scope scope, Parser parse, FormatterMap formatters) {
      scope.context['limit'] = 3;
      expect(parse('list | limitTo: -3').eval(scope.context, formatters)).toEqual(['f', 'g', 'h']);
      expect(parse('list | limitTo: -limit').eval(scope.context, formatters)).toEqual(['f', 'g', 'h']);
      expect(parse('string | limitTo: -3').eval(scope.context, formatters)).toEqual('xyz');
      expect(parse('string | limitTo: -limit').eval(scope.context, formatters)).toEqual('xyz');
    });

    it('should return an null when limiting null list',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('null | limitTo: 1').eval(scope.context, formatters)).toEqual(null);
      expect(parse('thisIsNull | limitTo: 1').eval(scope.context, formatters)).toEqual(null);
    });

    it('should return an empty array when X cannot be parsed',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('list | limitTo: bogus').eval(scope.context, formatters)).toEqual([]);
      expect(parse('string | limitTo: null').eval(scope.context, formatters)).toEqual([]);
      expect(parse('string | limitTo: thisIsNull').eval(scope.context, formatters)).toEqual([]);
    });

    it('should return a copy of input array if X is exceeds array length',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('list | limitTo: 20').eval(scope.context, formatters)).toEqual(scope.context['list']);
      expect(parse('list | limitTo: -20').eval(scope.context, formatters)).toEqual(scope.context['list']);
      expect(parse('list | limitTo: 20').eval(scope.context, formatters)).not.toBe(scope.context['list']);
    });

    it('should return the entire string if X exceeds input length',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('string | limitTo: 20').eval(scope.context, formatters)).toEqual(scope.context['string']);
      expect(parse('string | limitTo: -20').eval(scope.context, formatters)).toEqual(scope.context['string']);
    });

  });
}
