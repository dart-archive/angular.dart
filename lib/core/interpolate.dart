part of angular.core;

String _startSymbol = '{{';
String _endSymbol = '}}';
int _startSymbolLength = _startSymbol.length;
int _endSymbolLength = _endSymbol.length;

class Interpolation {
  final String template;
  final List<String> seperators;
  final List<Getter> watchExpressions;
  Function setter = (_) => _;

  Interpolation(this.template, this.seperators, this.watchExpressions);

  String call(List parts, [_, __]) {
    var str = [];
    for(var i = 0, ii = parts.length; i < ii; i++) {
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
   */
  Interpolation call(String template, [bool mustHaveExpression = false]) {
    int startIndex;
    int endIndex;
    int index = 0;
    int length = template.length;
    bool hasInterpolation = false;
    bool shouldAddSeparator = true;
    String exp;
    List<String> separators = [];
    List<Getter> watchExpressions = [];

    while(index < length) {
      if ( ((startIndex = template.indexOf(_startSymbol, index)) != -1) &&
           ((endIndex = template.indexOf(_endSymbol, startIndex + _startSymbolLength)) != -1) ) {
        separators.add(template.substring(index, startIndex));
        exp = template.substring(startIndex + _startSymbolLength, endIndex);
        Expression expression = _parse(exp);
        watchExpressions.add(expression.eval);
        index = endIndex + _endSymbolLength;
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
    if (!mustHaveExpression  || hasInterpolation) {
      return new Interpolation(template, separators, watchExpressions);
    }
  }
}
