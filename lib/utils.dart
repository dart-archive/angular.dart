library angular.util;

import 'dart:async';

import 'package:smoke/smoke.dart' as smoke;

bool toBool(x) {
  if (x is bool) return x;
  if (x is num) return x != 0;
  return false;
}

relaxFnApply(Function fn, List args) {
  // Check the args.length to support functions with optional parameters.
  if (fn is Function) {
    var maxArgs = smoke.maxArgs(fn);
    if (maxArgs == -1) {
      throw "Unknown function type, expecting 0 to ${smoke.SUPPORTED_ARGS} args.";
    }
    var minArgs = smoke.minArgs(fn);
    if (minArgs > args.length) {
      throw "Function requires $minArgs args, ${args.length} provided.";
    }
    return Function.apply(fn, args.length > maxArgs ? args.sublist(0, maxArgs) : args);
  } else {
    throw "Missing function.";
  }
}

relaxFnArgs1(Function fn) {
  switch(smoke.minArgs(fn)) {
    case 3:
      return (_1) => fn(_1, null, null);
    case 2:
      return (_1) => fn(_1, null);
    case 1:
      return fn;
    case 0:
      return (_1) => fn();
  }
  // TODO(jacobr): why do we quietly return null if the minimum number of args
  // is > 3?
}

relaxFnArgs2(Function fn) {
  if (smoke.canAcceptNArgs(fn, 2)) return fn;
  if (smoke.canAcceptNArgs(fn, 1)) return (_1, _2) => fn(_1);
  if (smoke.canAcceptNArgs(fn, 0)) return (_1, _2) => fn();
  // TODO(jacobr): why do we quietly return null if the minimum number of args
  // is > 2?
}

relaxFnArgs3(Function fn) {
  if (smoke.canAcceptNArgs(fn, 3)) return fn;
  if (smoke.canAcceptNArgs(fn, 2)) return (_1, _2, _3) => fn(_1, null);
  if (smoke.canAcceptNArgs(fn, 1)) return (_1, _2, _3) => fn(_1);
  if (smoke.canAcceptNArgs(fn, 0)) return (_1, _2, _3) => fn();
  // TODO(jacobr): why do we quietly return null if the minimum number of args
  // is > 3?
}

relaxFnArgs(Function fn) {
  if (smoke.canAcceptNArgs(fn, 5)) {
    return ([a0, a1, a2, a3, a4]) => fn(a0, a1, a2, a3, a4);
  } else if (smoke.canAcceptNArgs(fn, 4)) {
    return ([a0, a1, a2, a3, a4]) => fn(a0, a1, a2, a3);
  } else if (smoke.canAcceptNArgs(fn, 3)) {
    return ([a0, a1, a2, a3, a4]) => fn(a0, a1, a2);
  } else if (smoke.canAcceptNArgs(fn, 2)) {
    return ([a0, a1, a2, a3, a4]) => fn(a0, a1);
  } else if (smoke.canAcceptNArgs(fn, 1)) {
    return ([a0, a1, a2, a3, a4]) => fn(a0);
  } else if (smoke.canAcceptNArgs(fn, 0)) {
    return ([a0, a1, a2, a3, a4]) => fn();
  } else {
    return ([a0, a1, a2, a3, a4]) {
      throw "Unknown function type, expecting 0 to 5 args.";
    };
  }
}

capitalize(String s) => s.substring(0, 1).toUpperCase() + s.substring(1);

String camelCase(String s) {
  var parts = s.split('-');
  return parts.first.toLowerCase() + parts.skip(1).map(capitalize).join();
}

/// Returns whether or not the given identifier is a reserved word in Dart.
bool isReservedWord(String identifier) => RESERVED_WORDS.contains(identifier);

final Set<String> RESERVED_WORDS = new Set<String>.from(const [
  "assert",
  "break",
  "case",
  "catch",
  "class",
  "const",
  "continue",
  "default",
  "do",
  "else",
  "enum",
  "extends",
  "false",
  "final",
  "finally",
  "for",
  "if",
  "in",
  "is",
  "new",
  "null",
  "rethrow",
  "return",
  "super",
  "switch",
  "this",
  "throw",
  "true",
  "try",
  "var",
  "void",
  "while",
  "with"
]);

/// Returns true iff o is [double.NAN].
/// In particular, returns false if o is null.
bool isNaN(Object o) => o is num && o.isNaN;

/// Returns true iff o1 == o2 or both are [double.NAN].
bool eqOrNaN(Object o1, Object o2) => o1 == o2 || (isNaN(o1) && isNaN(o2));

/// Merges two futures of iterables into one.
Future<Iterable> mergeFutures(Future<Iterable> f1, Future<Iterable> f2) {
  return Future.wait([f1, f2]).then((twoLists) {
    assert(twoLists.length == 2);
    return []..addAll(twoLists[0])..addAll(twoLists[1]);
  });
}
