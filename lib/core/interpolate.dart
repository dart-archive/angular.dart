part of angular.core_internal;

class Interpolation {
  final String expression;
  final List<String> bindingExpressions;

  Interpolation(this.expression, this.bindingExpressions);
}

final EMPTY_INTERPOLATION = new Interpolation("", <String>[]);

/**
 * Compiles a string with markup into an expression. This service is used by the
 * HTML [Compiler] service for data binding.
 *
 *     var interpolate = ...; // injected
 *     var exp = interpolate('Hello {{name}}!');
 *     expect(exp).toEqual('"Hello "+(name|stringify)+"!"');
 */
@Injectable()
class Interpolate implements Function {
  var _cache = new HashMap();

  Interpolate(CacheRegister cacheRegister) {
    cacheRegister.registerCache("Interpolate", _cache);
  }

  /**
   * Compiles markup text into expression.
   *
   * - [template]: The markup text to interpolate in form `foo {{expr}} bar`.
   * - [mustHaveExpression]: if set to true then the interpolation string must
   *   have embedded expression in order to return an expression. Strings with
   *   no embedded expression will return null.
   * - [startSymbol]: The symbol to start interpolation. '{{' by default.
   * - [endSymbol]: The symbol to end interpolation. '}}' by default.
   */
  Interpolation call(String template, [bool mustHaveExpression = false,
                            String startSymbol = '{{', String endSymbol = '}}']) {
    if (mustHaveExpression == false && startSymbol == '{{' && endSymbol == '}}') {
      // cachable
      return _cache.putIfAbsent(template, () => _call(template, mustHaveExpression, startSymbol, endSymbol));
    }
    return _call(template, mustHaveExpression, startSymbol, endSymbol);
  }

  Interpolation _call(String template, [bool mustHaveExpression = false,
                      String startSymbol, String endSymbol]) {
    if (template == null || template.isEmpty) return EMPTY_INTERPOLATION;

    final startLen = startSymbol.length;
    final endLen = endSymbol.length;
    final length = template.length;

    int startIdx;
    int endIdx;
    int index = 0;

    bool hasInterpolation = false;

    String exp;
    final expParts = <String>[];
    final bindings = <String>[];

    while (index < length) {
      startIdx = template.indexOf(startSymbol, index);
      endIdx = template.indexOf(endSymbol, startIdx + startLen);
      if (startIdx != -1 && endIdx != -1) {
        if (index < startIdx) {
          // Empty strings could be stripped thanks to the stringify
          // formatter
          expParts.add(_wrapInQuotes(template.substring(index, startIdx)));
        }
        var binding = template.substring(startIdx + startLen, endIdx);
        bindings.add(binding);
        expParts.add('(' + binding + '|stringify)');

        index = endIdx + endLen;
        hasInterpolation = true;
      } else {
        // we did not find any interpolation, so add the remainder
        expParts.add(_wrapInQuotes(template.substring(index)));
        break;
      }
    }

    return !mustHaveExpression || hasInterpolation ?
        new Interpolation(expParts.join('+'), bindings) : null;
  }

  String _wrapInQuotes(String s){
    final escaped = s.replaceAll(r'\', r'\\').replaceAll(r'"', r'\"');
    return '"$escaped"';
  }
}
