library angular.core.new_parser.new_eval_access;

import 'dart:mirrors';
import 'package:angular/core/parser/new_eval.dart';
import 'package:angular/core/parser/new_syntax.dart';
import 'package:angular/core/parser/new_eval_utils.dart';

Evaluatable newAccessScope(ClosureMap closures, name) {
  Getter getter = closures.lookupGetter(name);
  if (getter != null) {
    return new _AccessScopeFast(name, getter);
  } else {
    return new _AccessScope(name);
  }
}

Evaluatable newAccessMember(ClosureMap closures, object, name) {
  Getter getter = closures.lookupGetter(name);
  if (getter != null) {
    return new _AccessMemberFast(object, name, getter);
  } else {
    return new _AccessMember(object, name);
  }
}

Evaluatable newAccessKeyed(object, key) {
  return new _AccessKeyed(object, key);
}

class _AccessScope extends AccessScope with Evaluatable, _AccessCaching {
  final Symbol symbol;
  _AccessScope(name) : super(name), symbol = new Symbol(name);
  evaluate(scope) => _evaluateAccess(scope);

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
  evaluate(scope) => (scope is Map) ? scope[name] : getter(scope);

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
  evaluate(scope) => _evaluateAccess(E(scope, object));

  assign(scope, value) {
    Evaluatable object = this.object;
    var o = object.evaluate(scope);
    if (o == null) {
      // TODO(kasperl): This leads to double evaluation. Is that a problem?
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
  _AccessMemberFast(object, name, this.getter)
      : super(object, name)
      , symbol = new Symbol(name);

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
      // TODO(kasperl): This leads to double evaluation. Is that a problem?
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


/**
 * ...
 */
abstract class _AccessCaching {
  static const int CACHED_FIELD = 0;
  static const int CACHED_MAP = 1;
  static const int CACHED_VALUE = 2;

  int _cachedKind = 0;
  var _cachedHolder = UNINITIALIZED;
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
    if (!hasMember(mirror, symbol)) return null;
    return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
      var arguments = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
      return mirror.invoke(symbol, arguments).reflectee;
    });
  }

  static stripTrailingNulls(List list) {
    while (list.isNotEmpty && (list.last == null)) {
      list.removeLast();
    }
    return list;
  }

  static bool hasMember(InstanceMirror mirror, Symbol symbol) {
    var type = mirror.type as dynamic;
    var members = useInstanceMembers ? type.instanceMembers : type.members;
    return members.containsKey(symbol);
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
}

