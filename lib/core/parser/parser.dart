library angular.core.parser;

import 'package:di/annotations.dart';
import 'package:angular/core/parser/syntax.dart'
    show defaultFormatterMap, Expression, Visitor, CallArguments;
import 'package:angular/core/parser/eval.dart';
import 'package:angular/core/parser/utils.dart' show EvalError;
import 'package:angular/cache/module.dart';
import 'package:angular/core/annotation_src.dart' hide Formatter;
import 'package:angular/core/module_internal.dart' show
    FormatterMap,
    ContextLocals;

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/core/parser/parse_expression.dart';
import 'package:angular/utils.dart';

export 'package:angular/core/parser/syntax.dart'
    show Visitor, Expression, BoundExpression, CallArguments;

typedef LocalsWrapper(context, locals);
typedef Getter(self);
typedef Setter(self, value);
typedef BoundGetter([locals]);
typedef BoundSetter(value, [locals]);
typedef MethodClosure(obj, List posArgs, Map namedArgs);

abstract class ClosureMap {
  Getter lookupGetter(String name);
  Setter lookupSetter(String name);
  Symbol lookupSymbol(String name);
  MethodClosure lookupFunction(String name, CallArguments arguments);
}

abstract class ParserBackend<T> {
  bool isAssignable(T expression);

  T newChain(List expressions) => null;
  T newFormatter(T expression, String name, List arguments) => null;

  T newAssign(T target, T value) => null;
  T newConditional(T condition, T yes, T no) => null;

  T newAccessScope(String name) => null;
  T newAccessMember(T object, String name) => null;
  T newAccessKeyed(T object, T key) => null;

  T newCallScope(String name, CallArguments arguments) => null;
  T newCallFunction(T function, CallArguments arguments) => null;
  T newCallMember(T object, String name, CallArguments arguments) => null;

  T newPrefix(String operation, T expression) => null;
  T newPrefixPlus(T expression) => expression;
  T newPrefixMinus(T expression) =>
      newBinaryMinus(newLiteralZero(), expression);
  T newPrefixNot(T expression) => newPrefix('!', expression);

  T newBinary(String operation, T left, T right) => null;
  T newBinaryPlus(T left, T right) => newBinary('+', left, right);
  T newBinaryMinus(T left, T right) => newBinary('-', left, right);
  T newBinaryMultiply(T left, T right) => newBinary('*', left, right);
  T newBinaryDivide(T left, T right) => newBinary('/', left, right);
  T newBinaryModulo(T left, T right) => newBinary('%', left, right);
  T newBinaryTruncatingDivide(T left, T right) => newBinary('~/', left, right);
  T newBinaryLogicalAnd(T left, T right) => newBinary('&&', left, right);
  T newBinaryLogicalOr(T left, T right) => newBinary('||', left, right);
  T newBinaryEqual(T left, T right) => newBinary('==', left, right);
  T newBinaryNotEqual(T left, T right) => newBinary('!=', left, right);
  T newBinaryLessThan(T left, T right) => newBinary('<', left, right);
  T newBinaryGreaterThan(T left, T right) => newBinary('>', left, right);
  T newBinaryLessThanEqual(T left, T right) => newBinary('<=', left, right);
  T newBinaryGreaterThanEqual(T left, T right) => newBinary('>=', left, right);

  T newLiteralPrimitive(value) => null;
  T newLiteralArray(List elements) => null;
  T newLiteralObject(List<String> keys, List values) => null;
  T newLiteralNull() => newLiteralPrimitive(null);
  T newLiteralZero() => newLiteralNumber(0);
  T newLiteralBoolean(bool value) => newLiteralPrimitive(value);
  T newLiteralNumber(num value) => newLiteralPrimitive(value);
  T newLiteralString(String value) => null;
}

@Injectable()
class Parser {
  final Lexer _lexer;
  final ParserBackend _backend;
  final Map<String, Expression> _cache = {};
  Parser(this._lexer, this._backend, CacheRegister cacheRegister) {
    cacheRegister.registerCache("Parser", _cache);
  }

  Expression call(String input) {
    if (input == null) input = '';
    return _cache.putIfAbsent(input, () => _parse(input));
  }

  Expression _parse(String input) {
    Expression expression = parseExpression(_lexer, _backend, input);
    return new _UnwrapExceptionDecorator(expression);
  }
}

class _UnwrapExceptionDecorator extends Expression {
  final Expression _expression;
  _UnwrapExceptionDecorator (this._expression);

  bool get isAssignable => _expression.isAssignable;
  bool get isChain => _expression.isChain;

  accept(Visitor visitor) => _expression.accept(visitor);
  toString() => _expression.toString();

  eval(scope, [FormatterMap formatters = defaultFormatterMap]) {
    try {
      return _expression.eval(scope, formatters);
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

@Injectable()
class RuntimeParserBackend extends ParserBackend {
  final ClosureMap _closures;
  RuntimeParserBackend(ClosureMap _closures): _closures = new ClosureMapLocalsAware(_closures);

  bool isAssignable(Expression expression) => expression.isAssignable;

  Expression newFormatter(expression, name, arguments) {
    List allArguments = new List(arguments.length + 1);
    allArguments[0] = expression;
    allArguments.setAll(1, arguments);
    return new Formatter(expression, name, arguments, allArguments);
  }

  Expression newChain(expressions) => new Chain(expressions);
  Expression newAssign(target, value) => new Assign(target, value);
  Expression newConditional(condition, yes, no) =>
      new Conditional(condition, yes, no);

  Expression newAccessKeyed(object, key) => new AccessKeyed(object, key);
  Expression newCallFunction(function, arguments) =>
      new CallFunction(function, _closures, arguments);

  Expression newPrefixNot(expression) => new PrefixNot(expression);

  Expression newBinary(operation, left, right) =>
      new Binary(operation, left, right);

  Expression newLiteralPrimitive(value) => new LiteralPrimitive(value);
  Expression newLiteralArray(elements) => new LiteralArray(elements);
  Expression newLiteralObject(keys, values) => new LiteralObject(keys, values);
  Expression newLiteralString(value) => new LiteralString(value);

  Expression newAccessScope(name) {
    Getter getter;
    Setter setter;
    if (name == 'this') {
      getter = (o) => o;
    } else {
      _assertNotReserved(name);
      getter = _closures.lookupGetter(name);
      setter = _closures.lookupSetter(name);
    }
    return new AccessScopeFast(name, getter, setter);
  }

  Expression newAccessMember(object, name) {
    _assertNotReserved(name);
    Getter getter = _closures.lookupGetter(name);
    Setter setter = _closures.lookupSetter(name);
    return new AccessMemberFast(object, name, getter, setter);
  }

  Expression newCallScope(name, arguments) {
    _assertNotReserved(name);
    MethodClosure function = _closures.lookupFunction(name, arguments);
    return new CallScope(name, function, arguments);
  }

  Expression newCallMember(object, name, arguments) {
    _assertNotReserved(name);
    MethodClosure function = _closures.lookupFunction(name, arguments);
    return new CallMember(object, function, name, arguments);
  }

  _assertNotReserved(name) {
    if (isReservedWord(name)) {
      throw "Identifier '$name' is a reserved word.";
    }
  }
}

// todo(vicb) Would probably be better to remove this from the parser
class ClosureMapLocalsAware implements ClosureMap {
  final ClosureMap wrappedClsMap;

  ClosureMapLocalsAware(this.wrappedClsMap);

  Getter lookupGetter(String name) {
    return (o) {
      while (o is ContextLocals) {
        var ctx = o as ContextLocals;
        if (ctx.hasProperty(name)) return ctx[name];
        o = ctx.parentContext;
      }
      var getter = wrappedClsMap.lookupGetter(name);
      return getter(o);
    };
  }

  Setter lookupSetter(String name) {
    return (o, value) {
      while (o is ContextLocals) {
        var ctx = o as ContextLocals;
        if (ctx.hasProperty(name)) return ctx[name] = value;
        o = ctx.parentContext;
      }
      var setter = wrappedClsMap.lookupSetter(name);
      return setter(o, value);
    };
  }

  MethodClosure lookupFunction(String name, CallArguments arguments) {
    return (o, pArgs, nArgs) {
      while (o is ContextLocals) {
        var ctx = o as ContextLocals;
        if (ctx.hasProperty(name)) {
          var fn = ctx[name];
          if (fn is Function) {
            var snArgs = {};
            nArgs.forEach((name, value) {
              var symbol = wrappedClsMap.lookupGetter(name);
              snArgs[symbol] = value;
            });
            return Function.apply(fn, pArgs, snArgs);
          } else {
            throw "Property '$name' is not of type function.";
          }
        }
        o = ctx.parentContext;
      }
      var fn = wrappedClsMap.lookupFunction(name, arguments);
      return fn(o, pArgs, nArgs);
    };
  }

  Symbol lookupSymbol(String name) => wrappedClsMap.lookupSymbol(name);
}


