part of angular;


class ParsedFn {
  ParsedGetterFn getterFn;
  ParsedAssignFn assignFn;

  ParsedFn(this.getterFn, [this.assignFn]);
  call(s, l) => getterFn(s, l);
  assign(s, v, l) => assignFn(s, v, l);

  get assignable => assignFn != null;
}

class Token {
  bool json;
  int index;
  String text;
  String string;
  Operator fn;
  // access fn as a function that doesn't take a or b values.
  ParsedFn primaryFn;

  Token(this.index, this.text) {
    // default fn
    this.withFn((s, l, a, b) => text);
  }

  withFn(fn, [assignFn]) {
    this.fn = fn;
    this.primaryFn = new ParsedFn(
        (s, l) => fn(s, l, null, null),
        assignFn);
  }

  withFn0(fn()) => withFn(op0(fn));

  withString(string) { this.string = string; }

  fn0() => primaryFn(null, null);

  toString() => "Token($text)";
}

// TODO(deboer): Type this typedef further
typedef Operator(scope, locals, ParsedFn a, ParsedFn b);

typedef ParsedGetterFn(scope, locals);
typedef ParsedAssignFn(scope, value, locals);

op0(fn()) => (_, _1, _2, _3) => fn();

String QUOTES = "\"'";
String DOT = ".";
String SPECIAL = "(){}[].,;:";
String JSON_SEP = "{,";
String JSON_OPEN = "{[";
String JSON_CLOSE = "}]";
String WHITESPACE = " \r\t\n\v\u00A0";
String EXP_OP = "Ee";
String SIGN_OP = "+-";

Operator NULL_OP = (_, _x, _0, _1) => null;
Operator NOT_IMPL_OP = (_, _x, _0, _1) => throw "Op not implemented";

toBool(x) {
  if (x is bool) return x;
  if (x is int || x is double) return x != 0;
  throw "Can't convert $x to boolean";
}

Map<String, Operator> OPERATORS = {
  'undefined': NULL_OP,
  'true': (scope, locals, a, b) => true,
  'false': (scope, locals, a, b) => false,
  '+': (scope, locals, aFn, bFn) {
    var a = aFn(scope, locals);
    var b = bFn(scope, locals);
    if (a != null && b != null) return a + b;
    if (a != null) return a;
    if (b != null) return b;
    return null;
  },
  '-': (scope, locals, a, b) {
    assert(a != null || b != null);
    var aResult = a != null ? a(scope, locals) : null;
    var bResult = b != null ? b(scope, locals) : null;
    return (aResult == null ? 0 : aResult) - (bResult == null ? 0 : bResult);
  },
  '*': (s, l, a, b) => a(s, l) * b(s, l),
  '/': (s, l, a, b) => a(s, l) / b(s, l),
  '%': (s, l, a, b) => a(s, l) % b(s, l),
  '^': (s, l, a, b) => a(s, l) ^ b(s, l),
  '=': NULL_OP,
  '==': (s, l, a, b) => a(s, l) == b(s, l),
  '!=': (s, l, a, b) => a(s, l) != b(s, l),
  '<': (s, l, a, b) => a(s, l) < b(s, l),
  '>': (s, l, a, b) => a(s, l) > b(s, l),
  '<=': (s, l, a, b) => a(s, l) <= b(s, l),
  '>=': (s, l, a, b) => a(s, l) >= b(s, l),
  '&&': (s, l, a, b) => toBool(a(s, l)) && toBool(b(s, l)),
  '||': (s, l, a, b) => toBool(a(s, l)) || toBool(b(s, l)),
  '&': (s, l, a, b) => a(s, l) & b(s, l),
  '|': NOT_IMPL_OP, //b(locals)(locals, a(locals))
  '!': (scope, locals, a, b) => !toBool(a(scope, locals))
};

Map<String, String> ESCAPE = {"n":"\n", "f":"\f", "r":"\r", "t":"\t", "v":"\v", "'":"'", '"':'"'};

ParsedFn ZERO = new ParsedFn((_, _x) => 0);

class BreakException {}

getterFn(scope, path) {
  List<String> pathKeys = path.split('.');
  var pathKeysLength = pathKeys.length;
  var currentValue = scope;
  for (var i = 0; i < pathKeysLength; i++) {
    try {
      currentValue = currentValue[pathKeys[i]];
    } catch (e) {
      // maybe it is a member field?
      try {
        currentValue = reflect(currentValue).getField(new Symbol(pathKeys[i])).reflectee;
      } catch (e) {
        return null;
      }
    }
  }
  return currentValue;
}

setter(Map obj, path, setValue) {
  var element = path.split('.');
  for (var i = 0; element.length > 1; i++) {
    var key = element.removeAt(0);
    var propertyObj = obj[key];
    if (propertyObj == null) {
      propertyObj = {};
      obj[key] = propertyObj;
    }
    obj = propertyObj;
  }
  obj[element.removeAt(0)] = setValue;
  return setValue;
}

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

    isExpOperator([String c]) => isIn(SIGN_OP, c) || isNumber(c);

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
                  onError: (s) => throw "Lexer Error: Invalid unicode escape [\\u$hex] at column $index in expression [$text].");
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
            breakWhile();
          });
        } else if (ch == quote) {
          index++;
          tokens.add(new Token(start, rawString)
              ..withString(string)
              ..withFn0(() => string));
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
          if (isIn(EXP_OP) && isExpOperator(peekCh)) {
            number += ch;
          } else if (isExpOperator() && peekCh != '' && isNumber(peekCh) && isIn(EXP_OP, number[number.length - 1])) {
            number += ch;
          } else if (isExpOperator() && (peekCh == '' || !isNumber(peekCh)) &&
              isIn(EXP_OP, number[number.length - 1])) {
            throw "Lexer Error: Invalid exponent at column $index in expression [$text].";
          } else {
            breakWhile();
          }
        }
        index++;
      });
      tokens.add(new Token(start, number)..withFn0(() => double.parse(number)));
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
        token.withFn(OPERATORS[ident]);
      } else {
        // TODO(deboer): In the JS version this method is incredibly optimized.
        // We should likely do the same.
        token.withFn((scope, locals, a, b) => getterFn(scope, ident),
        (scope, value, unused_locals) =>
          setter(scope, ident, value)
        );
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
          tokens.add(new Token(index, ch2)..withFn(fn2));
          index += 2;
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

  static ParsedFn parse(text) {
    List<Token> tokens = Parser.lex(text);
    Token token;


    Token peekToken() {
      if (tokens.length == 0)
        throw "not impl peekToken error"; //throw Error("Unexpected end of expression: " + text);
      return tokens[0];
    }

    Token peek([String e1, String e2, String e3, String e4]) {
      if (tokens.length > 0) {
        Token token = tokens[0];
        String t = token.text;
        if (t==e1 || t==e2 || t==e3 || t==e4 ||
            (e1 == null && e2 == null && e3 == null && e4 == null)) {
          return token;
        }
      }
      return null;
    }

    Token expect([String e1, String e2, String e3, String e4]){
      Token token = peek(e1, e2, e3, e4);
      if (token != null) {
        // TODO json
//        if (json && !token.json) {
//          throwError("is not valid json", token);
//        }
        tokens.removeAt(0);
        return token;
      }
      return null;
    }

    ParsedFn consume(e1){
      if (expect(e1) == null) {
        throw "not impl consume error";
        //throwError("is unexpected, expecting [" + e1 + "]", peek());
      }
    }





    var filterChain = null;
    var functionCall, arrayDeclaration, objectIndex, fieldAccess, object;



    ParsedFn primary() {
      var primary;
      if (expect('(') != null) {
        primary = filterChain();
        consume(')');
      } else if (expect('[') != null) {
        primary = arrayDeclaration();
      } else if (expect('{') != null) {
        primary = object();
      } else {
        var token = expect();
        primary = token.primaryFn;
        if (primary == null) {
          throw "not impl error";
          //throwError("not a primary expression", token);
        }
      }

      // TODO(deboer): I don't think context applies to Dart..
      var next, context;
      while ((next = expect('(', '[', '.')) != null) {
        if (next.text == '(') {
          primary = functionCall(primary);
          context = null;
        } else if (next.text == '[') {
          context = primary;
          primary = objectIndex(primary);
        } else if (next.text == '.') {
          context = primary;
          primary = fieldAccess(primary);
        } else {
          throw "Impossible.. what?";
        }
      }
      return primary;
    }

    ParsedFn binaryFn(ParsedFn left, Operator fn, ParsedFn right) =>
      new ParsedFn((self, locals) {
        return fn(self, locals, left, right);
      });

    ParsedFn unaryFn(Operator fn, ParsedFn right) =>
      new ParsedFn((self, locals) {
        return fn(self, locals, right, null);
      });

    ParsedFn unary() {
      var token;
      if (expect('+') != null) {
        return primary();
      } else if ((token = expect('-')) != null) {
        return binaryFn(ZERO, token.fn, unary());
      } else if ((token = expect('!')) != null) {
        return unaryFn(token.fn, unary());
      } else {
        return primary();
      }
    }

    ParsedFn multiplicative() {
      var left = unary();
      var token;
      while ((token = expect('*','/','%')) != null) {
        left = binaryFn(left, token.fn, unary());
      }
      return left;
    }

    ParsedFn additive() {
      var left = multiplicative();
      var token;
      while ((token = expect('+','-')) != null) {
        left = binaryFn(left, token.fn, multiplicative());
      }
      return left;
    }

    ParsedFn relational() {
      var left = additive();
      var token;
      if ((token = expect('<', '>', '<=', '>=')) != null) {
        left = binaryFn(left, token.fn, relational());
      }
      return left;
    }

    ParsedFn equality() {
      var left = relational();
      var token;
      if ((token = expect('==','!=')) != null) {
        left = binaryFn(left, token.fn, equality());
      }
      return left;
    }

    ParsedFn logicalAND() {
      var left = equality();
      var token;
      if ((token = expect('&&')) != null) {
        left = binaryFn(left, token.fn, logicalAND());
      }
      return left;
    }

    ParsedFn logicalOR() {
      var left = logicalAND();
      var token;
      while(true) {
        if ((token = expect('||')) != null) {
          left = binaryFn(left, token.fn, logicalAND());
        } else {
          return left;
        }
      }
    }

    // =========================
    // =========================

    ParsedFn assignment() {
      var left = logicalOR();
      var right;
      var token;
      if ((token = expect('=')) != null) {
        if (!left.assignable) {
          throw "not impl bad assignment error";
//          throwError("implies assignment but [" +
//              text.substring(0, token.index) + "] can not be assigned to", token);
        }
        right = logicalOR();
        return new ParsedFn((scope, locals) =>
          left.assign(scope, right(scope, locals), locals));
      } else {
        return left;
      }
    }


    ParsedFn expression() {
      return assignment();
    }

    filterChain = () {
      var left = expression();
      var token;
      while(true) {
        if ((token = expect('|') != null)) {
          //left = binaryFn(left, token.fn, filter());
          throw "not impl filter";
        } else {
          return left;
        }
      }
    };

    statements() {
      List<ParsedFn> statements = [];
      while (true) {
        if (tokens.length > 0 && peek('}', ')', ';', ']') == null)
          statements.add(filterChain());
        if (expect(';') == null) {
          return statements.length == 1
              ? statements[0]
              : new ParsedFn((scope, locals) {
                var value;
                for ( var i = 0; i < statements.length; i++) {
                  var statement = statements[i];
                  if (statement != null)
                    value = statement(scope, locals);
                }
                return value;
              });
        }
      }
    }

    functionCall = (fn) {
      var argsFn = [];
      if (peekToken().text != ')') {
        do {
          argsFn.add(expression());
        } while (expect(',') != null);
      }
      consume(')');
      return new ParsedFn((self, locals){
        List args = [];
        for ( var i = 0; i < argsFn.length; i++) {
          args.add(argsFn[i](self, locals));
        }
        var userFn = fn(self, locals);
        return Function.apply(userFn, args);
      });
    };

    // This is used with json array declaration
    arrayDeclaration = () {
      var elementFns = [];
      if (peekToken().text != ']') {
        do {
          elementFns.add(expression());
        } while (expect(',') != null);
      }
      consume(']');
      return new ParsedFn((self, locals){
        var array = [];
        for ( var i = 0; i < elementFns.length; i++) {
          array.add(elementFns[i](self, locals));
        }
        return array;
      });
    };

    objectIndex = (obj) {
      var indexFn = expression();
      consume(']');
      return new ParsedFn((self, locals){
            int i = indexFn(self, locals).toInt();
            var o = obj(self, locals),
                v, p;

            if (o == null) return throw "not impl null obj";  // null
            v = o[i];
            // TODO futures
            /*
            if (v && v.then) {
              p = v;
              if (!('$$v' in v)) {
                p.$$v = undefined;
                p.then(ParsedFn(val) { p.$$v = val; });
              }
              v = v.$$v;
            } */
            return v;
          }, (self, value, locals) =>
              obj(self, locals)[indexFn(self, locals)] = value
          );

    };

    fieldAccess = (object) {
      var field = expect().text;
      //var getter = getterFn(field);
      return new ParsedFn((self, locals) => getterFn(object(self, locals), field),
          (self, value, locals) => setter(object(self, locals), field, value));
    };

    object = () {
      var keyValues = [];
      if (peekToken().text != '}') {
        do {
          var token = expect(),
              key = token.string != null ? token.string : token.text;
          consume(":");
          var value = expression();
          keyValues.add({"key":key, "value":value});
        } while (expect(',') != null);
      }
      consume('}');
      return new ParsedFn((self, locals){
        var object = {};
        for ( var i = 0; i < keyValues.length; i++) {
          var keyValue = keyValues[i];
          var value = keyValue["value"](self, locals);
          object[keyValue["key"]] = value;
        }
        return object;
      });
    };






    // TODO(deboer): json
    ParsedFn value = statements();

    if (tokens.length != 0) {
      throw "not impl, error msg $tokens";
    }
    return value;
  }

}
