part of angular.core.parser;

@NgInjectableService()
abstract class Lexer {
  factory Lexer() => new _NewLexer();
  List<Token> call(String text);
}

class _NewLexer implements Lexer {
  List<Token> call(String text) {
    Scanner scanner = new Scanner(text);
    List<Token> tokens = [];
    Token token = scanner.scanToken();
    while (token != null) {
      tokens.add(token);
      token = scanner.scanToken();
    }
    return tokens;
  }
}

class Scanner {
  final String input;
  final int length;

  // TODO(kasperl): Get rid of this buffer. It is currently used for
  // pushing back tokens for method calls found while scanning
  // identifiers. We should be able to do this in the parser instead.
  final List<Token> buffer = [];

  int peek = 0;
  int index = -1;

  Scanner(String input) : this.input = input, this.length = input.length {
    advance();
  }

  Token scanToken() {
    // TODO(kasperl): The current handling of method calls is somewhat
    // complicated. We should simplify it by dealing with it in the parser.
    if (!buffer.isEmpty) return buffer.removeLast();

    // Skip whitespace.
    while (isWhitespace(peek)) advance();

    // Handle identifiers and numbers.
    if (isIdentifierStart(peek)) return scanIdentifier();
    if (isDigit(peek)) return scanNumber(index);

    int start = index;
    switch (peek) {
      case $EOF:
        return null;
      case $PERIOD:
        advance();
        return isDigit(peek) ? scanNumber(start) : new Token(start, '.');
      case $LPAREN:
        return scanCharacter(start, '(');
      case $RPAREN:
        return scanCharacter(start, ')');
      case $LBRACE:
        return scanCharacter(start, '{');
      case $RBRACE:
        return scanCharacter(start, '}');
      case $LBRACKET:
        return scanCharacter(start, '[');
      case $RBRACKET:
        return scanCharacter(start, ']');
      case $COMMA:
        return scanCharacter(start, ',');
      case $COLON:
        return scanCharacter(start, ':');
      case $SEMICOLON:
        return scanCharacter(start, ';');
      case $SQ:
      case $DQ:
        return scanString();
      case $PLUS:
        return scanOperator(start, '+');
      case $MINUS:
        return scanOperator(start, '-');
      case $STAR:
        return scanOperator(start, '*');
      case $SLASH:
        return scanOperator(start, '/');
      case $PERCENT:
        return scanOperator(start, '%');
      case $CARET:
        return scanOperator(start, '^');
      case $QUESTION:
        return scanOperator(start, '?');
      case $LT:
        return scanComplexOperator(start, $EQ, '<', '<=');
      case $GT:
        return scanComplexOperator(start, $EQ, '>', '>=');
      case $BANG:
        return scanComplexOperator(start, $EQ, '!', '!=');
      case $EQ:
        return scanComplexOperator(start, $EQ, '=', '==');
      case $AMPERSAND:
        return scanComplexOperator(start, $AMPERSAND, '&', '&&');
      case $BAR:
        return scanComplexOperator(start, $BAR, '|', '||');
      case $TILDE:
        return scanComplexOperator(start, $SLASH, '~', '~/');
    }

    String character = new String.fromCharCode(peek);
    error('Unexpected character [$character]');
  }

  Token scanCharacter(int start, String string) {
    assert(peek == string.codeUnitAt(0));
    advance();
    return new Token(start, string);
  }

  Token scanOperator(int start, String string) {
    assert(peek == string.codeUnitAt(0));
    assert(OPERATORS.containsKey(string));
    advance();
    return new Token(start, string)..withOp(string);
  }

  Token scanComplexOperator(int start, int code, String one, String two) {
    assert(peek == one.codeUnitAt(0));
    advance();
    String string = one;
    if (peek == code) {
      advance();
      string = two;
    }
    assert(OPERATORS.containsKey(string));
    return new Token(start, string)..withOp(string);
  }

  Token scanIdentifier() {
    assert(isIdentifierStart(peek));
    int start = index;
    int dot = -1;
    advance();
    while (true) {
      if (peek == $PERIOD) {
        dot = index;
      } else if (!isIdentifierPart(peek)) {
        break;
      }
      advance();
    }
    if (dot == -1) {
      String string = input.substring(start, index);
      Token result = new Token(start, string);
      // TODO(kasperl): Deal with null, undefined, true, and false in
      // a cleaner and faster way.
      if (OPERATORS.containsKey(string)) {
        result.withOp(string);
      } else {
        result.withGetterSetter(string);
      }
      return result;
    }

    int end = index;
    while (isWhitespace(peek)) advance();
    if (peek == $LPAREN) {
      buffer.add(new Token(dot + 1, input.substring(dot + 1, end)));
      buffer.add(new Token(dot, '.'));
      end = dot;
    }
    String string = input.substring(start, end);
    return new Token(start, string)..withGetterSetter(string);
  }

  Token scanNumber(int start) {
    assert(isDigit(peek));
    bool simple = (index == start);
    while (true) {
      if (isDigit(peek)) {
        // Do nothing.
      } else if (peek == $PERIOD) {
        simple = false;
      } else if (isExponentStart(peek)) {
        advance();
        if (isExponentSign(peek)) advance();
        if (!isDigit(peek)) error('Invalid exponent', -1);
        simple = false;
      } else {
        break;
      }
      advance();
    }
    String string = input.substring(start, index);
    num value = simple ? int.parse(string) : double.parse(string);
    return new Token(start, string)..withValue(value);
  }

  Token scanString() {
    assert(peek == $SQ || peek == $DQ);
    int start = index;
    int quote = peek;
    advance();  // Skip initial quote.

    StringBuffer buffer;
    int last = index;

    while (peek != quote) {
      if (peek == $BACKSLASH) {
        if (buffer == null) buffer = new StringBuffer();
        if (last < index) buffer.write(input.substring(last, index));
        advance();
        int unescaped;
        if (peek == $u) {
          // TODO(kasperl): Check bounds? Make sure we have test
          // coverage for this.
          String hex = input.substring(index + 1, index + 5);
          unescaped = int.parse(hex, radix: 16, onError: (ignore) {
            error('Invalid unicode escape [\\u$hex]'); });
          for (int i = 0; i < 5; i++) advance();
        } else {
          unescaped = unescape(peek);
          advance();
        }
        buffer.writeCharCode(unescaped);
        last = index;
      } else if (peek == $EOF) {
        error('Unterminated quote');
      } else {
        advance();
      }
    }

    advance();  // Skip terminating quote.

    String string = input.substring(start, index);
    String unescaped;
    if (buffer == null) {
      unescaped = input.substring(start + 1, index - 1);
    } else {
      if (last < index - 1) buffer.write(input.substring(last, index - 1));
      unescaped = buffer.toString();
    }
    return new Token(start, string)..withValue(unescaped);
  }

  void advance() {
    if (++index >= length) peek = $EOF;
    else peek = input.codeUnitAt(index);
  }

  void error(String message, [int offset = 0]) {
    // TODO(kasperl): Get rid of this position hack once the lexer tests
    // have been updated.
    int position = index + offset;
    throw "Lexer Error: $message at column $position in expression [$input]";
  }
}

class _OldLexer implements Lexer {
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
