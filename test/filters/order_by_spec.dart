library order_by_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('orderBy filter', () {
    beforeEach(() => inject((Scope scope) {
      scope['authors'] = [
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ];
      scope['items'] = [
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
      ];
    }));

    it('should pass through argument without an expression', inject((Scope scope) {
      var list = scope['list'] = [1, 2, 3];
      expect(scope.$eval('list | orderBy')).toBe(list);
    }));

    it('should sort by expression', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"firstName"')).toEqual([
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);
      expect(scope.$eval('authors | orderBy:"lastName"')).toEqual([
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);

      scope['sortKey'] = 'firstName';
      expect(scope.$eval('authors | orderBy:sortKey')).toEqual([
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);

    }));

    it('should reverse order when passed the additional descending param', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"lastName":true')).toEqual([
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
      ]);
    }));

    it('should reverse order when expression is prefixed with "-"', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"-lastName"')).toEqual([
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
      ]);
    }));

    it('should NOT reverse order when BOTH expression is prefixed with "-" AND additional parameter also asks reversal',
       inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"-lastName":true')).toEqual([
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);
    }));

    it('should allow a "+" prefix on the expression that should be a nop (ascending order)',
       inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"+lastName"')).toEqual([
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);
      expect(scope.$eval('authors | orderBy:"+lastName":false')).toEqual([
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);
      expect(scope.$eval('authors | orderBy:"+lastName":true')).toEqual([
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
      ]);
    }));

    it('should support an array of expressions',
       inject((Scope scope) {
      expect(scope.$eval('items | orderBy:["-a", "-b"]')).toEqual([
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
      ]);
      expect(scope.$eval('items | orderBy:["-b", "-a"]')).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      expect(scope.$eval('items | orderBy:["a", "-b"]')).toEqual([
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
      ]);
      expect(scope.$eval('items | orderBy:["a", "-b"]:true')).toEqual([
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
      ]);
    }));

    it('should support function expressions',
       inject((Scope scope) {
      scope['func'] = (e) => -(e['a'] + e['b']);
      expect(scope.$eval('items | orderBy:[func, "a", "-b"]')).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      scope['func'] = (e) => e['lastName'];
      expect(scope.$eval('authors | orderBy:func')).toEqual([
        {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        {'firstName': 'Isaac',   'lastName': 'Asimov'},
        {'firstName': 'Emily',   'lastName': 'Bronte'},
        {'firstName': 'Mark',    'lastName': 'Twain'},
        {'firstName': 'Oscar',   'lastName': 'Wilde'},
      ]);
    }));

  });
}
