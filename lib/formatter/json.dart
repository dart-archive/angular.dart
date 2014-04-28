part of angular.formatter_internal;

/**
 * Allows you to convert a JavaScript object into JSON string. This formatter is
 * mostly useful for debugging.
 *
 * Usage:
 *
 *     {{ json_expression | json }}
 */
@Formatter(name:'json')
class Json implements Function {
  String call(jsonObj) => JSON.encode(jsonObj);
}
