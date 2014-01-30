part of angular.filter;

/**
 * Converts string to uppercase.
 *
 * Usage:
 *
 *     {{ uppercase_expression | uppercase }}
 */
@NgInjectableService()
@NgFilter(name:'uppercase')
class UppercaseFilter {
  call(String text) => text == null ? text : text.toUpperCase();
}
