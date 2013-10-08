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
    }));

    it('should sort primitives without an expression', inject((Scope scope) {
      expect(scope.$eval('[1, 3, 2] | orderBy')).toEqual([1, 2, 3]);
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

  });
}
