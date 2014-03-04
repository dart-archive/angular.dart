library limit_to_spec;

import '../_specs.dart';

main() {
  describe('orderBy filter', () {
    beforeEach(() => inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['list'] = 'abcdefgh'.split('');
      scope.context['string'] = 'tuvwxyz';
    }));

    it('should return the first X items when X is positive', inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['limit'] = 3;
      expect(parse('list | limitTo: 3').eval(scope.context, filters)).toEqual(['a', 'b', 'c']);
      expect(parse('list | limitTo: limit').eval(scope.context, filters)).toEqual(['a', 'b', 'c']);
      expect(parse('string | limitTo: 3').eval(scope.context, filters)).toEqual('tuv');
      expect(parse('string | limitTo: limit').eval(scope.context, filters)).toEqual('tuv');
    }));

    it('should return the last X items when X is negative', inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['limit'] = 3;
      expect(parse('list | limitTo: -3').eval(scope.context, filters)).toEqual(['f', 'g', 'h']);
      expect(parse('list | limitTo: -limit').eval(scope.context, filters)).toEqual(['f', 'g', 'h']);
      expect(parse('string | limitTo: -3').eval(scope.context, filters)).toEqual('xyz');
      expect(parse('string | limitTo: -limit').eval(scope.context, filters)).toEqual('xyz');
    }));

    it('should return an null when limiting null list',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('null | limitTo: 1').eval(scope.context, filters)).toEqual(null);
      expect(parse('thisIsNull | limitTo: 1').eval(scope.context, filters)).toEqual(null);
    }));

    it('should return an empty array when X cannot be parsed',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('list | limitTo: bogus').eval(scope.context, filters)).toEqual([]);
      expect(parse('string | limitTo: null').eval(scope.context, filters)).toEqual([]);
      expect(parse('string | limitTo: thisIsNull').eval(scope.context, filters)).toEqual([]);
    }));

    it('should return a copy of input array if X is exceeds array length',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('list | limitTo: 20').eval(scope.context, filters)).toEqual(scope.context['list']);
      expect(parse('list | limitTo: -20').eval(scope.context, filters)).toEqual(scope.context['list']);
      expect(parse('list | limitTo: 20').eval(scope.context, filters)).not.toBe(scope.context['list']);
    }));

    it('should return the entire string if X exceeds input length',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('string | limitTo: 20').eval(scope.context, filters)).toEqual(scope.context['string']);
      expect(parse('string | limitTo: -20').eval(scope.context, filters)).toEqual(scope.context['string']);
    }));

  });
}
