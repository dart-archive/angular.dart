part of angular.core.parser;

@NgInjectableService()
class Lexer {
  static const String QUOTES = "\"'";
  static const String DOT = ".";
  static const String SPECIAL = "(){}[].,;:";
  static const String JSON_SEP = "{,";
  static const String JSON_OPEN = "{[";
  static const String JSON_CLOSE = "}]";
  static const String WHITESPACE = " \r\t\n\v\u00A0";
  static const String EXP_OP = "Ee";
  static const String SIGN_OP = "+-";

  static Map<String, String> ESCAPE =
      {"n":"\n", "f":"\f", "r":"\r", "t":"\t", "v":"\v", "'":"'", '"':'"'};

  List<Token> call(String text) {
    List<Token> tokens = [];
    Token token;
    int index = 0;
    int lastIndex;
    int textLength = text.length;
    String ch;
    String lastCh = ":";

    isIn(String charSet, [String c]) =>
      charSet.indexOf(c != null ? c : ch) != -1;
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
    isExpOperator([String c]) => isIn(SIGN_OP, c) || isNumber(c);

    String peek() => index + 1 < textLength ? text[index + 1] : "EOF";

    lexError(String s) { throw "Lexer Error: $s at column $index in expression [$text]"; }

    // whileChars takes two functions: One called for each character
    // and a second, optional function call at the end of the file.
    // If the first function returns false, the the loop stops and endFn
    // is not run.
    whileChars(fn(), [endFn()]) {
      while (index < textLength) {
        ch = text[index];
        int lastIndex = index;
        if (fn() == false) {
          return;
        }
        if (lastIndex >= index) {
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
              String hex = text.substring(index + 1, index + 5);
              int charCode = int.parse(hex, radix: 16,
              onError: (s) { lexError('Invalid unicode escape [\\u$hex]'); });
              string += new String.fromCharCode(charCode);
              index += 5;
            } else {
              var rep = ESCAPE[ch];
              if (rep != null) {
                string += rep;
              } else {
                string += ch;
              }
              index++;
            }
            return false; // BREAK
          });
        } else if (ch == quote) {
          index++;
          tokens.add(new Token(start, rawString)
          ..withValue(string));
          return false; // BREAK
        } else {
          string += ch;
          index++;
        }
      }, () {
        lexError('Unterminated quote starting at $start');
      });
    }

    readNumber() {
      String number = "";
      int start = index;
      bool simpleInt = true;
      whileChars(() {
        if (ch == '.') {
          number += ch;
          simpleInt = false;
        } else if (isNumber()) {
          number += ch;
        } else {
          String peekCh = peek();
          if (isIn(EXP_OP) && isExpOperator(peekCh)) {
            simpleInt = false;
            number += ch;
          } else if (isExpOperator() && peekCh != '' && isNumber(peekCh) && isIn(EXP_OP, number[number.length - 1])) {
            simpleInt = false;
            number += ch;
          } else if (isExpOperator() && (peekCh == '' || !isNumber(peekCh)) &&
          isIn(EXP_OP, number[number.length - 1])) {
            lexError('Invalid exponent');
          } else {
            return false; // BREAK
          }
        }
        index++;
      });
      var ret = simpleInt ? int.parse(number) : double.parse(number);
      tokens.add(new Token(start, number)..withValue(ret));
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
          return false; // BREAK
        }
        index++;
      });

      // The identifier had a . in the identifier
      if (lastDot != -1) {
        peekIndex = index;
        while (peekIndex < textLength) {
          String peekChar = text[peekIndex];
          if (peekChar == "(") {
            methodName = ident.substring(lastDot - start + 1);
            ident = ident.substring(0, lastDot - start);
            index = peekIndex;
          }
          if (isWhitespace(peekChar)) {
            peekIndex++;
          } else {
            break;
          }
        }
      }

      var token = new Token(start, ident);

      if (OPERATORS.containsKey(ident)) {
        token.withOp(ident);
      } else {
        token.withGetterSetter(ident);
      }

      tokens.add(token);

      if (methodName != null) {
        tokens.add(new Token(lastDot, '.'));
        tokens.add(new Token(lastDot + 1, methodName));
      }
    }

    oneLexLoop() {
      if (isIn(QUOTES)) {
        readString();
      } else if (isNumber() || isIn(DOT) && isNumber(peek())) {
        readNumber();
      } else if (isIdent()) {
        readIdent();
      } else if (isIn(SPECIAL)) {
        tokens.add(new Token(index, ch));
        index++;
      } else if (isWhitespace()) {
        index++;
      } else {
        // Check for two character operators (e.g. "==")
        String ch2 = ch + peek();

        if (OPERATORS.containsKey(ch2)) {
          tokens.add(new Token(index, ch2)..withOp(ch2));
          index += 2;
        } else if (OPERATORS.containsKey(ch)) {
          tokens.add(new Token(index, ch)..withOp(ch));
          index++;
        } else {
          lexError('Unexpected next character [$ch]');
        }
      }
    }

    whileChars(() {
      oneLexLoop();
    });
    return tokens;
  }
}
