part of angular.formatter_internal;

/**
 * Converts a JavaScript object into a JSON string.
 *
 * This formatter is mostly useful for debugging.
 *
 * Usage:
 *
 *     {{ json_expression | json }}
 */
@Formatter(name:'json')
class Json implements Function {
  String call(jsonObj) => JSON.encode(jsonObj);
}
