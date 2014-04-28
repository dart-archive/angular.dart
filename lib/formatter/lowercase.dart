part of angular.formatter_internal;

/**
 * Converts string to lowercase.
 *
 * Usage:
 *
 *     {{ lowercase_expression | lowercase }}
 */
@Formatter(name:'lowercase')
class Lowercase implements Function {
  call(String text) => text == null ? text : text.toLowerCase();
}
