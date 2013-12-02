part of angular.core.parser;

typedef ParsedGetter(self, [locals]);
typedef ParsedSetter(self, value, [locals]);

typedef Getter([locals]);
typedef Setter(value, [locals]);

abstract class ParserAST {
  bool get assignable;
}

class Token {
  final int index;
  final String text;

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

typedef Operator(dynamic self, Map<String, dynamic>locals, ParserAST a, ParserAST b);

Operator NULL_OP = (_, _x, _0, _1) => null;
Operator NOT_IMPL_OP = (_, _x, _0, _1) { throw "Op not implemented"; };

// FUNCTIONS USED AT RUNTIME.

parserEvalError(String s, String text, stack) =>
  ['Eval Error: $s while evaling [$text]' +
      (stack != null ? '\n\nFROM:\n$stack' : '')];

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


Map<String, Operator> OPERATORS = {
  'undefined': NULL_OP,
  'null': NULL_OP,
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
  '~/': (s, l, a, b) => a.eval(s, l) ~/ b.eval(s, l),
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
  '!': (s, l, a, b) => !toBool(a.eval(s, l)),
  '?': (s, l, c, t, f) => toBool(c.eval(s, l)) ? t.eval(s, l) : f.eval(s, l),
};

@NgInjectableService()
class DynamicParser implements Parser {
  final Lexer _lexer;
  final ParserBackend _b;

  DynamicParser(Lexer this._lexer, ParserBackend this._b);

  List<Token> _tokens;
  String _text;
  var _evalError;

  Map<String, ParserAST> _cache = {};

  ParserAST call(String text) {
    var value = _cache[text];
    if (value != null) {
      return value;
    }
    return _cache[text] = _call(text);
  }

  ParserAST _call(String text) {
    try {
      if (text == null) text = '';
      _tokenSavers = [];
      _text = text;
      _tokens = _lexer.call(text);
      _evalError = (String s, [stack]) => parserEvalError(s, text, stack);

      ParserAST value = _statements();

      if (_tokens.length != 0) {
        throw _parserError("Unconsumed token ${_tokens[0].text}");
      }
      return value;
    } finally {
      _tokens = null;
      _text = null;
      _evalError = null;
      _tokenSavers = null;
    }
  }

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

  _parserError(String s, [Token t]) {
    if (t == null && !_tokens.isEmpty) t = _tokens[0];
    String location = t == null ?
      'the end of the expression' :
      'at column ${t.index + 1} in';
    return 'Parser Error: $s $location [$_text]';
  }


  Token _peekToken() {
    if (_tokens.length == 0)
      throw "Unexpected end of expression: " + _text;
    return _tokens[0];
  }

  Token _peek([String e1, String e2, String e3, String e4]) {
    if (_tokens.length > 0) {
      Token token = _tokens[0];
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
  List<List<Token>> _tokenSavers;
  List<Token> _saveTokens() { var n = []; _tokenSavers.add(n); return n; }
  _stopSavingTokens(x) { if (!_tokenSavers.remove(x)) { throw 'bad token saver'; } return x; }
  _tokensText(List x) => x.map((x) => x.text).join();


  Token _expect([String e1, String e2, String e3, String e4]){
    Token token = _peek(e1, e2, e3, e4);
    if (token != null) {
      var consumed = _tokens.removeAt(0);
      _tokenSavers.forEach((ts) => ts.add(consumed));
      return token;
    }
    return null;
  }

  ParserAST _consume(e1){
    if (_expect(e1) == null) {
      throw _parserError("Missing expected $e1");
    }
  }

  ParserAST _primary() {
    var primary;
    var ts = _saveTokens();
    if (_expect('(') != null) {
      primary = _filterChain();
      _consume(')');
    } else if (_expect('[') != null) {
      primary = _arrayDeclaration();
    } else if (_expect('{') != null) {
      primary = _object();
    } else {
      Token token = _expect();
      primary = primaryFromToken(token, _parserError);
      if (primary == null) {
        throw _parserError("Internal Angular Error: Unreachable code A.");
      }
    }

    var next;
    while ((next = _expect('(', '[', '.')) != null) {
      if (next.text == '(') {
        primary = _functionCall(primary, _tokensText(ts.sublist(0, ts.length - 1)));
      } else if (next.text == '[') {
        primary = _objectIndex(primary);
      } else if (next.text == '.') {
        primary = _fieldAccess(primary);
      } else {
        throw _parserError("Internal Angular Error: Unreachable code B.");
      }
    }
    _stopSavingTokens(ts);
    return primary;
  }

  ParserAST _binaryFn(ParserAST left, String op, ParserAST right) =>
      _b.binaryFn(left, op, right);

  ParserAST _unaryFn(String op, ParserAST right) =>
      _b.unaryFn(op, right);

  ParserAST _unary() {
    var token;
    if (_expect('+') != null) {
      return _primary();
    } else if ((token = _expect('-')) != null) {
      return _binaryFn(_b.zero(), token.opKey, _unary());
    } else if ((token = _expect('!')) != null) {
      return _unaryFn(token.opKey, _unary());
    } else {
      return _primary();
    }
  }

  ParserAST _multiplicative() {
    var left = _unary();
    var token;
    while ((token = _expect('*','%','/','~/')) != null) {
      left = _binaryFn(left, token.opKey, _unary());
    }
    return left;
  }

  ParserAST _additive() {
    var left = _multiplicative();
    var token;
    while ((token = _expect('+','-')) != null) {
      left = _binaryFn(left, token.opKey, _multiplicative());
    }
    return left;
  }

  ParserAST _relational() {
    var left = _additive();
    var token;
    if ((token = _expect('<', '>', '<=', '>=')) != null) {
      left = _binaryFn(left, token.opKey, _relational());
    }
    return left;
  }

  ParserAST _equality() {
    var left = _relational();
    var token;
    if ((token = _expect('==','!=')) != null) {
      left = _binaryFn(left, token.opKey, _equality());
    }
    return left;
  }

  ParserAST _logicalAND() {
    var left = _equality();
    var token;
    if ((token = _expect('&&')) != null) {
      left = _binaryFn(left, token.opKey, _logicalAND());
    }
    return left;
  }

  ParserAST _logicalOR() {
    var left = _logicalAND();
    var token;
    while(true) {
      if ((token = _expect('||')) != null) {
        left = _binaryFn(left, token.opKey, _logicalAND());
      } else {
        return left;
      }
    }
  }

  ParserAST _ternary() {
    var ts = _saveTokens();
    var cond = _logicalOR();
    var token = _expect('?');
    if (token != null) {
      var _true = _expression();
      if ((token = _expect(':')) != null) {
        cond = _b.ternaryFn(cond, _true, _expression());
      } else {
        throw _parserError('Conditional expression ${_tokensText(ts)} requires '
                           'all 3 expressions');
      }
    }
    _stopSavingTokens(ts);
    return cond;
  }

  ParserAST _assignment() {
    var ts = _saveTokens();
    var left = _ternary();
    _stopSavingTokens(ts);
    var right;
    var token;
    if ((token = _expect('=')) != null) {
      if (!left.assignable) {
        throw _parserError('Expression ${_tokensText(ts)} is not assignable', token);
      }
      right = _ternary();
      return _b.assignment(left, right, _evalError);
    } else {
      return left;
    }
  }


  ParserAST _expression() {
    return _assignment();
  }

  _filterChain() {
    var left = _expression();
    var token;
    while(true) {
      if ((token = _expect('|')) != null) {
        left = _filter(left);
      } else {
        return left;
      }
    }
  }

  ParserAST _filter(ParserAST left) {
    var token = _expect();
    var filterName = token.text;
    var argsFn = [];
    while(true) {
      if ((token = _expect(':')) != null) {
        argsFn.add(_expression());
      } else {
        return _b.filter(filterName, left, argsFn, _evalError);
      }
    }
  }


  _statements() {
    List<ParserAST> statements = [];
    while (true) {
      if (_tokens.length > 0 && _peek('}', ')', ';', ']') == null)
        statements.add(_filterChain());
      if (_expect(';') == null) {
        return statements.length == 1
        ? statements[0]
        : _b.multipleStatements(statements);
      }
    }
  }

  _functionCall(fn, fnName) {
    var argsFn = [];
    if (_peekToken().text != ')') {
      do {
        argsFn.add(_expression());
      } while (_expect(',') != null);
    }
    _consume(')');
    return _b.functionCall(fn, fnName, argsFn, _evalError);
  }

  // This is used with json array declaration
  _arrayDeclaration() {
    var elementFns = [];
    if (_peekToken().text != ']') {
      do {
        elementFns.add(_expression());
      } while (_expect(',') != null);
    }
    _consume(']');
    return _b.arrayDeclaration(elementFns);
  }

  _objectIndex(obj) {
    var indexFn = _expression();
    _consume(']');
    return _b.objectIndex(obj, indexFn, _evalError);
  }

  _fieldAccess(object) {
    var field = _expect().text;
    //var getter = getter(field);
    return _b.fieldAccess(object, field);
  }

  _object() {
    var keyValues = [];
    if (_peekToken().text != '}') {
      do {
        var token = _expect(),
        key = token.value != null && token.value is String ? token.value : token.text;
        _consume(":");
        var value = _expression();
        keyValues.add({"key":key, "value":value});
      } while (_expect(',') != null);
    }
    _consume('}');
    return _b.object(keyValues);
  }

}
