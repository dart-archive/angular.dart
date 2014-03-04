part of angular.core;

class Interpolation {
  final String template;
  final List<String> seperators;
  final List<String> expressions;
  Function setter = (_) => _;

  Interpolation(this.template, this.seperators, this.expressions);

  String call(List parts, [_]) {
    if (parts == null) return seperators.join('');
    var str = [];
    for (var i = 0; i < parts.length; i++) {
      str.add(seperators[i]);
      var value = parts[i];
      str.add(value == null ? '' : '$value');
    }
    str.add(seperators.last);
    return setter(str.join(''));
  }
}

/**
 * Compiles a string with markup into an interpolation function. This service
 * is used by the HTML [Compiler] service for data binding.
 *
 *
 *     var $interpolate = ...; // injected
 *     var exp = $interpolate('Hello {{name}}!');
 *     expect(exp({name:'Angular'}).toEqual('Hello Angular!');
 */
@NgInjectableService()
class Interpolate {
  final Parser _parse;

  Interpolate(this._parse);

  /**
   * Compiles markup text into interpolation function.
   *
   * - `text`: The markup text to interpolate in form `foo {{expr}} bar`.
   * - `mustHaveExpression`: if set to true then the interpolation string must
   *      have embedded expression in order to return an interpolation function.
   *      Strings with no embedded expression will return null for the
   *      interpolation function.
   * - `startSymbol`: The symbol to start interpolation. '{{' by default.
   * - `endSymbol`: The symbol to end interpolation. '}}' by default.
   */
  Interpolation call(String template, [bool mustHaveExpression = false,
      String startSymbol = '{{', String endSymbol = '}}']) {
    int startSymbolLength = startSymbol.length;
    int endSymbolLength = endSymbol.length;
    int startIndex;
    int endIndex;
    int index = 0;
    int length = template.length;
    bool hasInterpolation = false;
    bool shouldAddSeparator = true;
    String exp;
    List<String> separators = [];
    List<String> expressions = [];

    while(index < length) {
      if ( ((startIndex = template.indexOf(startSymbol, index)) != -1) &&
           ((endIndex = template.indexOf(endSymbol, startIndex + startSymbolLength)) != -1) ) {
        separators.add(template.substring(index, startIndex));
        exp = template.substring(startIndex + startSymbolLength, endIndex);
        expressions.add(exp);
        index = endIndex + endSymbolLength;
        hasInterpolation = true;
      } else {
        // we did not find anything, so we have to add the remainder to the chunks array
        separators.add(template.substring(index));
        shouldAddSeparator = false;
        break;
      }
    }
    if (shouldAddSeparator) {
      separators.add('');
    }
    return (!mustHaveExpression || hasInterpolation)
        ? new Interpolation(template, separators, expressions)
        : null;
  }
}
