part of angular.core.parser;

@NgInjectableService()
class Lexer {
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
    int marker = index;

    while (peek != quote) {
      if (peek == $BACKSLASH) {
        if (buffer == null) buffer = new StringBuffer();
        buffer.write(input.substring(marker, index));
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
        marker = index;
      } else if (peek == $EOF) {
        error('Unterminated quote');
      } else {
        advance();
      }
    }

    String last = input.substring(marker, index);
    advance();  // Skip terminating quote.
    String string = input.substring(start, index);

    // Compute the unescaped string value.
    String unescaped = last;
    if (buffer != null) {
      buffer.write(last);
      unescaped = buffer.toString();
    }
    return new Token(start, string)..withValue(unescaped);
  }

  void advance() {
    if (++index >= length) peek = $EOF;
    else peek = input.codeUnitAt(index);
  }

  void error(String message, [int offset = 0]) {
    // TODO(kasperl): Try to get rid of the offset. It is only used to match
    // the error expectations in the lexer tests for numbers with exponents.
    int position = index + offset;
    throw "Lexer Error: $message at column $position in expression [$input]";
  }
}
