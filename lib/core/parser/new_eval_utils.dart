library angular.core.new_parser.new_eval_utils;

import 'package:angular/core/parser/new_eval.dart';
export 'package:angular/utils.dart' show relaxFnApply, relaxFnArgs, toBool;

/**
 * Marker for an uninitialized value.
 */
const UNINITIALIZED = const _Uninitialized();

/**
 * Evaluate the [evaluatable] in context of the [scope].
 */
E(scope, Evaluatable evaluatable)
    => evaluatable.evaluate(scope);

/**
 * Evaluate the [list] in context of the [scope].
 */
List EL(scope, list) {
  int length = list.length;
  List result = _cachedLists[length];
  for (int i = 0; i < length; i++) {
    result[i] = E(scope, list[i]);
  }
  return result;
}

/**
 * Evaluate the [value] in context of the [scope] and assign it to [target].
 */
A(scope, Evaluatable target, Evaluatable value)
    => target.assign(scope, E(scope, value));

// TODO(kasperl): Rename this function.
Function getFunctionFromMap(Map holder, String name) {
  var result = holder[name];
  if (result is Function) return result;
  throw new EvalError('Undefined function $name');
}

final List _cachedLists =
    [[],[0],[0, 0],[0, 0, 0],[0, 0, 0, 0],[0, 0, 0, 0, 0]];

class _Uninitialized {
  const _Uninitialized();
}
