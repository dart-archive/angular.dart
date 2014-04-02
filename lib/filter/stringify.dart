part of angular.filter;

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
@NgFilter(name:'stringify')
class Stringify implements Function {
  String call(obj) => obj == null ? "" : obj.toString();
}
