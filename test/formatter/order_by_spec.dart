library order_by_spec;

import '../_specs.dart';


class Name {
  String firstName;
  String lastName;
  Name({this.firstName, this.lastName});
  operator ==(Name other) =>
      (firstName == other.firstName && lastName == other.lastName);
  String toString() => 'Name(firstName: $firstName, lastName: $lastName)';
  int get hashCode => firstName.hashCode + lastName.hashCode;
}


main() {
  describe('orderBy formatter', () {
    var Emily___Bronte = new Name(firstName: 'Emily', lastName: 'Bronte'),
        Mark____Twain = {'firstName': 'Mark',    'lastName': 'Twain'},
        Jeffrey_Archer = {'firstName': 'Jeffrey', 'lastName': 'Archer'},
        Isaac___Asimov = new Name(firstName: 'Isaac', lastName: 'Asimov'),
        Oscar___Wilde = {'firstName': 'Oscar',   'lastName': 'Wilde'};
    beforeEach((Scope scope, Parser parse, FormatterMap formatters) {
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
    });

    it('should pass through null list when input list is null', (Scope scope, Parser parse, FormatterMap formatters) {
      var list = null;
      expect(parse('list | orderBy:"foo"').eval(scope.context, formatters)).toBe(null);
    });

    it('should pass through argument when expression is null', (Scope scope, Parser parse, FormatterMap formatters) {
      var list = scope.context['list'] = [1, 3, 2];
      expect(parse('list | orderBy:thisIsNull').eval(scope.context, formatters)).toBe(list);
    });

    it('should sort with "empty" expression using default comparator', (Scope scope, Parser parse, FormatterMap formatters) {
      scope.context['list'] = [1, 3, 2];
      expect(parse('list | orderBy:""').eval(scope.context, formatters)).toEqual([1, 2, 3]);
      expect(parse('list | orderBy:"+"').eval(scope.context, formatters)).toEqual([1, 2, 3]);
      expect(parse('list | orderBy:"-"').eval(scope.context, formatters)).toEqual([3, 2, 1]);
    });

    it('should sort by expression', (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('authors | orderBy:"firstName"').eval(scope.context, formatters)).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"lastName"').eval(scope.context, formatters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);

      scope.context['sortKey'] = 'firstName';
      expect(parse('authors | orderBy:sortKey').eval(scope.context, formatters)).toEqual([
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
        Mark____Twain,
        Oscar___Wilde,
      ]);

    });

    it('should reverse order when passed the additional descending param', (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('authors | orderBy:"lastName":true').eval(scope.context, formatters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    });

    it('should reverse order when expression is prefixed with "-"', (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('authors | orderBy:"-lastName"').eval(scope.context, formatters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    });

    it('should NOT reverse order when BOTH expression is prefixed with "-" AND additional parameter also asks reversal',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('authors | orderBy:"-lastName":true').eval(scope.context, formatters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    });

    it('should allow a "+" prefix on the expression that should be a nop (ascending order)',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('authors | orderBy:"+lastName"').eval(scope.context, formatters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"+lastName":false').eval(scope.context, formatters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
      expect(parse('authors | orderBy:"+lastName":true').eval(scope.context, formatters)).toEqual([
        Oscar___Wilde,
        Mark____Twain,
        Emily___Bronte,
        Isaac___Asimov,
        Jeffrey_Archer,
      ]);
    });

    it('should support an array of expressions',
       (Scope scope, Parser parse, FormatterMap formatters) {
      expect(parse('items | orderBy:["-a", "-b"]').eval(scope.context, formatters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
      ]);
      expect(parse('items | orderBy:["-b", "-a"]').eval(scope.context, formatters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      expect(parse('items | orderBy:["a", "-b"]').eval(scope.context, formatters)).toEqual([
        {'a': 10, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 20, 'b': 10},
      ]);
      expect(parse('items | orderBy:["a", "-b"]:true').eval(scope.context, formatters)).toEqual([
        {'a': 20, 'b': 10},
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 10},
        {'a': 10, 'b': 20},
      ]);
    });

    it('should support function expressions',
       (Scope scope, Parser parse, FormatterMap formatters) {
      scope.context['func'] = (e) => -(e['a'] + e['b']);
      expect(parse('items | orderBy:[func, "a", "-b"]').eval(scope.context, formatters)).toEqual([
        {'a': 20, 'b': 20},
        {'a': 10, 'b': 20},
        {'a': 20, 'b': 10},
        {'a': 10, 'b': 10},
      ]);
      scope.context['func'] = (e) => (e is Name) ? e.lastName : e['lastName'];
      expect(parse('authors | orderBy:func').eval(scope.context, formatters)).toEqual([
        Jeffrey_Archer,
        Isaac___Asimov,
        Emily___Bronte,
        Mark____Twain,
        Oscar___Wilde,
      ]);
    });

  });
}
