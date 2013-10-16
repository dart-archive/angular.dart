library limit_to_spec;

import '../_specs.dart';

main() {
  describe('orderBy filter', () {
    beforeEach(() => inject((Scope scope) {
      scope['list'] = 'abcdefgh'.split('');
      scope['string'] = 'tuvwxyz';
    }));

    it('should return the first X items when X is positive', inject((Scope scope) {
      scope['limit'] = 3;
      expect(scope.$eval('list | limitTo: 3')).toEqual(['a', 'b', 'c']);
      expect(scope.$eval('list | limitTo: limit')).toEqual(['a', 'b', 'c']);
      expect(scope.$eval('string | limitTo: 3')).toEqual('tuv');
      expect(scope.$eval('string | limitTo: limit')).toEqual('tuv');
    }));

    it('should return the last X items when X is negative', inject((Scope scope) {
      scope['limit'] = 3;
      expect(scope.$eval('list | limitTo: -3')).toEqual(['f', 'g', 'h']);
      expect(scope.$eval('list | limitTo: -limit')).toEqual(['f', 'g', 'h']);
      expect(scope.$eval('string | limitTo: -3')).toEqual('xyz');
      expect(scope.$eval('string | limitTo: -limit')).toEqual('xyz');
    }));

    it('should return an null when limiting null list',
       inject((Scope scope) {
      expect(scope.$eval('null | limitTo: 1')).toEqual(null);
      expect(scope.$eval('thisIsNull | limitTo: 1')).toEqual(null);
    }));

    it('should return an empty array when X cannot be parsed',
       inject((Scope scope) {
      expect(scope.$eval('list | limitTo: bogus')).toEqual([]);
      expect(scope.$eval('string | limitTo: null')).toEqual([]);
      expect(scope.$eval('string | limitTo: thisIsNull')).toEqual([]);
    }));

    it('should return a copy of input array if X is exceeds array length',
       inject((Scope scope) {
      expect(scope.$eval('list | limitTo: 20')).toEqual(scope['list']);
      expect(scope.$eval('list | limitTo: -20')).toEqual(scope['list']);
      expect(scope.$eval('list | limitTo: 20')).not.toBe(scope['list']);
    }));

    it('should return the entire string if X exceeds input length',
       inject((Scope scope) {
      expect(scope.$eval('string | limitTo: 20')).toEqual(scope['string']);
      expect(scope.$eval('string | limitTo: -20')).toEqual(scope['string']);
    }));

  });
}
