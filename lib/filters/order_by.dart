part of angular.filter;

typedef dynamic Mapper(dynamic e);

/**
 * Orders the provided [Iterable] by supplied optional `expression` predicate.
 *
 * Example 1: Simple array
 *
 * Assume that you have an array on scope called `colors` and it has a list of
 * these strings – `['red', 'blue', 'green']`.  You might sort these in
 * ascending order this way:
 *
 *     Colors: <ul>
 *       <li ng-repeat='color in colors | orderBy'>{{color}}</li>
 *     </ul>
 *
 * That would result in:
 *
 *     <ul>
 *       <li>blue</li>
 *       <li>green</li>
 *       <li>red</li>
 *     <ul>
 *
 * To list the colors in descending order, you would pass in the 2nd optional
 * parameter, `descending`, and set it to `true`.  Since this requires passing
 * in the sort expression, and we want to sort by the color, we pass `color` for
 * the expression making it an identity transformer.
 *
 *     Colors: <ul>
 *       <li ng-repeat='color in colors | orderBy:color:true'>{{color}}</li>
 *     </ul>
 *
 * You may provide more complex expressions to sort non-primitives values or
 * if you want to sort on a decorated/transformed value.
 *
 * e.g. Support you have a list `users` that looks like this:
 *
 *     authors = [
 *       {firstName: 'Emily',   lastName: 'Bronte'},
 *       {firstName: 'Mark',    lastName: 'Twain'},
 *       {firstName: 'Jeffrey', lastName: 'Archer'},
 *       {firstName: 'Isaac',   lastName: 'Asimov'},
 *       {firstName: 'Oscar',   lastName: 'Wilde'},
 *     ];
 *
 * If you want to list the authors sorted by `lastName`, you would use
 *
 *     <li ng-repeat='author in authors | orderBy:lastName'>
 *       {{author.lastName}}, {{author.firstName
 *     </li>
 *
 * To reverse the order when you have an expression, you have two choices.  You
 * may either pass in an optional parameter following the expression that
 * evaluates to true for descending / false for ascending OR you may prefix the
 * expression with a '-' to indicate reversing.  If you do both (i.e. prefix the
 * expression with a '-' and pass in `true` for the optional `descending`
 * parameter), they will cancel each other out and you'll get the list in
 * ascending order.
 *
 *     <!-- Two reversals result in ascending order -->
 *     <li ng-repeat='author in authors | orderBy:-lastName:true'>
 *       {{author.lastName}}, {{author.firstName
 *     </li>
 */
@NgFilter(name:'orderBy')
class OrderByFilter {
  Injector _injector;
  Parser _parser;

  OrderByFilter(Injector this._injector, Parser this._parser);

  static _nop(e) => e;
  static bool _isNonZero(int n) => (n != 0);
  static int _returnZero() => 0;
  static int _defaultComparator(a, b) => Comparable.compare(a, b);
  static int _reverseComparator(a, b) => _defaultComparator(b, a);

  static int _compareLists(List a, List b, List<Comparator> comparators) {
    return new Iterable.generate(a.length, (i) => comparators[i](a[i], b[i]))
        .firstWhere(_isNonZero, orElse: _returnZero);
  }

  static List _sorted(
      List items, List<Mapper> mappers, List<Comparator> comparators, bool descending) {
    // Do the standard decorate-sort-undecorate aka Schwartzian dance since Dart
    // doesn't support a key/transform parameter to sort().
    // Ref: http://en.wikipedia.org/wiki/Schwartzian_transform
    mapper(e) => new List.generate(mappers.length, (i) => mappers[i](e));
    List decorated = items.map(mapper).toList(growable: false);
    List<int> indices = new Iterable.generate(decorated.length, (i) => i).toList(growable: false);
    var comparator = (i, j) => _compareLists(decorated[i], decorated[j], comparators);
    indices.sort((descending) ? (i, j) => comparator(j, i) : comparator);
    return indices.map((i) => items[i]).toList(growable: false);
  }

  /**
   * expression: String/Function or Array of String/Function.
   */
  List call(List items, [var expression, bool descending=false]) {
    Scope scope = _injector.get(Scope);
    List expressions = null;
    if (expression is String || expression is Mapper) {
      expressions = [expression];
    } else if (expression is List) {
      expressions = expression as List;
    }
    if (expressions == null || expressions.length == 0) {
      // AngularJS behavior.  You must have an expression to get any work done.
      return items;
    }
    int numExpressions = expressions.length;
    List<Mapper> mappers = new List(numExpressions);
    List<Comparator> comparators = new List<Comparator>(numExpressions);
    for (int i = 0; i < numExpressions; i++) {
      expression = expressions[i];
      if (expression is String) {
        var strExp = expression as String;
        var desc = false;
        if (strExp.startsWith('-') || strExp.startsWith('+')) {
          desc = strExp.startsWith('-');
          strExp = strExp.substring(1);
        }
        comparators[i] = desc ? _reverseComparator : _defaultComparator;
        if (strExp == '') {
          mappers[i] = _nop;
        } else {
          var parsed = _parser(strExp);
          mappers[i] = (e) => parsed.eval(scope, e);
        }
      } else if (expression is Mapper) {
        mappers[i] = (expression as Mapper);
        comparators[i] = _defaultComparator;
      }
    }
    return _sorted(items, mappers, comparators, descending);
  }
}
