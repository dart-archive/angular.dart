part of angular;

class Token {
  bool json;
  int index;
  String text;
  String string;
  Operator fn;

  Token(this.index, this.text);

  withFn(fn) { this.fn = fn; }
  withString(string) { this.string = string; }
}

// TODO(deboer): Type this typedef further
typedef Operator(locals, a, b);

String QUOTES = "\"'";
String DOT = ".";
String SPECIAL = "(){}[].,;:";
String JSON_SEP = "{,";
String JSON_OPEN = "{[";
String JSON_CLOSE = "}]";
String WHITESPACE = " \r\t\n\v\u00A0";

Map<String, Operator> OPERATORS = {
  'undefined': (_, _0, _1) => null,
  '+': (locals, a, b) {
    return null;
//    var aResult = a(locals);
//    var bResult = b(locals);
//    if (a != null && b != null) return a + b;
//    if (a != null) return a;
//    if (b != null) return b;
//    return null;
  },
  '-': (locals, a, b) {
    return null;
//    var aResult = a(locals);
//    var bResult = b(locals);
//    return (a == null ? 0 : a) - (b == null ? 0 : b);
  },
  '|': (locals, a, b) => null //b(locals)(locals, a(locals))
};

Map<String, String> ESCAPE = {"n":"\n", "f":"\f", "r":"\r", "t":"\t", "v":"\v", "'":"'", '"':'"'};


class BreakException {}

class Parser {

  static List<Token> lex(String text) {
    List<Token> tokens = [];
    Token token;
    int index = 0;
    int lastIndex;
    int textLength = text.length;
    String ch;
    String lastCh = ":";

    isIn(String charSet, [String c]) =>  charSet.indexOf(c != null ? c : ch) != -1;
    was(String charSet) => charSet.indexOf(lastCh) != -1;

    cc(String s) => s.codeUnitAt(0);

    bool isNumber([String c]) {
      int cch = cc(c != null ? c : ch);
      return cc('0') <= cch && cch <= cc('9');
    }

    isIdent() {
      int cch = cc(ch);
      return
        cc('a') <= cch && cch <= cc('z') ||
        cc('A') <= cch && cch <= cc('Z') ||
        cc('_') == cch || cch == cc('\$');
    }

    isWhitespace([String c]) => isIn(WHITESPACE, c);

    isExpOperator([String c]) => false;

    String peek() => index + 1 < textLength ? text[index + 1] : "EOF";

    breakWhile() { throw new BreakException(); }
    whileChars(fn(), [endFn()]) {
      while (index < textLength) {
        ch = text[index];
        int lastIndex = index;
	      try {
          fn();
	      } on BreakException catch(e) {
	        endFn = null;
          break;
	      }
        if (lastIndex == index) {
	        throw "while chars loop must advance at index $index";
	      }
      }
      if (endFn != null) { endFn(); }
    }

    readString() {
      int start = index;

      String string = "";
      String rawString = ch;
      String quote = ch;

      index++;

      whileChars(() {
        rawString += ch;
        if (ch == '\\') {
          index++;
          whileChars(() {
            rawString += ch;
            if (ch == 'u') {
              throw "not impl unicode escape";
            } else {
              var rep = ESCAPE[ch];
              if (rep != null) {
                string += rep;
              } else {
                throw "not impl unneeded escape";
              }
              index++;
              breakWhile();
            }
          });
        } else if (ch == quote) {
          index++;
          tokens.add(new Token(start, rawString)
              ..withString(string)
              ..withFn((_, _0, _1) => string));
          breakWhile();
        } else {
          string += ch;
          index++;
        }
      }, () {
        throw "Unterminated quote starting at $start";
      });
    }

    readNumber() {
      String number = "";
      int start = index;
      whileChars(() {
        if (ch == '.' || isNumber()) {
          number += ch;
        } else {
          String peekCh = peek();
          if (ch == 'e' && isExpOperator(peekCh)) {
            throw "exp not implemented";
          } else if (isExpOperator() && peekCh != '' && isNumber(peekCh) && number[number.length - 1] == 'e') {
            throw "exp 2 not impl";
          } else if (isExpOperator() && (peekCh == '' || !isNumber(peekCh)) &&
              number[number.length - 1] == 'e') {
            throw "Invalid exponent";
          } else {
            breakWhile();
          }
        }
        index++;
      });
      tokens.add(new Token(start, number)..withFn((_,_1,_2) => int.parse(number)));
    }

    readIdent() {
      String ident = "";
      int start = index;
      int lastDot = -1, peekIndex = -1;
      String methodName;


      whileChars(() {
        if (ch == '.' || isIdent() || isNumber()) {
          if (ch == '.') {
            lastDot = index;
          }
          ident += ch;
        } else {
          breakWhile();
        }
        index++;
      });

      // The identifier had a . in the identifier
      if (lastDot != -1) {
        peekIndex = index;
        while (peekIndex < textLength) {
          String peekChar = text[peekIndex];
          if (peekChar == "(") {
            throw "not impl method name";
          }
          if (isWhitespace(peekChar)) {
            throw "not impl space before method name";
            //peekIndex++;
          } else {
            break;
          }
        }
      }

      var token = new Token(start, ident);

      if (OPERATORS.containsKey(ident)) {
        token.withFn(OPERATORS[ident]);
      } else {
        token.withFn((_, _0, _1) => throw "not impl ident getter");
      }

      tokens.add(token);

      if (methodName != null) {
        throw "not impl ident methodName";
      }
    }

    oneLexLoop() {
      if (isIn(QUOTES)) {
        readString();
      } else if (isNumber() || isIn(DOT) && isNumber(peek())) {
        readNumber();
      } else if (isIdent()) {
        readIdent();
        // TODO(deboer): WTF is this doing?
        if (was(JSON_SEP) && inJsonObject() && hasToken()) {
            throw "not impl json fixup";
//          token = tokens.last;
//          token.json = token.text.indexOf('.') == -1;
        }
      } else if (isIn(SPECIAL)) {
        tokens.add(new Token(index, ch));
        index++;
//        if (isIn(OPEN_JSON)) json.unshift(ch);
//        if (isIn(CLOSE_JSON)) json.shift();
      } else if (isWhitespace()) {
        index++;
      } else {
        // Check for two character operators (e.g. "==")
        String ch2 = ch + peek();
        Operator fn = OPERATORS[ch];
        Operator fn2 = OPERATORS[ch2];

        if (fn2 != null) {
          throw "not impl double op";
        } else if (fn != null) {
          tokens.add(new Token(index, ch)..withFn(fn));
          index++;
        } else {
          throw "Unexpected next character $index $ch";
        }
      }
    }

    whileChars(() {
      try {
        oneLexLoop();
      } catch (e, s) {
        throw "index: $index $e\nORIG STACK:\n" + s.toString();
      }
    });
    return tokens;

  }



}
