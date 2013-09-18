library angular.core.service.interpolate;

import 'parser/parser_library.dart';
import 'exception_handler.dart';


String _startSymbol = '{{';
String _endSymbol = '}}';
num _startSymbolLength = _startSymbol.length;
num _endSymbolLength = _endSymbol.length;

/**
 * Compiles a string with markup into an interpolation function. This service
 * is used by the HTML [Compiler] service for data binding.
 *
 *
 *     var $interpolate = ...; // injected
 *     var exp = $interpolate('Hello {{name}}!');
 *     expect(exp({name:'Angular'}).toEqual('Hello Angular!');
 */
class Interpolate {
  Parser _parse;
  ExceptionHandler _exceptionHandler;

  Interpolate(Parser this._parse, ExceptionHandler this._exceptionHandler);

  /**
   * Compile markup text into interpolation function.
   *
   * - `text`: The markup text to interpolate in form `foo {{expr}} bar`.
   * - `mustHaveExpression`: if set to true then the interpolation string must
   *      have embedded expression in order to return an interpolation function.
   *      Strings with no embedded expression will return null for the
   *      interpolation function.
   */
  Expression call(String text, [bool mustHaveExpression = false]) {
    num startIndex;
    num endIndex;
    num index = 0;
    List chunks = [];
    num length = text.length;
    bool hasInterpolation = false;
    String exp;
    List concat = [];
    Expression fn;

    while(index < length) {
      if ( ((startIndex = text.indexOf(_startSymbol, index)) != -1) &&
           ((endIndex = text.indexOf(_endSymbol, startIndex + _startSymbolLength)) != -1) ) {
        (index != startIndex) && chunks.add(text.substring(index, startIndex));
        fn = $parse(exp = text.substring(startIndex + _startSymbolLength, endIndex));
        chunks.add(fn);
        fn.exp = exp;
        index = endIndex + _endSymbolLength;
        hasInterpolation = true;
      } else {
        // we did not find anything, so we have to add the remainder to the chunks array
        (index != length) && chunks.add(text.substring(index));
        index = length;
      }
    }

    if ((length = chunks.length) == 0) {
      // we added, nothing, must have been an empty string.
      chunks.add('');
      length = 1;
    }

    if (!mustHaveExpression  || hasInterpolation) {
      fn = new Expression((context, [locals]) {
        try {
          for(var i = 0, ii = length, chunk; i<ii; i++) {
            if ((chunk = chunks[i]) is Expression) {
              chunk = chunk.eval(context);
              if (chunk == null) {
                chunk = '';
              } else if (!(chunk is String)) {
                chunk = '$chunk';
              }
            }
            concat.add(chunk);
          }
          return concat.join('');
        } catch(err, s) {
          $exceptionHandler("\$interpolate error! Can't interpolate: $text\n$err", s);
        } finally {
          concat.length = 0;
        }
      });
      fn.exp = text;
      fn.parts = chunks;
      return fn;
    }
  }
}
