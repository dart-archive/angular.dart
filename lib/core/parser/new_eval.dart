library angular.core.new_parser.new_eval;

import 'package:angular/core/module.dart' show FilterMap, NgInjectableService;
import 'package:angular/core/parser/parser.dart' show autoConvertAdd;

import 'package:angular/core/parser/new_parser.dart';
import 'package:angular/core/parser/new_syntax.dart';

import 'package:angular/core/parser/new_eval_access.dart' as access;
import 'package:angular/core/parser/new_eval_call.dart' as calls;
import 'package:angular/core/parser/new_eval_utils.dart';

export 'package:angular/core/parser/new_parser.dart';

typedef Getter(object);
typedef Setter(object, value);

class ClosureMap {
  Getter lookupGetter(String name) => null;
  Setter lookupSetter(String name) => null;
  Function lookupFunction(String name, int arity) => null;
}

class EvalError {
  final String message;
  EvalError(this.message);
}

abstract class Evaluatable implements Expression {
  evaluate(scope);
  assign(scope, value) => throw new EvalError("Cannot assign to $this");
}

@NgInjectableService()
class ParserBackendForEvaluation extends ParserBackend {
  final FilterMap _filters;
  final ClosureMap _closures;
  ParserBackendForEvaluation(this._filters, this._closures);

  Evaluatable newFilter(expression, name, arguments) {
    Function filter = _filters(name);
    List allArguments = new List(arguments.length + 1);
    allArguments[0] = expression;
    allArguments.setAll(1, arguments);
    return new _Filter(expression, name, arguments, filter, allArguments);
  }

  Evaluatable newChain(expressions)
      => new _Chain(expressions);
  Evaluatable newAssign(target, value)
      => new _Assign(target, value);
  Evaluatable newConditional(condition, yes, no)
      => new _Conditional(condition, yes, no);

  Evaluatable newAccessScope(name)
      => access.newAccessScope(_closures, name);
  Evaluatable newAccessMember(object, name)
      => access.newAccessMember(_closures, object, name);
  Evaluatable newAccessKeyed(object, key)
      => access.newAccessKeyed(object, key);

  Evaluatable newCallScope(name, arguments)
      => calls.newCallScope(_closures, name, arguments);
  Evaluatable newCallFunction(function, arguments)
      => calls.newCallFunction(function, arguments);
  Evaluatable newCallMember(object, name, arguments)
      => calls.newCallMember(_closures, object, name, arguments);

  Evaluatable newPrefixNot(expression)
      => new _PrefixNot(expression);

  Evaluatable newBinary(operation, left, right)
      => new _Binary(operation, left, right);

  Evaluatable newLiteralPrimitive(value)
      => new _LiteralPrimitive(value);
  Evaluatable newLiteralArray(elements)
      => new _LiteralArray(elements);
  Evaluatable newLiteralObject(keys, values)
      => new _LiteralObject(keys, values);
  Evaluatable newLiteralString(value)
      => new _LiteralString(value);
}

class _Chain extends Chain with Evaluatable {
  _Chain(expressions) : super(expressions);

  evaluate(scope) {
    var result;
    for (int i = 0, length = expressions.length; i < length; i++) {
      var last = E(scope, expressions[i]);
      if (last != null) result = last;
    }
    return result;
  }
}

class _Filter extends Filter with Evaluatable {
  final Function function;
  final List allArguments;
  _Filter(expression, name, arguments, this.function, this.allArguments)
      : super(expression, name, arguments);
  evaluate(scope) => Function.apply(function, EL(scope, allArguments));
}

class _Assign extends Assign with Evaluatable {
  _Assign(target, value) : super(target, value);
  evaluate(scope) => A(scope, target, value);
}

class _Conditional extends Conditional with Evaluatable {
  _Conditional(condition, yes, no) : super(condition, yes, no);
  evaluate(scope) => toBool(E(scope, condition)) ? E(scope, yes) : E(scope, no);
}

class _PrefixNot extends Prefix with Evaluatable {
  _PrefixNot(expression) : super('!', expression);
  evaluate(scope) => !toBool(E(scope, expression));
}

class _Binary extends Binary with Evaluatable {
  _Binary(operation, left, right) : super(operation, left, right);

  evaluate(scope) {
    var left = E(scope, this.left);
    switch (operation) {
      case '&&': return toBool(left) && toBool(E(scope, this.right));
      case '||': return toBool(left) || toBool(E(scope, this.right));
    }
    var right = E(scope, this.right);
    switch (operation) {
      case '+'  : return autoConvertAdd(left, right);
      case '-'  : return left - right;
      case '*'  : return left * right;
      case '/'  : return left / right;
      case '~/' : return left ~/ right;
      case '%'  : return left % right;
      case '==' : return left == right;
      case '!=' : return left != right;
      case '<'  : return left < right;
      case '>'  : return left > right;
      case '<=' : return left <= right;
      case '>=' : return left >= right;
      case '^'  : return left ^ right;
      case '&'  : return left & right;
    }
    throw new EvalError('Internal error [$operation] not handled');
  }
}

class _LiteralPrimitive extends LiteralPrimitive with Evaluatable {
  _LiteralPrimitive(value) : super(value);
  evaluate(scope) => value;
}

class _LiteralString extends LiteralString with Evaluatable {
  _LiteralString(value) : super(value);
  evaluate(scope) => value;
}

class _LiteralArray extends LiteralArray with Evaluatable {
  _LiteralArray(elements) : super(elements);
  evaluate(scope) => elements.map((e) => E(scope, e)).toList();
}

class _LiteralObject extends LiteralObject with Evaluatable {
  _LiteralObject(keys, values) : super(keys, values);
  evaluate(scope) => new Map.fromIterables(keys, values.map((e) => E(scope, e)));
}
