part of angular.filter;

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

  static List sorted(List items, var mapper, bool descending) {
    // Do the standard decorate-sort-undecorate aka Schwartzian dance since Dart
    // doesn't support a key/transform parameter to sort().
    // Ref: http://en.wikipedia.org/wiki/Schwartzian_transform
    List decorated = items.map(mapper).toList(growable: false);
    List<int> indices = new Iterable.generate(
        decorated.length, (i) => i).toList(growable: false);
    var comparator = (i, j) => Comparable.compare(decorated[i], decorated[j]);
    indices.sort((descending) ? (i, j) => comparator(j, i) : comparator);
    List sorted = indices.map((i) => items[i]).toList(growable: false);
    return sorted;
  }

  List call(List items, [String expression, bool descending=false]) {
    Scope scope = _injector.get(Scope);
    var mapper = (e) => e;
    if (expression != null) {
      if (expression.startsWith('-') || expression.startsWith('+')) {
        if (expression.startsWith('-')) {
          descending = !descending;
        }
        expression = expression.substring(1);
      }
      if (expression != '') {
        var parsed = _parser(expression);
        mapper = (e) => parsed.eval(scope, e);
      }
    }
    return sorted(items, mapper, descending);
  }
}
