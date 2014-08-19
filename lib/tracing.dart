/**
 * Tracing for AngularDart framework and applications.
 *
 * The tracing API hooks up to either [WTF](http://google.github.io/tracing-framework/) or
 * [Dart Observatory](https://www.dartlang.org/tools/observatory/).
 */
library angular.tracing;

import "dart:profiler";

bool wtfEnabled = false;
var _trace;
var _events;
var _createScope;
var _enterScope;
var _leaveScope;
var _beginTimeRange;
var _endTimeRange;
final List _arg1 = [null];
final List _arg2 = [null, null];

/**
 * Use this method to detect if [WTF](http://google.github.io/tracing-framework/) has been enabled.
 *
 * If the method is not called or if WTF has not been detected that the tracing defaults to
 * Dart Observatory.
 *
 * To make sure that this library can be used DartVM where no JavaScript is available this
 * method needs to be called with JavaScript context:
 *
 *     import "dart:js" show context;
 *
 *     detectWTF(context);
 */
bool detectWTF(context) {
  if (context.hasProperty('wtf')) {
    var wtf = context['wtf'];
    if (wtf.hasProperty('trace')) {
      wtfEnabled = true;
      _trace = wtf['trace'];
      _events = _trace['events'];
      _createScope = _events['createScope'];
      _enterScope = _trace['enterScope'];
      _leaveScope = _trace['leaveScope'];
      _beginTimeRange = _trace['beginTimeRange'];
      _endTimeRange = _trace['endTimeRange'];
      return true;
    }
  }
  return false;
}

/**
 * Create trace scope. Scopes must be strictly nested and are analogous to stack frames, but
 * do not have to follow the stack frames. Instead it is recommended that they follow logical
 * nesting.
 */
dynamic createScope(String signature, [flags]) {
  if (wtfEnabled) {
    _arg2[0] = signature;
    _arg2[1] = flags;
    return _createScope.apply(_arg2, thisArg: _events);
  } else {
    return new UserTag(signature);
  }
}

/**
 * Used to mark scope entry.
 *
 *     final myScope = createScope('myMethod');
 *
 *     someMethod() {
 *        var s = enter(myScope);
 *        try {
 *          // do something
 *        } finally {
 *          leave(s);
 *        }
 *     }
 */
dynamic enter(scope) {
  if (wtfEnabled) {
    return scope.apply(const []);
  } else {
    return scope.makeCurrent();
  }
}

/**
 * Used to mark scope entry which logs single argument.
 */
dynamic enter1(scope, arg1) {
  if (wtfEnabled) {
    _arg1[0] = arg1;
    return scope.apply(_arg1);
  } else {
    return scope.makeCurrent();
  }
}

/**
 * Used to mark scope exit.
 */
dynamic leave(scope) {
  if (wtfEnabled) {
    _arg1[0] = scope;
    _leaveScope.apply(_arg1, thisArg: _trace);
  } else {
    scope.makeCurrent();
  }
}

/**
 * Used to mark scope exit with a value
 */
dynamic leaveVal(scope, returnValue) {
  if (wtfEnabled) {
    _arg2[0] = scope;
    _arg2[1] = returnValue;
    _leaveScope.apply(_arg2, thisArg: _trace);
  } else {
    scope.makeCurrent();
  }
}

/**
 * Used to mark Async start. Async are similar to scope but they don't have to be strictly nested.
 * Async ranges only work if WTF has been enabled.
 *
 *     someMethod() {
 *        var s = startAsync('HTTP:GET', 'some.url');
 *        var future = new Future.delay(5).then((_) {
 *          endAsync(s);
 *        });
 *     }
 */
dynamic startAsync(String rangeType, String action) {
  if (wtfEnabled) {
    _arg2[0] = rangeType;
    _arg2[1] = action;
    return _beginTimeRange.apply(_arg2, thisArg: _trace);
  }
  return null;
}

dynamic endAsync(dynamic range) {
  if (wtfEnabled) {
    _arg1[0] = range;
    return _endTimeRange.apply(_arg1, thisArg: _trace);
  }
  return null;
}

