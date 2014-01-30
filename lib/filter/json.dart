part of angular.filter;

/**
 * Allows you to convert a JavaScript object into JSON string. This filter is
 * mostly useful for debugging.
 *
 * Usage:
 *
 *     {{ json_expression | json }}
 */
@NgInjectableService()
@NgFilter(name:'json')
class JsonFilter {
  call(text) => JSON.encode(text);
}
