part of angular.formatter_internal;

/**
 * Allows you to convert an object to a string.
 *
 * Null object are converted to an empty string.
 *
 *
 * Usage:
 *
 *     {{ expression | stringify }}
 */
@Formatter(name:'stringify')
class Stringify implements Function {
  String call(obj) => obj == null ? "" : obj.toString();
}
