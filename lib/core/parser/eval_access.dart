library angular.core.parser.eval_access;

import 'dart:mirrors';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';

class AccessScope extends syntax.AccessScope with AccessReflective {
  final Symbol symbol;
  AccessScope(String name) : super(name), symbol = new Symbol(name);
  eval(scope) => _eval(scope);
  assign(scope, value) => _assign(scope, scope, value);
}

class AccessScopeFast extends syntax.AccessScope with AccessFast {
  final Getter getter;
  final Setter setter;
  AccessScopeFast(String name, this.getter, this.setter) : super(name);
  eval(scope) => _eval(scope);
  assign(scope, value) => _assign(scope, scope, value);
}

class AccessMember extends syntax.AccessMember with AccessReflective {
  final Symbol symbol;
  AccessMember(object, String name) : super(object, name), symbol = new Symbol(name);
  eval(scope) => _eval(object.eval(scope));
  assign(scope, value) => _assign(scope, object.eval(scope), value);
  _assignToNonExisting(scope, value) => object.assign(scope, { name: value });
}

class AccessMemberFast extends syntax.AccessMember with AccessFast {
  final Getter getter;
  final Setter setter;
  AccessMemberFast(object, String name, this.getter, this.setter)
      : super(object, name);
  eval(scope) => _eval(object.eval(scope));
  assign(scope, value) => _assign(scope, object.eval(scope), value);
  _assignToNonExisting(scope, value) => object.assign(scope, { name: value });
}

class AccessKeyed extends syntax.AccessKeyed {
  AccessKeyed(object, key) : super(object, key);
  eval(scope) => getKeyed(object.eval(scope), key.eval(scope));
  assign(scope, value) => setKeyed(object.eval(scope), key.eval(scope), value);
}


/**
 * The [AccessReflective] mixin is used to share code between access expressions
 * where we need to use reflection to get or set a field. We optimize for the
 * case where we access the same holder repeatedly through caching.
 */
abstract class AccessReflective {
  static const int CACHED_FIELD = 0;
  static const int CACHED_MAP = 1;
  static const int CACHED_VALUE = 2;

  int _cachedKind = 0;
  var _cachedHolder = UNINITIALIZED;
  var _cachedValue;

  String get name;
  Symbol get symbol;

  _eval(holder) {
    if (!identical(holder, _cachedHolder)) return _evalUncached(holder);
    int cachedKind = _cachedKind;
    if (cachedKind == CACHED_MAP) return holder[name];
    var value = _cachedValue;
    return (cachedKind == CACHED_FIELD)
        ? value.getField(symbol).reflectee
        : value;
  }

  _evalUncached(holder) {
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

  _assign(scope, holder, value) {
    if (holder is Map) {
      holder[name] = value;
    } else if (holder == null) {
      _assignToNonExisting(scope, value);
    } else {
      reflect(holder).setField(symbol, value);
    }
    return value;
  }

  // By default we don't do any assignments to non-existing holders. This
  // is overwritten for access to members.
  _assignToNonExisting(scope, value) => null;

  static Function createInvokeClosure(InstanceMirror mirror, Symbol symbol) {
    if (!hasMethod(mirror, symbol)) return null;
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

  static bool hasMethod(InstanceMirror mirror, Symbol symbol) {
    return hasMethodHelper(mirror.type, symbol);
  }

  static final objectClassMirror = reflectClass(Object);
  static final Set<Symbol> objectClassInstanceMethods =
      new Set<Symbol>.from([#toString, #noSuchMethod]);

  static final Function hasMethodHelper = (() {
    try {
      // Use ClassMirror.instanceMembers if available. It contains local
      // as well as inherited members.
      objectClassMirror.instanceMembers;
      // For SDK 1.2 we have to use a somewhat complicated helper for this
      // to work around bugs in the dart2js implementation.
      return hasInstanceMethod;
    } on NoSuchMethodError catch (e) {
      // For SDK 1.0 we fall back to just using the local members.
      return (type, symbol) => type.members[symbol] is MethodMirror;
    } on UnimplementedError catch (e) {
      // For SDK 1.1 we fall back to just using the local declarations.
      return (type, symbol) => type.declarations[symbol] is MethodMirror;
    }
    return null;
  })();

  static bool hasInstanceMethod(type, symbol) {
    // Always allow instance methods found in the Object class. This makes
    // it easier to work around a few bugs in the dart2js implementation.
    if (objectClassInstanceMethods.contains(symbol)) return true;
    // Work around http://dartbug.com/16309 which causes access to the
    // instance members of certain builtin types to throw exceptions
    // while traversing the superclass chain.
    var mirror;
    try {
      mirror = type.instanceMembers[symbol];
    } on UnsupportedError catch (e) {
      mirror = type.declarations[symbol];
    }
    // Work around http://dartbug.com/15760 which causes noSuchMethod
    // forwarding stubs to be treated as members of all classes. We have
    // already checked for the real instance methods in Object, so if the
    // owner of this method is Object we simply filter it out.
    if (mirror is !MethodMirror) return false;
    return mirror.owner != objectClassMirror;
  }
}

/**
 * The [AccessFast] mixin is used to share code between access expressions
 * where we have a pair of pre-compiled getter and setter functions that we
 * use to do the access the field.
 */
abstract class AccessFast {
  String get name;
  Getter get getter;
  Setter get setter;

  _eval(holder) {
    if (holder == null) return null;
    return (holder is Map) ? holder[name] : getter(holder);
  }

  _assign(scope, holder, value) {
    if (holder == null) {
      _assignToNonExisting(scope, value);
      return value;
    } else {
      return (holder is Map) ? (holder[name] = value) : setter(holder, value);
    }
  }

  // By default we don't do any assignments to non-existing holders. This
  // is overwritten for access to members.
  _assignToNonExisting(scope, value) => null;
}

