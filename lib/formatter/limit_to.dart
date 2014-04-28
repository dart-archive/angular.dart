part of angular.formatter_internal;

/**
 * Creates a new List or String containing only a prefix/suffix of the
 * elements as specified by the `limit` parameter.
 *
 * When operating on a List, the returned list is always a copy even when all
 * the elements are being returned.
 *
 * When the `limit` expression evaluates to a positive integer, `limit` items
 * from the beginning of the List/String are returned.  When `limit` evaluates
 * to a negative integer, `|limit|` items from the end of the List/String are
 * returned.  If `|limit|` is larger than the size of the List/String, then the
 * entire List/String is returned.  In the case of a List, a copy of the list is
 * returned.
 *
 * If the `limit` expression evaluates to a null or non-integer, then an empty
 * list is returned.  If the input is a null List/String, a null is returned.
 *
 * Example:
 *
 * - `{{ 'abcdefghij' | limitTo: 4 }}` → `'abcd'`
 * - `{{ 'abcdefghij' | limitTo: -4 }}` → `'ghij'`
 * - `{{ 'abcdefghij' | limitTo: -100 }}` → `'abcdefghij'`
 *
 * <br>
 *
 * This [ng-repeat] directive:
 *
 *     <li ng-repeat="i in 'abcdefghij' | limitTo:-2">{{i}}</li>
 *
 * results in
 *
 *     <li>i</li>
 *     <li>j</li>
 */
@Formatter(name:'limitTo')
class LimitTo implements Function {
  Injector _injector;

  LimitTo(this._injector);

  dynamic call(dynamic items, [int limit]) {
    if (items == null) return null;
    if (limit == null) return const[];
    if (items is! List && items is! String) return items;
    int i = 0, j = items.length;
    if (limit > -1) {
      j = (limit > j) ? j : limit;
    } else {
      i = j + limit;
      if (i < 0) i = 0;
    }
    return items is String ?
        (items as String).substring(i, j) :
        (items as List).getRange(i, j).toList(growable: false);
  }
}
