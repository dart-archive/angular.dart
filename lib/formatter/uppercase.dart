part of angular.formatter_internal;

/**
 * Converts string to uppercase.
 *
 * Usage:
 *
 *     {{ uppercase_expression | uppercase }}
 */
@Formatter(name:'uppercase')
class Uppercase implements Function {
  call(String text) => text == null ? text : text.toUpperCase();
}
