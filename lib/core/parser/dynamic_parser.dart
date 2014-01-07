part of angular.core.parser;

typedef ParsedGetter(self);
typedef ParsedSetter(self, value);

typedef Getter([locals]);
typedef Setter(value, [locals]);

abstract class ParserAST {
  bool get assignable;
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

@NgInjectableService()
class DynamicParser implements Parser {
  final new_parser.Parser _newParser;
  final Map<String, ParserAST> _cache = {};
  DynamicParser(this._newParser);

  ParserAST call(String text) {
    if (text == null) text = '';
    var value = _cache[text];
    if (value != null) {
      return value;
    }
    return _cache[text] = _call(text);
  }

  ParserAST _call(String text) {
    var newExpression = _newParser.parse(text);
    evaluate(scope) {
      try {
        return newExpression.evaluate(scope);
      } on new_parser.EvalError catch (e, s) {
        throw _parserEvalError(e.message, text, s);
      }
    }
    assign(scope, value) {
      try {
        return newExpression.assign(scope, value);
      } on new_parser.EvalError catch (e, s) {
        throw _parserEvalError(e.message, text, s);
      }
    }
    return _newParser.backend.isAssignable(newExpression)
        ? new Expression(evaluate, assign)
        : new Expression(evaluate);
  }

  static _parserEvalError(String s, String text, stack) =>
      ['Eval Error: $s while evaling [$text]' +
       (stack != null ? '\n\nFROM:\n$stack' : '')];

}