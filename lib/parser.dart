part of angular;


class ParsedFn {
  Parsedgetter getter;
  ParsedAssignFn assignFn;
  String exp;
  List parts;

  ParsedFn(this.getter, [this.assignFn]);
  call([s, l]) => getter(s, l);
  assign(s, v, [l]) => assignFn(s, v, l);

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

typedef Parsedgetter(scope, locals);
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

// Automatic type conversion.
autoConvertAdd(a, b) {
  // TODO(deboer): Support others.
  if (a is String && b is! String) {
    return a + b.toString();
  }
  if (a is! String && b is String) {
    return a.toString() + b;
  }
  return a + b;
}

Map<String, Operator> OPERATORS = {
  'undefined': NULL_OP,
  'true': (scope, locals, a, b) => true,
  'false': (scope, locals, a, b) => false,
  '+': (scope, locals, aFn, bFn) {
    var a = aFn(scope, locals);
    var b = bFn(scope, locals);
    if (a != null && b != null) return autoConvertAdd(a, b);
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

class Setter {
  operator[]=(name, value){}
}

abstract class Getter {
  bool containsKey(name);
  operator[](name);
}

stripTrailingNulls(List l) {
  while (l.length > 0 && l.last == null) {
    l.removeLast();
  }
  return l;
}

// Returns a tuple [found, value]
getterChild(value, childKey) {
  if (value is List && childKey is num) {
    if (childKey < value.length) {
      return [true, value[childKey]];
    } else {
      return [false, null];
    }
  }

  // TODO: replace with isInterface(value, Getter) when dart:mirrors
  // can support mixins.
  try {
    // containsKey() might not return a boolean, so explicitly test
    // against true.
    if (value.containsKey(childKey) == true) {
      return [true, value[childKey]];
    }
  } on NoSuchMethodError catch(e) {}

  InstanceMirror instanceMirror = reflect(value);
  Symbol curSym = new Symbol(childKey);

  try {
    // maybe it is a member field?
    return [true, instanceMirror.getField(curSym).reflectee];
  } on NoSuchMethodError catch (e) {
    // maybe it is a member method?
    if (instanceMirror.type.members.containsKey(curSym)) {
      MethodMirror methodMirror = instanceMirror.type.members[curSym];
      return [true, _relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
        var args = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
        return instanceMirror.invoke(curSym, args).reflectee;
      })];
    }
    return [false, null];
  }
}

getter(scope, locals, path) {
  if (scope == null) {
    return null;
  }

  List<String> pathKeys = path.split('.');
  var pathKeysLength = pathKeys.length;

  if (pathKeysLength == 0) { return scope; }

  // Use the locals object is the first key is defined on locals.
  // This allows users to hide sub-trees by setting the locals
  // value to 'null'.
  if (locals != null && getterChild(locals, pathKeys[0])[0]) {
    return getter(locals, null, path);
  }


  var currentValue = scope;
  for (var i = 0; i < pathKeysLength; i++) {
    var curKey = pathKeys[i];
    currentValue = getterChild(currentValue, curKey)[1];
    if (currentValue == null) { return null; }
  }
  //throw "getter parser";
  return currentValue;
}

setterChild(obj, childKey, value) {
  // TODO: replace with isInterface(value, Setter) when dart:mirrors
  // can support mixins.
  try {
    obj[childKey] = value;
    return value;
  } on NoSuchMethodError catch(e) {}

  InstanceMirror instanceMirror = reflect(obj);
  Symbol curSym = new Symbol(childKey);
  // maybe it is a member field?
  return instanceMirror.setField(curSym, value).reflectee;
}

setter(obj, path, setValue) {
  var element = path.split('.');
  for (var i = 0; element.length > 1; i++) {
    var key = element.removeAt(0);
    var propertyObj = getterChild(obj, key)[1];
    if (propertyObj == null) {
      propertyObj = {};
      setterChild(obj, key, propertyObj);
    }
    obj = propertyObj;
  }
  return setterChild(obj, element.removeAt(0), setValue);
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
            return false; // BREAK
          });
        } else if (ch == quote) {
          index++;
          tokens.add(new Token(start, rawString)
              ..withString(string)
              ..withFn0(() => string));
          return false; // BREAK
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
            throw "Lexer Error: Invalid exponent at column $index in expression [$text].";
          } else {
            return false; // BREAK
          }
        }
        index++;
      });
      var ret = simpleInt ? int.parse(number) : double.parse(number);
      tokens.add(new Token(start, number)..withFn0(() => ret));
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
        token.withFn(OPERATORS[ident]);
      } else {
        // TODO(deboer): In the JS version this method is incredibly optimized.
        // We should likely do the same.
        token.withFn((scope, locals, a, b) => getter(scope, locals, ident),
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

  ParsedFn call(String text) {
    return Parser.parse(text);
  }

  static ParsedFn parse(text) {
    List<Token> tokens = Parser.lex(text);
    Token token;

    parserError(String s, [Token t]) {
      if (t == null && !tokens.isEmpty) t = tokens[0];
      String location = t == null ?
          'the end of the expression' :
          'at column ${t.index + 1} in';
      return 'Parser Error: $s $location [$text]';
    }
    evalError(String s, [stack]) => 'Eval Error: $s while evaling [$text]' +
        (stack != null ? '\n\nFROM:\n$stack' : '');

    Token peekToken() {
      if (tokens.length == 0)
        throw "Unexpected end of expression: " + text;
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

    /**
     * Token savers are synchronous lists that allows Parser functions to
     * access the tokens parsed during some amount of time.  They are useful
     * for printing helpful debugging messages.
     */
    List<List<Token>> tokenSavers = [];
    List<Token> saveTokens() { var n = []; tokenSavers.add(n); return n; }
    stopSavingTokens(x) { if (!tokenSavers.remove(x)) { throw 'bad token saver'; } return x; }
    tokensText(List x) => x.map((x) => x.text).join();

    Token expect([String e1, String e2, String e3, String e4]){
      Token token = peek(e1, e2, e3, e4);
      if (token != null) {
        // TODO json
//        if (json && !token.json) {
//          throwError("is not valid json", token);
//        }
        var consumed = tokens.removeAt(0);
        tokenSavers.forEach((ts) => ts.add(consumed));
        return token;
      }
      return null;
    }

    ParsedFn consume(e1){
      if (expect(e1) == null) {
        throw parserError("Missing expected $e1");
        //throwError("is unexpected, expecting [" + e1 + "]", peek());
      }
    }

    var filterChain = null;
    var functionCall, arrayDeclaration, objectIndex, fieldAccess, object;

    ParsedFn primary() {
      var primary;
      var ts = saveTokens();
      if (expect('(') != null) {
        primary = filterChain();
        consume(')');
      } else if (expect('[') != null) {
        primary = arrayDeclaration();
      } else if (expect('{') != null) {
        primary = object();
      } else {
        Token token = expect();
        primary = token.primaryFn;
        if (primary == null) {
          throw parserError("Internal Angular Error: Unreachable code A.");
        }
      }

      // TODO(deboer): I don't think context applies to Dart..
      var next, context;
      while ((next = expect('(', '[', '.')) != null) {
        if (next.text == '(') {
          primary = functionCall(primary, tokensText(ts.sublist(0, ts.length - 1)));
          context = null;
        } else if (next.text == '[') {
          context = primary;
          primary = objectIndex(primary);
        } else if (next.text == '.') {
          context = primary;
          primary = fieldAccess(primary);
        } else {
          throw parserError("Internal Angular Error: Unreachable code B.");
        }
      }
      stopSavingTokens(ts);
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
      var ts = saveTokens();
      var left = logicalOR();
      stopSavingTokens(ts);
      var right;
      var token;
      if ((token = expect('=')) != null) {
        if (!left.assignable) {
          throw parserError('Expression ${tokensText(ts)} is not assignable', token);
        }
        right = logicalOR();
        return new ParsedFn((scope, locals) {
          try {
            return left.assign(scope, right(scope, locals), locals);
          } catch (e, s) {
            throw evalError('Caught $e', s);
          }
        });
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
        if ((token = expect('|')) != null) {
          //left = binaryFn(left, token.fn, filter());
          throw parserError("Filters are not implemented", token);
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

    functionCall = (fn, fnName) {
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
        if (userFn == null) {
          throw evalError("Undefined function $fnName");
        }
        if (userFn is! Function) {
          throw evalError("$fnName is not a function");
        }
        return relaxFnApply(userFn, args);
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
      // TODO(deboer): Combine these into a single function.
      getField(o, i) {
        if (o is List) {
          return o[i.toInt()];
        } else if (o is Map) {
          return o[i.toString()]; // toString dangerous?
        }
        throw evalError("Attempted field access on a non-list, non-map");
      }

      setField(o, i, v) {
        if (o is List) {
          int arrayIndex = i.toInt();
          if (o.length <= arrayIndex) { o.length = arrayIndex + 1; }
          o[arrayIndex] = v;
        } else if (o is Map) {
          o[i.toString()] = v; // toString dangerous?
        } else {
          throw evalError("Attempting to set a field on a non-list, non-map");
        }
        return v;
      }

      var indexFn = expression();
      consume(']');
      return new ParsedFn((self, locals){
            var i = indexFn(self, locals);
            var o = obj(self, locals),
                v, p;

            if (o == null) return throw evalError('Accessing null object');

            v = getField(o, i);

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
            setField(obj(self, locals), indexFn(self, locals), value)
          );

    };

    fieldAccess = (object) {
      var field = expect().text;
      //var getter = getter(field);
      return new ParsedFn((self, locals) => getter(object(self, locals), locals, field),
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
      throw parserError("Unconsumed token ${tokens[0].text}");
    }
    return value;
  }

}
