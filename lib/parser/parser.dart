part of parser_library;

typedef ParsedGetter(self, [locals]);
typedef ParsedSetter(self, value, [locals]);

typedef Getter([locals]);
typedef Setter(value, [locals]);

abstract class ParserAST {
  bool get assignable;
}

class Token {
  bool json;
  int index;
  String text;
  var value;
  // Tokens should have one of these set.
  String opKey;
  String key;

  Token(this.index, this.text);

  withOp(op) {
    this.opKey = op;
  }

  withGetterSetter(key) {
    this.key = key;
  }

  withValue(value) { this.value = value; }

  toString() => "Token($text)";
}

// TODO(deboer): Type this typedef further
typedef Operator(self, locals, ParserAST a, ParserAST b);

Operator NULL_OP = (_, _x, _0, _1) => null;
Operator NOT_IMPL_OP = (_, _x, _0, _1) { throw "Op not implemented"; };

// FUNCTIONS USED AT RUNTIME.

parserEvalError(String s, String text, stack) =>
  ['Eval Error: $s while evaling [$text]' +
      (stack != null ? '\n\nFROM:\n$stack' : '')];

toBool(x) {
  if (x is bool) return x;
  if (x is int || x is double) return x != 0;
  return false;
}

// Automatic type conversion.
autoConvertAdd(a, b) {
  if (a != null && b != null) {
    // TODO(deboer): Support others.
    if (a is String && b is! String) {
      return a + b.toString();
    }
    if (a is! String && b is String) {
      return a.toString() + b;
    }
    return a + b;
  }
  if (a != null) return a;
  if (b != null) return b;
  return null;
}

objectIndexGetField(o, i, evalError) {
  if (o == null) throw evalError('Accessing null object');

  if (o is List) {
    return o[i.toInt()];
  } else if (o is Map) {
    return o[i.toString()]; // toString dangerous?
  }
  throw evalError("Attempted field access on a non-list, non-map");
}

objectIndexSetField(o, i, v, evalError) {
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

safeFunctionCall(userFn, fnName, evalError) {
  if (userFn == null) {
    throw evalError("Undefined function $fnName");
  }
  if (userFn is! Function) {
    throw evalError("$fnName is not a function");
  }
  return userFn;
}

var undefined_ = new Symbol("UNDEFINED");

Map<String, Operator> OPERATORS = {
  'undefined': NULL_OP,
  'true': (self, locals, a, b) => true,
  'false': (self, locals, a, b) => false,
  '+': (self, locals, aFn, bFn) {
    var a = aFn.eval(self, locals);
    var b = bFn.eval(self, locals);
    return autoConvertAdd(a, b);
  },
  '-': (self, locals, a, b) {
    assert(a != null || b != null);
    var aResult = a != null ? a.eval(self, locals) : null;
    var bResult = b != null ? b.eval(self, locals) : null;
    return (aResult == null ? 0 : aResult) - (bResult == null ? 0 : bResult);
  },
  '*': (s, l, a, b) => a.eval(s, l) * b.eval(s, l),
  '/': (s, l, a, b) => a.eval(s, l) / b.eval(s, l),
  '%': (s, l, a, b) => a.eval(s, l) % b.eval(s, l),
  '^': (s, l, a, b) => a.eval(s, l) ^ b.eval(s, l),
  '=': NULL_OP,
  '==': (s, l, a, b) => a.eval(s, l) == b.eval(s, l),
  '!=': (s, l, a, b) => a.eval(s, l) != b.eval(s, l),
  '<': (s, l, a, b) => a.eval(s, l) < b.eval(s, l),
  '>': (s, l, a, b) => a.eval(s, l) > b.eval(s, l),
  '<=': (s, l, a, b) => a.eval(s, l) <= b.eval(s, l),
  '>=': (s, l, a, b) => a.eval(s, l) >= b.eval(s, l),
  '&&': (s, l, a, b) => toBool(a.eval(s, l)) && toBool(b.eval(s, l)),
  '||': (s, l, a, b) => toBool(a.eval(s, l)) || toBool(b.eval(s, l)),
  '&': (s, l, a, b) => a.eval(s, l) & b.eval(s, l),
  '|': NOT_IMPL_OP, //b(locals)(locals, a(locals))
  '!': (self, locals, a, b) => !toBool(a.eval(self, locals))
};

class DynamicParser implements Parser {
  Profiler _perf;
  Lexer _lexer;
  ParserBackend _b;

  DynamicParser(Profiler this._perf, Lexer this._lexer, ParserBackend this._b);

  primaryFromToken(Token token, parserError) {
    if (token.key != null) {
      return _b.getterSetter(token.key);
    }
    if (token.opKey != null) {
      return _b.fromOperator(token.opKey);
    }
    if (token.value != null) {
      return _b.value(token.value);
    }
    if (token.text != null) {
      return _b.value(token.text);
    }
    throw parserError("Internal Angular Error: Tokens should have keys, text or fns");
  }

  call(String text) {
    if (text == null) text = '';
    List<Token> tokens = _lexer.call(text);
    Token token;

    parserError(String s, [Token t]) {
      if (t == null && !tokens.isEmpty) t = tokens[0];
      String location = t == null ?
          'the end of the expression' :
          'at column ${t.index + 1} in';
      return 'Parser Error: $s $location [$text]';
    }
    evalError(String s, [stack]) => parserEvalError(s, text, stack);

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

    ParserAST consume(e1){
      if (expect(e1) == null) {
        throw parserError("Missing expected $e1");
      }
    }

    var filterChain = null;
    var functionCall, arrayDeclaration, objectIndex, fieldAccess, object;

    ParserAST primary() {
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
        primary = primaryFromToken(token, parserError);
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

    ParserAST binaryFn(ParserAST left, String op, ParserAST right) =>
      _b.binaryFn(left, op, right);

    ParserAST unaryFn(String op, ParserAST right) =>
      _b.unaryFn(op, right);

    ParserAST unary() {
      var token;
      if (expect('+') != null) {
        return primary();
      } else if ((token = expect('-')) != null) {
        return binaryFn(_b.zero(), token.opKey, unary());
      } else if ((token = expect('!')) != null) {
        return unaryFn(token.opKey, unary());
      } else {
        return primary();
      }
    }

    ParserAST multiplicative() {
      var left = unary();
      var token;
      while ((token = expect('*','/','%')) != null) {
        left = binaryFn(left, token.opKey, unary());
      }
      return left;
    }

    ParserAST additive() {
      var left = multiplicative();
      var token;
      while ((token = expect('+','-')) != null) {
        left = binaryFn(left, token.opKey, multiplicative());
      }
      return left;
    }

    ParserAST relational() {
      var left = additive();
      var token;
      if ((token = expect('<', '>', '<=', '>=')) != null) {
        left = binaryFn(left, token.opKey, relational());
      }
      return left;
    }

    ParserAST equality() {
      var left = relational();
      var token;
      if ((token = expect('==','!=')) != null) {
        left = binaryFn(left, token.opKey, equality());
      }
      return left;
    }

    ParserAST logicalAND() {
      var left = equality();
      var token;
      if ((token = expect('&&')) != null) {
        left = binaryFn(left, token.opKey, logicalAND());
      }
      return left;
    }

    ParserAST logicalOR() {
      var left = logicalAND();
      var token;
      while(true) {
        if ((token = expect('||')) != null) {
          left = binaryFn(left, token.opKey, logicalAND());
        } else {
          return left;
        }
      }
    }

    // =========================
    // =========================

    ParserAST assignment() {
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
        return _b.assignment(left, right, evalError);
      } else {
        return left;
      }
    }


    ParserAST expression() {
      return assignment();
    }

    filterChain = () {
      var left = expression();
      var token;
      while(true) {
        if ((token = expect('|')) != null) {
          //left = binaryFn(left, token.opKey, filter());
          throw parserError("Filters are not implemented", token);
        } else {
          return left;
        }
      }
    };

    statements() {
      List<ParserAST> statements = [];
      while (true) {
        if (tokens.length > 0 && peek('}', ')', ';', ']') == null)
          statements.add(filterChain());
        if (expect(';') == null) {
          return statements.length == 1
              ? statements[0]
              : _b.multipleStatements(statements);
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
      return _b.functionCall(fn, fnName, argsFn, evalError);
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
      return _b.arrayDeclaration(elementFns);
    };

    objectIndex = (obj) {
      var indexFn = expression();
      consume(']');
      return _b.objectIndex(obj, indexFn, evalError);
    };

    fieldAccess = (object) {
      var field = expect().text;
      //var getter = getter(field);
      return _b.fieldAccess(object, field);
    };

    object = () {
      var keyValues = [];
      if (peekToken().text != '}') {
        do {
          var token = expect(),
              key = token.value != null && token.value is String ? token.value : token.text;
          consume(":");
          var value = expression();
          keyValues.add({"key":key, "value":value});
        } while (expect(',') != null);
      }
      consume('}');
      return _b.object(keyValues);
    };

    // TODO(deboer): json
    ParserAST value = statements();

    if (tokens.length != 0) {
      throw parserError("Unconsumed token ${tokens[0].text}");
    }
    if (_perf == null) return value;

    return _b.profiled(value, _perf, text);
  }
}
