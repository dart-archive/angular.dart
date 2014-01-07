library angular.core.new_parser.evaluation;

import 'dart:mirrors';

import 'package:angular/core/module.dart' show FilterMap, NgInjectableService;
import 'package:angular/core/parser/parser.dart' show autoConvertAdd;
import 'package:angular/core/parser/new_parser.dart';
import 'package:angular/core/parser/new_syntax.dart';
import 'package:angular/utils.dart' show toBool, relaxFnArgs, relaxFnApply;

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
  static List _cachedLists = [
    [],
    [0],
    [0, 0],
    [0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0, 0] ];

  evaluate(scope);
  assign(scope, value) => throw new EvalError("Cannot assign to $this");

  List _evaluateArguments(scope, arguments) {
    int length = arguments.length;
    List result = _cachedLists[length];
    for (int i = 0; i < length; i++) {
      Evaluatable argument = arguments[i];
      result[i] = argument.evaluate(scope);
    }
    return result;
  }
}

@NgInjectableService()
class ParserBackendForEvaluation extends ParserBackend {
  final FilterMap _filters;
  final ClosureMap _closures;
  ParserBackendForEvaluation(this._filters, this._closures);

  Evaluatable newChain(expressions)
      => new _Chain(expressions);
  Evaluatable newFilter(expression, name, arguments)
      => new _Filter(expression, name, arguments, _filters(name));

  Evaluatable newAssign(target, value)
     => new _Assign(target, value);
  Evaluatable newConditional(condition, yes, no)
     => new _Conditional(condition, yes, no);

  Evaluatable newAccessScope(name) {
    Getter getter = _closures.lookupGetter(name);
    if (getter != null) {
      return new _AccessScopeFast(name, getter);
    } else {
      return new _AccessScope(name);
    }
  }

  Evaluatable newAccessMember(object, name) {
    Getter getter = _closures.lookupGetter(name);
    if (getter != null) {
      return new _AccessMemberFast(object, name, getter);
    } else {
      return new _AccessMember(object, name);
    }
  }

  Evaluatable newAccessKeyed(object, key)
      => new _AccessKeyed(object, key);

  Evaluatable newCallScope(name, arguments) {
    int arity = arguments.length;
    Function function = _closures.lookupFunction(name, arity);
    if (function != null) {
      switch (arity) {
        case 0: return new _CallScopeFast0(name, arguments, function);
        case 1: return new _CallScopeFast1(name, arguments, function);
      }
    }
    Getter getter = _closures.lookupGetter(name);
    if (getter != null) {
      return new _CallScopeFast(name, arguments, getter);
    } else {
      return new _CallScope(name, arguments);
    }
  }

  Evaluatable newCallFunction(function, arguments)
      => new _CallFunction(function, arguments);

  Evaluatable newCallMember(object, name, arguments) {
    int arity = arguments.length;
    Function function = _closures.lookupFunction(name, arity);
    if (function != null) {
      switch (arity) {
        case 0: return new _CallMemberFast0(object, name, arguments, function);
        case 1: return new _CallMemberFast1(object, name, arguments, function);
      }
    }
    Getter getter = _closures.lookupGetter(name);
    if (getter != null) {
      return new _CallMemberFast(object, name, arguments, getter);
    } else {
      return new _CallMember(object, name, arguments);
    }
  }

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
    var last;
    for (int i = 0, length = expressions.length; i < length; i++) {
      Evaluatable expression = expressions[i];
      last = expression.evaluate(scope);
    }
    return last;
  }
}

class _Filter extends Filter with Evaluatable {
  final Function function;
  _Filter(expression, name, arguments, this.function)
      : super(expression, name, arguments);

  evaluate(scope) {
    // TODO(kasperl: Compute this once -- not for every evaluation.
    List allArguments = new List(arguments.length + 1);
    allArguments[0] = expression;
    allArguments.setAll(1, arguments);

    return Function.apply(function,
        _evaluateArguments(scope, allArguments));
  }
}

class _Assign extends Assign with Evaluatable {
  _Assign(target, value) : super(target, value);
  evaluate(scope) {
    Evaluatable target = this.target;
    Evaluatable value = this.value;
    return target.assign(scope, value.evaluate(scope));
  }
}

class _Conditional extends Conditional with Evaluatable {
  _Conditional(condition, yes, no) : super(condition, yes, no);

  evaluate(scope) {
    Evaluatable condition = this.condition;
    if (toBool(condition.evaluate(scope))) {
      Evaluatable yes = this.yes;
      return yes.evaluate(scope);
    } else {
      Evaluatable no = this.no;
      return no.evaluate(scope);
    }
  }
}

class _AccessScope extends AccessScope with Evaluatable, _AccessCaching {
  final Symbol symbol;
  _AccessScope(name) : super(name), symbol = new Symbol(name);

  evaluate(scope) {
    return _evaluateAccess(scope);
  }

  assign(scope, value) {
    if (scope is Map) {
      scope[name] = value;
    } else {
      reflect(scope).setField(symbol, value);
    }
    return value;
  }
}

class _AccessScopeFast extends AccessScope with Evaluatable {
  final Getter getter;
  final Symbol symbol;
  _AccessScopeFast(name, this.getter) : super(name), symbol = new Symbol(name);

  evaluate(scope) {
    return (scope is Map) ? scope[name] : getter(scope);
  }

  assign(scope, value) {
    if (scope is Map) {
      scope[name] = value;
    } else {
      reflect(scope).setField(symbol, value);
    }
    return value;
  }
}

class _AccessMember extends AccessMember with Evaluatable, _AccessCaching {
  final Symbol symbol;
  _AccessMember(object, name) : super(object, name), symbol = new Symbol(name);

  evaluate(scope) {
    Evaluatable object = this.object;
    return _evaluateAccess(object.evaluate(scope));
  }

  assign(scope, value) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    if (o == null) {
      object.assign(scope, { name: value });
    } else if (o is Map) {
      o[name] = value;
    } else {
      reflect(o).setField(symbol, value);
    }
    return value;
  }
}

class _AccessMemberFast extends AccessMember with Evaluatable {
  final Getter getter;
  final Symbol symbol;
  _AccessMemberFast(object, name, this.getter) : super(object, name), symbol = new Symbol(name);

  evaluate(scope) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    if (o is Map) {
      return o[name];
    } else {
      return (o == null) ? null : getter(o);
    }
  }

  assign(scope, value) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    if (o == null) {
      object.assign(scope, { name: value });
    } else if (o is Map) {
      o[name] = value;
    } else {
      reflect(o).setField(symbol, value);
    }
    return value;
  }
}

class _AccessKeyed extends AccessKeyed with Evaluatable {
  _AccessKeyed(object, key) : super(object, key);

  evaluate(scope) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    Evaluatable key = this.key;
    var k = key.evaluate(scope);
    // TODO(kasperl): Reconsider automatic conversions.
    if (o is List) {
      return o[k.toInt()];
    } else if (o is Map) {
      return o["$k"];
    } else if (o == null) {
      throw new EvalError('Accessing null object');
    } else {
      // TODO(kasperl): Field access? Really?
      throw new EvalError('Attempted field access on a non-list, non-map');
    }
  }

  assign(scope, value) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    Evaluatable key = this.key;
    var k = key.evaluate(scope);
    // TODO(kasperl): Reconsider automatic conversions.
    if (o is List) {
      var index = k.toInt();
      if (o.length <= index) o.length = index + 1;
      o[index] = value;
    } else if (o is Map) {
      o["$k"] = value;
    } else {
      // TODO(kasperl): Set field? Really?
      throw new EvalError('Attempting to set a field on a non-list, non-map');
    }
    return value;
  }
}

class _CallScope extends CallScope with Evaluatable, _CallCaching {
  final Symbol symbol;
  _CallScope(name, arguments)
      : super(name, arguments)
      , symbol = new Symbol(name);

  evaluate(scope) {
    List arguments = _evaluateArguments(scope, this.arguments);
    return _evaluateCall(scope, arguments);
  }
}

class _CallScopeFast extends CallScope with Evaluatable {
  final Getter getter;
  _CallScopeFast(name, arguments, this.getter) : super(name, arguments);

  evaluate(scope) {
    List arguments = _evaluateArguments(scope, this.arguments);
    var function = (scope is Map) ? scope[name] : getter(scope);
    return relaxFnApply(function, arguments);
  }
}

class _CallScopeFast0 extends CallScope with Evaluatable {
  final Function function;
  _CallScopeFast0(name, arguments, this.function) : super(name, arguments);
  evaluate(scope) {
    return (scope is Map) ? scope[name]() : function(scope);
  }
}

class _CallScopeFast1 extends CallScope with Evaluatable {
  final Function function;
  _CallScopeFast1(name, arguments, this.function) : super(name, arguments);
  evaluate(scope) {
    Evaluatable a0 = arguments[0];
    var e0 = a0.evaluate(scope);
    return (scope is Map) ? scope[name](e0) : function(scope, e0);
  }
}

class _CallFunction extends CallFunction with Evaluatable {
  _CallFunction(function, arguments) : super(function, arguments);

  evaluate(scope) {
    Evaluatable function = this.function;
    var f = function.evaluate(scope);
    if (f is !Function) {
      throw new EvalError('$function is not a function');
    } else {
      return relaxFnApply(f, _evaluateArguments(scope, arguments));
    }
  }
}

class _CallMember extends CallMember with Evaluatable, _CallCaching {
  final Symbol symbol;
  _CallMember(object, name, arguments)
      : super(object, name, arguments)
      , symbol = new Symbol(name);

  evaluate(scope) {
    Evaluatable object = this.object;
    return _evaluateCall(object.evaluate(scope),
        _evaluateArguments(scope, arguments));
  }
}

class _CallMemberFast extends CallMember with Evaluatable {
  final Getter getter;
  _CallMemberFast(object, name, arguments, this.getter)
      : super(object, name, arguments);

  evaluate(scope) {
    Evaluatable object = this.object;
    var holder = object.evaluate(scope);
    var function = (holder is Map) ? holder[name] : getter(holder);
    if (function is !Function) {
      throw new EvalError('Undefined function $name');
    } else {
      return relaxFnApply(function,
          _evaluateArguments(scope, arguments));
    }
  }
}

class _CallMemberFast0 extends CallMember with Evaluatable {
  final Function function;
  _CallMemberFast0(object, name, arguments, this.function)
      : super(object, name, arguments);
  evaluate(scope) {
    Evaluatable object = this.object;
    var holder = object.evaluate(scope);
    if (holder is Map) {
      var x = holder[name];
      if (x is !Function) {
        throw new EvalError('Undefined function $name');
      } else {
        return x();
      }
    } else {
      return function(holder);
    }
  }
}

class _CallMemberFast1 extends CallMember with Evaluatable {
  final Function function;
  _CallMemberFast1(object, name, arguments, this.function)
      : super(object, name, arguments);
  evaluate(scope) {
    Evaluatable object = this.object;
    var holder = object.evaluate(scope);
    Evaluatable a0 = arguments[0];
    var e0 = a0.evaluate(scope);
    if (holder is Map) {
      var x = holder[name];
      if (x is !Function) {
        throw new EvalError('Undefined function $name');
      } else {
        return x(e0);
      }
    } else {
      return function(holder, e0);
    }
  }
}

class _PrefixNot extends Prefix with Evaluatable {
  _PrefixNot(expression) : super('!', expression);

  evaluate(scope) {
    Evaluatable expression = this.expression;
    return !toBool(expression.evaluate(scope));
  }
}

class _Binary extends Binary with Evaluatable {
  _Binary(operation, left, right) : super(operation, left, right);

  evaluate(scope) {
    Evaluatable left = this.left;
    Evaluatable right = this.right;
    var l = left.evaluate(scope);
    switch (operation) {
      case '&&': return toBool(l) && toBool(right.evaluate(scope));
      case '||': return toBool(l) || toBool(right.evaluate(scope));
    }
    var r = right.evaluate(scope);
    switch (operation) {
      case '+'  : return autoConvertAdd(l, r);
      case '-'  : return l - r;
      case '*'  : return l * r;
      case '/'  : return l / r;
      case '~/' : return l ~/ r;
      case '%'  : return l % r;
      case '==' : return l == r;
      case '!=' : return l != r;
      case '<'  : return l < r;
      case '>'  : return l > r;
      case '<=' : return l <= r;
      case '>=' : return l >= r;
      case '^'  : return l ^ r;
      case '&'  : return l & r;
      default   : throw new EvalError('Internal error: [$operation] not handled');
    }
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

  evaluate(scope) {
    int length = elements.length;
    List result = new List(length);
    for (int i = 0; i < length; i++) {
      Evaluatable element = elements[i];
      result[i] = element.evaluate(scope);
    }
    return result;
  }
}

class _LiteralObject extends LiteralObject with Evaluatable {
  _LiteralObject(keys, values) : super(keys, values);

  evaluate(scope) {
    Map result = new Map();
    for (int i = 0, length = keys.length; i < length; i++) {
      String key = keys[i];
      Evaluatable value = values[i];
      result[key] = value.evaluate(scope);
    }
    return result;
  }
}

class _Uninitialized {
  const _Uninitialized();
}
const _uninitialized = const _Uninitialized();

abstract class _AccessCaching {
  static const int CACHED_FIELD = 0;
  static const int CACHED_MAP = 1;
  static const int CACHED_VALUE = 2;

  int _cachedKind = 0;
  var _cachedHolder = _uninitialized;
  var _cachedValue;

  String get name;
  Symbol get symbol;

  _evaluateAccess(holder) {
    if (!identical(holder, _cachedHolder)) {
      return _evaluteAccessUncached(holder);
    }
    int cachedKind = _cachedKind;
    if (cachedKind == CACHED_MAP) {
      return holder[name];
    }
    var value = _cachedValue;
    return (cachedKind == CACHED_FIELD)
        ? value.getField(symbol).reflectee
        : value;
  }

  _evaluteAccessUncached(holder) {
    _cachedHolder = holder;
    if (holder == null) {
      _cachedKind = CACHED_VALUE;
      return _cachedValue = null;
    } else if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      return holder[name];
    }
    InstanceMirror mirror = reflect(holder);
    try {
      var result = mirror.getField(symbol).reflectee;
      _cachedKind = CACHED_FIELD;
      _cachedValue = mirror;
      return result;
    } on NoSuchMethodError catch (e) {
      var result = createInvokeClosure(mirror, symbol);
      if (result == null) rethrow;
      _cachedKind = CACHED_VALUE;
      return _cachedValue = result;
    } on UnsupportedError catch (e) {
      var result = createInvokeClosure(mirror, symbol);
      if (result == null) rethrow;
      _cachedKind = CACHED_VALUE;
      return _cachedValue = result;
    }
  }

  static Function createInvokeClosure(InstanceMirror mirror, Symbol symbol) {
    var type = mirror.type;
    var members = useInstanceMembers ? type.instanceMembers : type.members;
    if (!members.containsKey(symbol)) return null;
    return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
      var arguments = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
      return mirror.invoke(symbol, arguments).reflectee;
    });
  }

  static final bool useInstanceMembers = computeUseInstanceMembers();
  static bool computeUseInstanceMembers() {
    try {
      reflect(Object).type.instanceMembers;
      return true;
    } catch (e) {
      return false;
    }
  }

  static stripTrailingNulls(List list) {
    while (list.isNotEmpty && (list.last == null)) {
      list.removeLast();
    }
    return list;
  }
}

abstract class _CallCaching {
  static const int CACHED_MAP = 0;
  static const int CACHED_FUNCTION = 1;

  int _cachedKind = 0;
  var _cachedHolder = _uninitialized;
  var _cachedValue;

  String get name;
  Symbol get symbol;

  _evaluateCall(holder, arguments) {
    if (!identical(holder, _cachedHolder)) {
      return _evaluteCallUncached(holder, arguments);
    }
    if (_cachedKind == CACHED_MAP) {
      var function = holder[name];
      if (function is !Function) {
        throw new EvalError('Undefined function $name');
      }
      return relaxFnApply(function, arguments);
    } else {
      return _cachedValue.invoke(symbol, arguments).reflectee;
    }
  }

  _evaluteCallUncached(holder, arguments) {
    _cachedHolder = holder;
    if (holder is Map) {
      _cachedKind = CACHED_MAP;
      _cachedValue = null;
      var function = holder[name];
      if (function is !Function) {
        throw new EvalError('Undefined function $name');
      }
      return relaxFnApply(function, arguments);
    } else {
      InstanceMirror mirror = reflect(holder);
      _cachedKind = CACHED_FUNCTION;
      _cachedValue = mirror;
      return mirror.invoke(symbol, arguments).reflectee;
    }
  }
}
