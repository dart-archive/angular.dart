library angular.core.parser.static_parser;

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/utils.dart' show EvalError;

class StaticParserFunctions {
  final Map<String, Function> eval;
  final Map<String, Function> assign;
  StaticParserFunctions(this.eval, this.assign);
}

//@NgInjectableService()
class StaticParser implements Parser<Expression> {
  final StaticParserFunctions _functions;
  final DynamicParser _fallbackParser;
  final Map<String, Expression> _cache = {};
  StaticParser(this._functions, this._fallbackParser);

  Expression call(String input) {
    if (input == null) input = '';
    return _cache.putIfAbsent(input, () => _construct(input));
  }

  Expression _construct(String input) {
    var eval = _functions.eval[input];
    if (eval == null) return _fallbackParser(input);
    if (eval is !Function) throw eval;
    Function assign = _functions.assign[input];
    return new StaticExpression(input, eval, assign);
  }
}

class StaticExpression extends Expression {
  final String _input;
  final Function _eval;
  final Function _assign;
  StaticExpression(this._input, this._eval, [this._assign]);

  bool get isAssignable => _assign != null;
  accept(Visitor visitor) => throw "Cannot visit static expression $this";
  toString() => _input;

  eval(scope) {
    try {
      return _eval(scope);
    } on EvalError catch (e, s) {
      throw e.unwrap("$this", s);
    }
  }

  assign(scope, value) {
    try {
      if (_assign == null) throw new EvalError("Cannot assign to $this");
      return _assign(scope, value);
    } on EvalError catch (e, s) {
      throw e.unwrap("$this", s);
    }
  }
}