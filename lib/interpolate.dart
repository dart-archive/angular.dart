part of angular;


String startSymbol = '{{';
String endSymbol = '}}';
num startSymbolLength = startSymbol.length;
num endSymbolLength = endSymbol.length;

class Interpolate {
  Parser $parse;
  ExceptionHandler $exceptionHandler;

  Interpolate(Parser this.$parse, ExceptionHandler this.$exceptionHandler);

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
      if ( ((startIndex = text.indexOf(startSymbol, index)) != -1) &&
           ((endIndex = text.indexOf(endSymbol, startIndex + startSymbolLength)) != -1) ) {
        (index != startIndex) && chunks.add(text.substring(index, startIndex));
        fn = $parse(exp = text.substring(startIndex + startSymbolLength, endIndex));
        chunks.add(fn);
        fn.exp = exp;
        index = endIndex + endSymbolLength;
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
      fn = new Expression((context, locals) {
        try {
          for(var i = 0, ii = length, chunk; i<ii; i++) {
            if ((chunk = chunks[i]) is Function) {
              chunk = chunk(context);
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
