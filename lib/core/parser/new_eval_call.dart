library angular.core.new_parser.new_eval_call;

import 'dart:mirrors';
import 'package:angular/core/parser/new_eval.dart';
import 'package:angular/core/parser/new_syntax.dart';
import 'package:angular/core/parser/new_eval_utils.dart';

Evaluatable newCallScope(ClosureMap closures, name, arguments) {
  int arity = arguments.length;
  Function function = closures.lookupFunction(name, arity);
  if (function != null) {
    switch (arity) {
      case 0: return new _CallScopeFast0(name, arguments, function);
      case 1: return new _CallScopeFast1(name, arguments, function);
    }
  }
  Getter getter = closures.lookupGetter(name);
  if (getter != null) {
    return new _CallScopeFast(name, arguments, getter);
  } else {
    return new _CallScope(name, arguments);
  }
}

Evaluatable newCallMember(ClosureMap closures, object, name, arguments) {
  int arity = arguments.length;
  Function function = closures.lookupFunction(name, arity);
  if (function != null) {
    switch (arity) {
      case 0: return new _CallMemberFast0(object, name, arguments, function);
      case 1: return new _CallMemberFast1(object, name, arguments, function);
    }
  }
  Getter getter = closures.lookupGetter(name);
  if (getter != null) {
    return new _CallMemberFast(object, name, arguments, getter);
  } else {
    return new _CallMember(object, name, arguments);
  }
}

Evaluatable newCallFunction(function, arguments) {
  return new _CallFunction(function, arguments);
}

class _CallScope extends CallScope with Evaluatable, _CallCaching {
  final Symbol symbol;
  _CallScope(name, arguments)
      : super(name, arguments)
      , symbol = new Symbol(name);
  evaluate(scope) => _evaluate(scope, scope);
}

class _CallMember extends CallMember with Evaluatable, _CallCaching {
  final Symbol symbol;
  _CallMember(object, name, arguments)
      : super(object, name, arguments)
      , symbol = new Symbol(name);
  evaluate(scope) => _evaluate(scope, E(scope, object));
}

class _CallScopeFast extends CallScope with Evaluatable, _CallX {
  final Getter getter;
  _CallScopeFast(name, arguments, this.getter) : super(name, arguments);
  evaluate(scope) => _evaluate(scope, scope);
}

class _CallMemberFast extends CallMember with Evaluatable, _CallX {
  final Getter getter;
  _CallMemberFast(object, name, arguments, this.getter)
      : super(object, name, arguments);
  evaluate(scope) => _evaluate(scope, E(scope, object));
}

class _CallScopeFast0 extends CallScope with Evaluatable, _CallFast {
  final Function function;
  _CallScopeFast0(name, arguments, this.function) : super(name, arguments);
  evaluate(scope) => _evaluate0(scope);
}

class _CallScopeFast1 extends CallScope with Evaluatable, _CallFast {
  final Function function;
  _CallScopeFast1(name, arguments, this.function) : super(name, arguments);
  evaluate(scope) => _evaluate1(scope, E(scope, arguments[0]));
}

class _CallMemberFast0 extends CallMember with Evaluatable, _CallFast {
  final Function function;
  _CallMemberFast0(object, name, arguments, this.function)
      : super(object, name, arguments);
  evaluate(scope) => _evaluate0(E(scope, object));
}

class _CallMemberFast1 extends CallMember with Evaluatable, _CallFast {
  final Function function;
  _CallMemberFast1(object, name, arguments, this.function)
      : super(object, name, arguments);
  evaluate(scope) => _evaluate1(E(scope, object), E(scope, arguments[0]));
}

class _CallFunction extends CallFunction with Evaluatable {
  _CallFunction(function, arguments) : super(function, arguments);
  evaluate(scope) {
    var f  = E(scope, function);
    if (f is !Function) {
      throw new EvalError('$function is not a function');
    } else {
      return relaxFnApply(f, EL(scope, arguments));
    }
  }
}


/**
 * ...
 */
abstract class _CallCaching implements Evaluatable {
  static const int CACHED_MAP = 0;
  static const int CACHED_FUNCTION = 1;

  int _cachedKind = 0;
  var _cachedHolder = UNINITIALIZED;
  var _cachedValue;

  String get name;
  Symbol get symbol;
  List get arguments;

  _evaluate(scope, holder) {
    List arguments = EL(scope, this.arguments);
    if (!identical(holder, _cachedHolder)) {
      return _evaluteUncached(holder, arguments);
    }
    return (_cachedKind == CACHED_MAP)
        ? relaxFnApply(getFunctionFromMap(holder, name), arguments)
        : _cachedValue.invoke(symbol, arguments).reflectee;
  }

  _evaluteUncached(holder, arguments) {
    _cachedHolder = holder;
    if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      return relaxFnApply(getFunctionFromMap(holder, name), arguments);
    } else {
      InstanceMirror mirror = reflect(holder);
      _cachedKind = CACHED_FUNCTION;
      _cachedValue = mirror;
      return mirror.invoke(symbol, arguments).reflectee;
    }
  }
}


/**
 * ...
 */
abstract class _CallX implements Evaluatable {
  String get name;
  List get arguments;
  Getter get getter;

  _evaluate(scope, holder) {
    var function = (holder is Map) ? holder[name] : getter(holder);
    if (function is !Function) {
      throw new EvalError('Undefined function $name');
    } else {
      return relaxFnApply(function, EL(scope, arguments));
    }
  }
}


/**
 * ...
 */
abstract class _CallFast implements Evaluatable {
  String get name;
  Function get function;

  _evaluate0(holder) => (holder is Map)
      ? getFunctionFromMap(holder, name)()
      : function(holder);
  _evaluate1(holder, a0) => (holder is Map)
        ? getFunctionFromMap(holder, name)(a0)
        : function(holder, a0);
}





