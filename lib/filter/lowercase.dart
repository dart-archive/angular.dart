part of angular.filter;

/**
 * Converts string to lowercase.
 *
 * Usage:
 *
 *     {{ lowercase_expression | lowercase }}
 */
@NgInjectableService()
@NgFilter(name:'lowercase')
class LowercaseFilter {
  call(String text) => text == null ? text : text.toLowerCase();
}
