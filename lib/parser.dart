part of parser_library;


typedef ParsedGetter(self, [locals]);
typedef ParsedSetter(self, value, [locals]);

typedef Getter([locals]);
typedef Setter(value, [locals]);

class BoundExpression {
  var _context;
  Expression expression;

  BoundExpression(this._context, Expression this.expression);

  call([locals]) => expression.eval(_context, locals);
  assign(value, [locals]) => expression.assign(_context, value, locals);
}

class Expression {
  ParsedGetter eval;
  ParsedSetter assign;
  String exp;
  List parts;

  Expression(ParsedGetter this.eval, [ParsedSetter this.assign]);

  bind(context) => new BoundExpression(context, this);

  get assignable => assign != null;
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
typedef Operator(self, locals, Expression a, Expression b);

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
Operator NOT_IMPL_OP = (_, _x, _0, _1) { throw "Op not implemented"; };

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

Map<String, String> ESCAPE = {"n":"\n", "f":"\f", "r":"\r", "t":"\t", "v":"\v", "'":"'", '"':'"'};

Expression ZERO = new Expression((_, [_x]) => 0);

stripTrailingNulls(List l) {
  while (l.length > 0 && l.last == null) {
    l.removeLast();
  }
  return l;
}

var _undefined_ = new Symbol("UNDEFINED");

// Returns a tuple [found, value]
_getterChild(value, childKey) {
  if (value is List && childKey is num) {
    if (childKey < value.length) {
      return value[childKey];
    }
  } else if (value is Map) {
    // TODO: We would love to drop the 'is Map' for a more generic 'is Getter'
    if (childKey is String && value.containsKey(childKey)) {
      return value[childKey];
    }
  } else {
    InstanceMirror instanceMirror = reflect(value);
    Symbol curSym = new Symbol(childKey);

    try {
      // maybe it is a member field?
      return instanceMirror.getField(curSym).reflectee;
    } on NoSuchMethodError catch (e) {
      // maybe it is a member method?
      if (instanceMirror.type.members.containsKey(curSym)) {
        MethodMirror methodMirror = instanceMirror.type.members[curSym];
        return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
          var args = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
          return instanceMirror.invoke(curSym, args).reflectee;
        });
      }
      rethrow;
    }
  }
  return _undefined_;
}

getter(self, locals, path) {
  if (self == null) {
    return null;
  }

  List<String> pathKeys = path.split('.');
  var pathKeysLength = pathKeys.length;
  var value = _undefined_;

  if (pathKeysLength == 0) { return self; }

  var currentValue = self;
  for (var i = 0; i < pathKeysLength; i++) {
    var curKey = pathKeys[i];
    if (locals == null) {
      currentValue = _getterChild(currentValue, curKey);
    } else {
      currentValue = _getterChild(locals, curKey);
      locals = null;
      if (currentValue == _undefined_) {
        currentValue = _getterChild(self, curKey);
      }
    }
    if (currentValue == null || currentValue == _undefined_) { return null; }
  }
  return currentValue;
}

_setterChild(obj, childKey, value) {
  // TODO: replace with isInterface(value, Setter) when dart:mirrors
  // can support mixins.
  try {
    return obj[childKey] = value;
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
    var propertyObj = _getterChild(obj, key);
    if (propertyObj == null || propertyObj == _undefined_) {
      propertyObj = {};
      _setterChild(obj, key, propertyObj);
    }
    obj = propertyObj;
  }
  return _setterChild(obj, element.removeAt(0), setValue);
}


class ExpressionFactory {
  _op(opKey) => OPERATORS[opKey];

  Expression binaryFn(Expression left, String op, Expression right) =>
    new Expression((self, [locals]) => _op(op)(self, locals, left, right));

  Expression unaryFn(String op, Expression right) =>
      new Expression((self, [locals]) => _op(op)(self, locals, right, null));

  Expression assignment(Expression left, Expression right, evalError) =>
    new Expression((self, [locals]) {
      try {
        return left.assign(self, right.eval(self, locals), locals);
      } catch (e, s) {
        throw evalError('Caught $e', s);
      }
    });

  Expression multipleStatements(statements) =>
    new Expression((self, [locals]) {
      var value;
      for ( var i = 0; i < statements.length; i++) {
        var statement = statements[i];
        if (statement != null)
          value = statement.eval(self, locals);
      }
      return value;
    });

  Expression functionCall(fn, fnName, argsFn, evalError) =>
    new Expression((self, [locals]){
        List args = [];
        for ( var i = 0; i < argsFn.length; i++) {
          args.add(argsFn[i].eval(self, locals));
        }
        var userFn = fn.eval(self, locals);
        if (userFn == null) {
          throw evalError("Undefined function $fnName");
        }
        if (userFn is! Function) {
          throw evalError("$fnName is not a function");
        }
        return relaxFnApply(userFn, args);
      });

  Expression arrayDeclaration(elementFns) =>
    new Expression((self, [locals]){
        var array = [];
        for ( var i = 0; i < elementFns.length; i++) {
          array.add(elementFns[i].eval(self, locals));
        }
        return array;
      });

  Expression objectIndex(obj, indexFn, evalError) {
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

    return new Expression((self, [locals]){
      var i = indexFn.eval(self, locals);
      var o = obj.eval(self, locals),
      v, p;

      if (o == null) throw evalError('Accessing null object');

      v = getField(o, i);

      return v;
    }, (self, value, [locals]) =>
    setField(obj.eval(self, locals), indexFn.eval(self, locals), value)
    );
  }

  Expression fieldAccess(object, field) =>
    new Expression(
          (self, [locals]) =>
      getter(object.eval(self, locals), null, field),
          (self, value, [locals]) =>
      setter(object.eval(self, locals), field, value));

  Expression object(keyValues) =>
    new Expression((self, [locals]){
      var object = {};
      for ( var i = 0; i < keyValues.length; i++) {
        var keyValue = keyValues[i];
        var value = keyValue["value"].eval(self, locals);
        object[keyValue["key"]] = value;
      }
      return object;
    });

  Expression profiled(value, _perf, text) {
    var wrappedGetter = (s, [l]) =>
    _perf.time('angular.parser.getter', () => value.eval(s, l), text);
    var wrappedAssignFn = null;
    if (value.assign != null) {
      wrappedAssignFn = (s, v, [l]) =>
      _perf.time('angular.parser.assign',
          () => value.assign(s, v, l), text);
    }
    return new Expression(wrappedGetter, wrappedAssignFn);
  }

  Expression fromOperator(String op) =>
    new Expression((s, [l]) => OPERATORS[op](s, l, null, null));

  Expression getterSetter(key) =>
    new Expression(
        (self, [locals]) => getter(self, locals, key),
        (self, value, [locals]) => setter(self, key, value));

  Expression value(v) =>
    new Expression((self, [locals]) => v);

  zero() => ZERO;
}

class Parser {
  Profiler _perf;
  Lexer _lexer;
  ExpressionFactory _ef;

  Parser(Profiler this._perf, Lexer this._lexer, ExpressionFactory this._ef);

  primaryFromToken(Token token, parserError) {
    if (token.key != null) {
      return _ef.getterSetter(token.key);
    }
    if (token.opKey != null) {
      return _ef.fromOperator(token.opKey);
    }
    if (token.value != null) {
      return _ef.value(token.value);
    }
    if (token.text != null) {
      return _ef.value(token.text);
    }
    throw parserError("Internal Angular Error: Tokens should have keys, text or fns");
  }

  call(String text) {
    List<Token> tokens = _lexer.call(text);
    Token token;

    parserError(String s, [Token t]) {
      if (t == null && !tokens.isEmpty) t = tokens[0];
      String location = t == null ?
          'the end of the expression' :
          'at column ${t.index + 1} in';
      return 'Parser Error: $s $location [$text]';
    }
    evalError(String s, [stack]) => ['Eval Error: $s while evaling [$text]' +
        (stack != null ? '\n\nFROM:\n$stack' : '')];

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

    Expression consume(e1){
      if (expect(e1) == null) {
        throw parserError("Missing expected $e1");
      }
    }

    var filterChain = null;
    var functionCall, arrayDeclaration, objectIndex, fieldAccess, object;

    Expression primary() {
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

    Expression binaryFn(Expression left, String op, Expression right) =>
      _ef.binaryFn(left, op, right);

    Expression unaryFn(String op, Expression right) =>
      _ef.unaryFn(op, right);

    Expression unary() {
      var token;
      if (expect('+') != null) {
        return primary();
      } else if ((token = expect('-')) != null) {
        return binaryFn(_ef.zero(), token.opKey, unary());
      } else if ((token = expect('!')) != null) {
        return unaryFn(token.opKey, unary());
      } else {
        return primary();
      }
    }

    Expression multiplicative() {
      var left = unary();
      var token;
      while ((token = expect('*','/','%')) != null) {
        left = binaryFn(left, token.opKey, unary());
      }
      return left;
    }

    Expression additive() {
      var left = multiplicative();
      var token;
      while ((token = expect('+','-')) != null) {
        left = binaryFn(left, token.opKey, multiplicative());
      }
      return left;
    }

    Expression relational() {
      var left = additive();
      var token;
      if ((token = expect('<', '>', '<=', '>=')) != null) {
        left = binaryFn(left, token.opKey, relational());
      }
      return left;
    }

    Expression equality() {
      var left = relational();
      var token;
      if ((token = expect('==','!=')) != null) {
        left = binaryFn(left, token.opKey, equality());
      }
      return left;
    }

    Expression logicalAND() {
      var left = equality();
      var token;
      if ((token = expect('&&')) != null) {
        left = binaryFn(left, token.opKey, logicalAND());
      }
      return left;
    }

    Expression logicalOR() {
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

    Expression assignment() {
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
        return _ef.assignment(left, right, evalError);
      } else {
        return left;
      }
    }


    Expression expression() {
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
      List<Expression> statements = [];
      while (true) {
        if (tokens.length > 0 && peek('}', ')', ';', ']') == null)
          statements.add(filterChain());
        if (expect(';') == null) {
          return statements.length == 1
              ? statements[0]
              : _ef.multipleStatements(statements);
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
      return _ef.functionCall(fn, fnName, argsFn, evalError);
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
      return _ef.arrayDeclaration(elementFns);
    };

    objectIndex = (obj) {
      var indexFn = expression();
      consume(']');
      return _ef.objectIndex(obj, indexFn, evalError);
    };

    fieldAccess = (object) {
      var field = expect().text;
      //var getter = getter(field);
      return _ef.fieldAccess(object, field);
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
      return _ef.object(keyValues);
    };

    // TODO(deboer): json
    Expression value = statements();

    if (tokens.length != 0) {
      throw parserError("Unconsumed token ${tokens[0].text}");
    }
    if (_perf == null) return value;

    return _ef.profiled(value, _perf, text);
  }
}
