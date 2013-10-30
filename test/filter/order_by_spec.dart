library order_by_spec;

import '../_specs.dart';


class Name {
  String firstName;
  String lastName;
  Name({String this.firstName, String this.lastName});
  operator ==(Name other) =>
      (firstName == other.firstName && lastName == other.lastName);
  String toString() => 'Name(firstName: $firstName, lastName: $lastName)';
}


main() {
  describe('orderBy filter', () {
    var Emily___Bronte = new Name(firstName: 'Emily', lastName: 'Bronte'),
        Mark____Twain = {'firstName': 'Mark',    'lastName': 'Twain'},
        Jeffrey_Archer = {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        Isaac___Asimov = new Name(firstName: 'Isaac', lastName: 'Asimov'),
        Oscar___Wilde = {'firstName': 'Oscar',   'lastName': 'Wilde'};
    beforeEach(() => inject((Scope scope) {
      scope['authors'] = [
        Emily___Bronte,
        Mark____Twain,
        Jeffrey_Archer,
        Isaac___Asimov,
        Oscar___Wilde,
      ];
      scope['items'] = [
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
      ];
    }));

    it('should pass through null list when input list is null', inject((Scope scope) {
      var list = null;
      expect(scope.$eval('list | orderBy:"foo"')).toBe(null);
    }));

    it('should pass through argument when expression is null', inject((Scope scope) {
      var list = scope['list'] = [1, 3, 2];
      expect(scope.$eval('list | orderBy:thisIsNull')).toBe(list);
    }));

    it('should sort with "empty" expression using default comparator', inject((Scope scope) {
      scope['list'] = [1, 3, 2];
      expect(scope.$eval('list | orderBy:""')).toEqual([1, 2, 3]);
      expect(scope.$eval('list | orderBy:"+"')).toEqual([1, 2, 3]);
      expect(scope.$eval('list | orderBy:"-"')).toEqual([3, 2, 1]);
    }));

    it('should sort by expression', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"firstName"')).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(scope.$eval('authors | orderBy:"lastName"')).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);

      scope['sortKey'] = 'firstName';
      expect(scope.$eval('authors | orderBy:sortKey')).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);

    }));

    it('should reverse order when passed the additional descending param', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"lastName":true')).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    }));

    it('should reverse order when expression is prefixed with "-"', inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"-lastName"')).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    }));

    it('should NOT reverse order when BOTH expression is prefixed with "-" AND additional parameter also asks reversal',
       inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"-lastName":true')).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    }));

    it('should allow a "+" prefix on the expression that should be a nop (ascending order)',
       inject((Scope scope) {
      expect(scope.$eval('authors | orderBy:"+lastName"')).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(scope.$eval('authors | orderBy:"+lastName":false')).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(scope.$eval('authors | orderBy:"+lastName":true')).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
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
      scope['func'] = (e) => (e is Name) ? e.lastName : e['lastName'];
      expect(scope.$eval('authors | orderBy:func')).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    }));

  });
}
