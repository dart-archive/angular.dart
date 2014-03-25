library angular.core.parser.eval_calls;

import 'dart:mirrors';
import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/module.dart';

typedef Function LookupFunction(String name, syntax.CallArguments arguments);

class CallScope extends syntax.CallScope with CallReflective {
  final Symbol symbol;
  CallScope(name, arguments)
      : super(name, arguments),
        symbol = newSymbol(name);
  eval(scope, [FilterMap filters]) => _eval(scope, scope, filters);
}

class CallMember extends syntax.CallMember with CallReflective {
  final Symbol symbol;
  CallMember(object, name, arguments)
      : super(object, name, arguments),
        symbol = newSymbol(name);
  eval(scope, [FilterMap filters]) => _eval(scope, object.eval(scope, filters),
                                            filters);
}

class CallScopeFast0 extends syntax.CallScope with CallFast {
  final Function callProperty;
  final Function callMap;
  CallScopeFast0(name, arguments, LookupFunction lookup)
      : this.callProperty = lookup(name, arguments),
        this.callMap = lookup("", arguments),
        super(name, arguments);

  eval(scope, [FilterMap filters]) => _evaluate0(scope);
}

class CallScopeFast1 extends syntax.CallScope with CallFast {
  final Function callProperty;
  final Function callMap;
  CallScopeFast1(name, arguments, LookupFunction lookup)
      : callProperty = lookup(name, arguments),
        callMap = lookup("", arguments),
        super(name, arguments);

  eval(scope, [FilterMap filters]) =>
       _evaluate1(scope, arguments[0].eval(scope, filters));
}

class CallMemberFast0 extends syntax.CallMember with CallFast {
  final Function callProperty;
  final Function callMap;
  CallMemberFast0(object, name, arguments, LookupFunction lookup)
      : this.callProperty = lookup(name, arguments)
      , this.callMap = lookup("", arguments)
      , super(object, name, arguments);
  eval(scope, [FilterMap filters]) => _evaluate0(object.eval(scope, filters));
}

class CallMemberFast1 extends syntax.CallMember with CallFast {
  final Function callProperty;
  final Function callMap;
  CallMemberFast1(object, name, arguments, LookupFunction lookup)
      : this.callProperty = lookup(name, arguments)
      , this.callMap = lookup("", arguments)
      , super(object, name, arguments);
  eval(scope, [FilterMap filters]) => _evaluate1(object.eval(scope, filters),
      arguments[0].eval(scope, filters));
}

class CallFunction extends syntax.CallFunction {
  CallFunction(function, arguments) : super(function, arguments);
  eval(scope, [FilterMap filters]) {
    var function  = this.function.eval(scope, filters);
    if (function is! Function) {
      throw new EvalError('${this.function} is not a function');
    } else {
      List positionals = evalList(scope, arguments.positionals, filters);
      if (arguments.named.isNotEmpty) {
        var named = new Map<Symbol, dynamic>();
        arguments.named.forEach((String name, value) {
          named[new Symbol(name)] = value.eval(scope, filters);
        });
        return Function.apply(function, positionals, named);
      } else {
        return relaxFnApply(function, positionals);
      }
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
  syntax.CallArguments get arguments;

  _eval(scope, holder, FilterMap filters) {
    List positionals = evalList(scope, arguments.positionals, filters);
    if (arguments.named.isNotEmpty) {
      var named = new Map<Symbol, dynamic>();
      arguments.named.forEach((String name, value) {
        named[new Symbol(name)] = value.eval(scope, filters);
      });
      if (holder is Map) {
        var fn = ensureFunctionFromMap(holder, name);
        return Function.apply(fn, positionals, named);
      } else {
        return reflect(holder).invoke(symbol, positionals, named).reflectee;
      }
    }

    if (!identical(holder, _cachedHolder)) {
      return _evaluteUncached(holder, positionals);
    }
    return (_cachedKind == CACHED_MAP)
        ? relaxFnApply(ensureFunctionFromMap(holder, name), positionals)
        : _cachedValue.invoke(symbol, positionals).reflectee;
  }

  _evaluteUncached(holder, positionals) {
    _cachedHolder = holder;
    if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      return relaxFnApply(ensureFunctionFromMap(holder, name), positionals);
    } else if (symbol == null) {
      _cachedHolder = UNINITIALIZED;
      throw new EvalError("Undefined function $name");
    } else {
      InstanceMirror mirror = reflect(holder);
      _cachedKind = CACHED_FUNCTION;
      _cachedValue = mirror;
      return mirror.invoke(symbol, positionals).reflectee;
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

  Function get callMap;
  Function get callProperty;

  _evaluate0(holder) => (holder is Map)
      ? callMap(ensureFunctionFromMap(holder, name))
      : callProperty(holder);
  _evaluate1(holder, a0) => (holder is Map)
      ? callMap(ensureFunctionFromMap(holder, name), a0)
      : callProperty(holder, a0);
}
