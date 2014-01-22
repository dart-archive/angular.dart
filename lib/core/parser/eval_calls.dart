library angular.core.parser.eval_calls;

import 'dart:mirrors';
import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';

class CallScope extends syntax.CallScope with CallReflective {
  final Symbol symbol;
  CallScope(name, arguments)
      : super(name, arguments)
      , symbol = new Symbol(name);
  eval(scope) => _eval(scope, scope);
}

class CallMember extends syntax.CallMember with CallReflective {
  final Symbol symbol;
  CallMember(object, name, arguments)
      : super(object, name, arguments)
      , symbol = new Symbol(name);
  eval(scope) => _eval(scope, object.eval(scope));
}

class CallScopeFast0 extends syntax.CallScope with CallFast {
  final Function function;
  CallScopeFast0(name, arguments, this.function) : super(name, arguments);
  eval(scope) => _evaluate0(scope);
}

class CallScopeFast1 extends syntax.CallScope with CallFast {
  final Function function;
  CallScopeFast1(name, arguments, this.function) : super(name, arguments);
  eval(scope) => _evaluate1(scope, arguments[0].eval(scope));
}

class CallMemberFast0 extends syntax.CallMember with CallFast {
  final Function function;
  CallMemberFast0(object, name, arguments, this.function)
      : super(object, name, arguments);
  eval(scope) => _evaluate0(object.eval(scope));
}

class CallMemberFast1 extends syntax.CallMember with CallFast {
  final Function function;
  CallMemberFast1(object, name, arguments, this.function)
      : super(object, name, arguments);
  eval(scope) => _evaluate1(object.eval(scope),
      arguments[0].eval(scope));
}

class CallFunction extends syntax.CallFunction {
  CallFunction(function, arguments) : super(function, arguments);
  eval(scope) {
    var function  = this.function.eval(scope);
    if (function is !Function) {
      throw new EvalError('${this.function} is not a function');
    } else {
      return relaxFnApply(function, evalList(scope, arguments));
    }
  }
}


/**
 * The [CallReflective] mixin is used to share code between call expressions
 * where we need to use reflection to do the invocation. We optimize for the
 * case where we invoke a method on the same holder repeatedly through caching.
 */
abstract class CallReflective {
  static const int CACHED_MAP = 0;
  static const int CACHED_FUNCTION = 1;

  int _cachedKind = 0;
  var _cachedHolder = UNINITIALIZED;
  var _cachedValue;

  String get name;
  Symbol get symbol;
  List get arguments;

  _eval(scope, holder) {
    List arguments = evalList(scope, this.arguments);
    if (!identical(holder, _cachedHolder)) {
      return _evaluteUncached(holder, arguments);
    }
    return (_cachedKind == CACHED_MAP)
        ? relaxFnApply(ensureFunctionFromMap(holder, name), arguments)
        : _cachedValue.invoke(symbol, arguments).reflectee;
  }

  _evaluteUncached(holder, arguments) {
    _cachedHolder = holder;
    if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      return relaxFnApply(ensureFunctionFromMap(holder, name), arguments);
    } else {
      InstanceMirror mirror = reflect(holder);
      _cachedKind = CACHED_FUNCTION;
      _cachedValue = mirror;
      return mirror.invoke(symbol, arguments).reflectee;
    }
  }
}


/**
 * The [CallFast] mixin is used to share code between call expressions
 * where we have a pre-compiled helper function that we use to do the
 * function invocation.
 */
abstract class CallFast {
  String get name;
  Function get function;

  _evaluate0(holder) => (holder is Map)
      ? ensureFunctionFromMap(holder, name)()
      : function(holder);
  _evaluate1(holder, a0) => (holder is Map)
      ? ensureFunctionFromMap(holder, name)(a0)
      : function(holder, a0);
}
