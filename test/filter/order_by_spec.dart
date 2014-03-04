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
    beforeEach(() => inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['authors'] = [
        Emily___Bronte,
        Mark____Twain,
        Jeffrey_Archer,
        Isaac___Asimov,
        Oscar___Wilde,
      ];
      scope.context['items'] = [
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
      ];
    }));

    it('should pass through null list when input list is null', inject((Scope scope, Parser parse, FilterMap filters) {
      var list = null;
      expect(parse('list | orderBy:"foo"').eval(scope.context, filters)).toBe(null);
    }));

    it('should pass through argument when expression is null', inject((Scope scope, Parser parse, FilterMap filters) {
      var list = scope.context['list'] = [1, 3, 2];
      expect(parse('list | orderBy:thisIsNull').eval(scope.context, filters)).toBe(list);
    }));

    it('should sort with "empty" expression using default comparator', inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['list'] = [1, 3, 2];
      expect(parse('list | orderBy:""').eval(scope.context, filters)).toEqual([1, 2, 3]);
      expect(parse('list | orderBy:"+"').eval(scope.context, filters)).toEqual([1, 2, 3]);
      expect(parse('list | orderBy:"-"').eval(scope.context, filters)).toEqual([3, 2, 1]);
    }));

    it('should sort by expression', inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('authors | orderBy:"firstName"').eval(scope.context, filters)).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"lastName"').eval(scope.context, filters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);

      scope.context['sortKey'] = 'firstName';
      expect(parse('authors | orderBy:sortKey').eval(scope.context, filters)).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);

    }));

    it('should reverse order when passed the additional descending param', inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('authors | orderBy:"lastName":true').eval(scope.context, filters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    }));

    it('should reverse order when expression is prefixed with "-"', inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('authors | orderBy:"-lastName"').eval(scope.context, filters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    }));

    it('should NOT reverse order when BOTH expression is prefixed with "-" AND additional parameter also asks reversal',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('authors | orderBy:"-lastName":true').eval(scope.context, filters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    }));

    it('should allow a "+" prefix on the expression that should be a nop (ascending order)',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('authors | orderBy:"+lastName"').eval(scope.context, filters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"+lastName":false').eval(scope.context, filters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"+lastName":true').eval(scope.context, filters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    }));

    it('should support an array of expressions',
       inject((Scope scope, Parser parse, FilterMap filters) {
      expect(parse('items | orderBy:["-a", "-b"]').eval(scope.context, filters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
      ]);
      expect(parse('items | orderBy:["-b", "-a"]').eval(scope.context, filters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      expect(parse('items | orderBy:["a", "-b"]').eval(scope.context, filters)).toEqual([
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
      ]);
      expect(parse('items | orderBy:["a", "-b"]:true').eval(scope.context, filters)).toEqual([
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
      ]);
    }));

    it('should support function expressions',
       inject((Scope scope, Parser parse, FilterMap filters) {
      scope.context['func'] = (e) => -(e['a'] + e['b']);
      expect(parse('items | orderBy:[func, "a", "-b"]').eval(scope.context, filters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      scope.context['func'] = (e) => (e is Name) ? e.lastName : e['lastName'];
      expect(parse('authors | orderBy:func').eval(scope.context, filters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    }));

  });
}
