part of angular;

class Token {
  bool json;
  int index;
  String text;

  Token(this.index, this.text);
}

// TODO(deboer): Type this typedef further
typedef Operator(locals, a, b);

String QUOTES = "\"'";
String DOT = ".";
String SPECIAL = "(){}[].,;:";
String JSON_SEP = "{,";

Map<String, Operator> OPERATORS = { };

class Parser {

  static List<Token> lex(String text) {
    List<Token> tokens = [];
    Token token;
    int index = 0;
    int lastIndex;
    int textLength = text.length;
    String ch;
    String lastCh = ":";

    isIn(String charSet) =>  charSet.indexOf(ch) != -1;
    was(String charSet) => charSet.indexOf(lastCh) != -1;
    isNumber() => false;
    isIdent() {
      cc(String s) => s.codeUnitAt(0);
      int cch = cc(ch);
      return
        cc('a') <= cch && cch <= cc('z') ||
        cc('A') <= cch && cch <= cc('Z') ||
        cc('_') == cch || cch == cc('\$');
    }

    isWhitespace() => false;

    String peek() => index + 1 < textLength ? text[index + 1] : "EOF";

    readIdent() {
      String ident = "";
      int start = index;
      int lastDot = -1, peekIndex = -1;
      String methodName;

      while (index < textLength) {
        ch = text[index];
        if (ch == '.' || isIdent() || isNumber()) {
          if (ch == '.') throw "not impl ident dots";
          ident += ch;
        } else {
          break;
        }
        index++;
      }

      if (lastDot != -1) {
        throw "not impl last dot";
      }

      var token = new Token(start, ident);

      if (OPERATORS.containsKey(ident)) {
        throw "not impl ident operator";
      }

      tokens.add(token);

      if (methodName != null) {
        throw "not impl ident methodName";
      }
    }

    oneLexLoop() {
      lastIndex = index;
      ch = text[index];
      if (isIn(QUOTES)) {
        throw "not implemented";
      } else if (isNumber() || isIn(DOT) && isNumber(peek())) {
        throw "not implemented";
      } else if (isIdent()) {
        readIdent();
        // TODO(deboer): WTF is this doing?
        if (was(JSON_SEP) && inJsonObject() && hasToken()) {
            throw "not impl json fixup";
//          token = tokens.last;
//          token.json = token.text.indexOf('.') == -1;
        }
      } else if (isIn(SPECIAL)) {
        throw "not implemented special";
      } else if (isWhitespace()) {
        throw "not impl ws";
      } else {
        // Check for two character operators (e.g. "==")
        String ch2 = ch + peek();
        Operator fn = OPERATORS[ch];
        Operator fn2 = OPERATORS[ch2];

        if (fn2 != null) {
          throw "not impl double op";
        } else if (fn != null) {
          throw "not impl op";
        } else {
          throw "Unexpected next character $index $ch";
        }
      }
      if (index == lastIndex) {
        throw "Lex loop must advance: $index";
      }
    }

    while (index < textLength) {
      try {
        oneLexLoop();
      } catch (e, s) {
        throw "index: $index $e\nORIG STACK:\n" + s.toString();
      }

    }

    return tokens;

  }



}