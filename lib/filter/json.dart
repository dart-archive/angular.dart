part of angular.filter;

/**
 * Allows you to convert a JavaScript object into JSON string. This filter is
 * mostly useful for debugging.
 *
 * Usage:
 *
 *     {{ json_expression | json }}
 */
@NgFilter(name:'json')
class Json implements Function {
  String call(jsonObj) => JSON.encode(jsonObj);
}
