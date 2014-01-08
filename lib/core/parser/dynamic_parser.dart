library angular.core.parser.dynamic_parser;

import 'package:angular/core/module.dart' show FilterMap, NgInjectableService;

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/core/parser/dynamic_parser_impl.dart';

import 'package:angular/core/parser/eval.dart';
import 'package:angular/core/parser/utils.dart' show EvalError;

class ClosureMap {
  Getter lookupGetter(String name) => null;
  Setter lookupSetter(String name) => null;
  Function lookupFunction(String name, int arity) => null;
}

class DynamicParser implements Parser<Expression> {
  final Lexer _lexer;
  final ParserBackend _backend;
  final Map<String, Expression> _cache = {};
  DynamicParser(this._lexer, this._backend);

  Expression call(String input) {
    if (input == null) input = '';
    return _cache.putIfAbsent(input, () => _parse(input));
  }

  Expression _parse(String input) {
    DynamicParserImpl parser = new DynamicParserImpl(_lexer, _backend, input);
    Expression expression = parser.parseChain();
    return new DynamicExpression(expression);
  }
}

class DynamicExpression extends Expression {
  final Expression _expression;
  DynamicExpression(this._expression);

  bool get isAssignable => _expression.isAssignable;
  bool get isChain => _expression.isChain;

  accept(Visitor visitor) => _expression.accept(visitor);
  toString() => _expression.toString();

  eval(scope) {
    try {
      return _expression.eval(scope);
    } on EvalError catch (e, s) {
      throw e.unwrap("$this", s);
    }
  }

  assign(scope, value) {
    try {
      return _expression.assign(scope, value);
    } on EvalError catch (e, s) {
      throw e.unwrap("$this", s);
    }
  }
}

class DynamicParserBackend extends ParserBackend {
  final FilterMap _filters;
  final ClosureMap _closures;
  DynamicParserBackend(this._filters, this._closures);

  bool isAssignable(Expression expression)
      => expression.isAssignable;

  Expression newFilter(expression, name, arguments) {
    Function filter = _filters(name);
    List allArguments = new List(arguments.length + 1);
    allArguments[0] = expression;
    allArguments.setAll(1, arguments);
    return new Filter(expression, name, arguments, filter, allArguments);
  }

  Expression newChain(expressions)
      => new Chain(expressions);
  Expression newAssign(target, value)
      => new Assign(target, value);
  Expression newConditional(condition, yes, no)
      => new Conditional(condition, yes, no);

  Expression newAccessKeyed(object, key)
      => new AccessKeyed(object, key);
  Expression newCallFunction(function, arguments)
      => new CallFunction(function, arguments);

  Expression newPrefixNot(expression)
      => new PrefixNot(expression);

  Expression newBinary(operation, left, right)
      => new Binary(operation, left, right);

  Expression newLiteralPrimitive(value)
      => new LiteralPrimitive(value);
  Expression newLiteralArray(elements)
      => new LiteralArray(elements);
  Expression newLiteralObject(keys, values)
      => new LiteralObject(keys, values);
  Expression newLiteralString(value)
      => new LiteralString(value);


  Expression newAccessScope(name) {
    Getter getter = _closures.lookupGetter(name);
    Setter setter = _closures.lookupSetter(name);
    if (getter != null && setter != null) {
      return new AccessScopeFast(name, getter, setter);
    } else {
      return new AccessScope(name);
    }
  }

  Expression newAccessMember(object, name) {
    Getter getter = _closures.lookupGetter(name);
    Setter setter = _closures.lookupSetter(name);
    if (getter != null && setter != null) {
      return new AccessMemberFast(object, name, getter, setter);
    } else {
      return new AccessMember(object, name);
    }
  }

  Expression newCallScope(name, arguments) {
    Function constructor = _computeCallConstructor(
        _callScopeConstructors, name, arguments.length);
    return (constructor != null)
        ? constructor(name, arguments, _closures)
        : new CallScope(name, arguments);
  }

  Expression newCallMember(object, name, arguments) {
    Function constructor = _computeCallConstructor(
        _callMemberConstructors, name, arguments.length);
    return (constructor != null)
        ? constructor(object, name, arguments, _closures)
        : new CallMember(object, name, arguments);
  }

  Function _computeCallConstructor(Map constructors, String name, int arity) {
    Function function = _closures.lookupFunction(name, arity);
    return (function == null) ? null : constructors[arity];
  }

  static final Map<int, Function> _callScopeConstructors = {
      0: (n, a, c) => new CallScopeFast0(n, a, c.lookupFunction(n, 0)),
      1: (n, a, c) => new CallScopeFast1(n, a, c.lookupFunction(n, 1)),
  };

  static final Map<int, Function> _callMemberConstructors = {
      0: (o, n, a, c) => new CallMemberFast0(o, n, a, c.lookupFunction(n, 0)),
      1: (o, n, a, c) => new CallMemberFast1(o, n, a, c.lookupFunction(n, 1)),
  };
}

