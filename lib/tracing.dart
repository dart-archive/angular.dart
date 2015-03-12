/**
 * Tracing for AngularDart framework and applications.
 *
 * The tracing API hooks up to either [WTF](http://google.github.io/tracing-framework/) or
 * [Dart Observatory](https://www.dartlang.org/tools/observatory/).
 */
library angular.tracing;

import "dart:profiler";

bool traceEnabled = false;
dynamic /* JsObject */ _trace;
dynamic /* JsObject */ _events;
dynamic /* JsFunction */ _createScope;
dynamic /* JsFunction */ _enterScope;
dynamic /* JsFunction */ _leaveScope;
dynamic /* JsFunction */ _beginTimeRange;
dynamic /* JsFunction */ _endTimeRange;
final List _arg1 = [null];
final List _arg2 = [null, null];

/**
 * Use this method to detect if [WTF](http://google.github.io/tracing-framework/) has been enabled.
 *
 * To make sure that this library can be used DartVM where no JavaScript is available this
 * method needs to be called with JavaScript context.
 *
 * If the method is not called or if WTF has not been detected that the tracing defaults to
 * Dart Observatory.
 *
 *     import "dart:js" show context;
 *
 *     detectWTF(context);
 */
traceDetectWTF(dynamic /* JsObject */ context) {
  if (context.hasProperty('wtf')) {
    dynamic /* JsObject */ wtf = context['wtf'];
    if (wtf.hasProperty('trace')) {
      traceEnabled = true;
      _trace = wtf['trace'];
      _events = _trace['events'];
      _createScope = _events['createScope'];
      _enterScope = _trace['enterScope'];
      _leaveScope = _trace['leaveScope'];
      _beginTimeRange = _trace['beginTimeRange'];
      _endTimeRange = _trace['endTimeRange'];
    }

  }
}

/**
 * Create trace scope. Scopes must be strictly nested and are analogous to stack frames, but
 * do not have to follow the stack frames. Instead it is recommended that they follow logical
 * nesting.
 */
dynamic /* JsFunction */ traceCreateScope(signature, [flags]) {
  if (traceEnabled) {
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
 *     final myScope = traceCreateScope('myMethod');
 *
 *     someMethod() {
 *        var s = traceEnter(myScope);
 *        try {
 *          // do something
 *        } finally {
 *          traceLeave(s);
 *        }
 *     }
 */
dynamic /* JsObject */ traceEnter(dynamic /* JsFunction */ scope) {
  if (traceEnabled) {
    return scope.apply(const []);
  } else {
    return scope.makeCurrent();
  }
}

/**
 * Used to mark scope entry which logs single argument.
 *
 *     final myScope = traceCreateScope('myMethod');
 *
 *     someMethod() {
 *        var s = traceEnter(myScope);
 *        try {
 *          // do something
 *        } finally {
 *          traceLeave(s);
 *        }
 *     }
 */
dynamic /* JsObject */ traceEnter1(dynamic /* JsFunction */ scope, arg1) {
  if (traceEnabled) {
    _arg1[0] = arg1;
    return scope.apply(_arg1);
  } else {
    return scope.makeCurrent();
  }
}

/**
 * Used to mark scope exit.
 *
 *     var myScope = traceCreateScope('myMethod');
 *
 *     someMethod() {
 *        var s = traceEnter(myScope);
 *        try {
 *          // do something
 *        } finally {
 *          traceLeave(s);
 *        }
 *     }
 */
dynamic /* JsObject */ traceLeave(dynamic /* JsObject */ scope) {
  if (traceEnabled) {
    _arg1[0] = scope;
    _leaveScope.apply(_arg1, thisArg: _trace);
  } else {
    scope.makeCurrent();
  }
}

/**
 * Used to mark scope exit.
 *
 *     var myScope = traceCreateScope('myMethod');
 *
 *     someMethod() {
 *        var s = traceEnter(myScope);
 *        try {
 *          // do something
 *        } finally {
 *          traceLeave(s);
 *        }
 *     }
 */
dynamic /* JsObject */ traceLeaveVal(dynamic /* JsObject */ scope, dynamic returnValue) {
  if (traceEnabled) {
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
 *        var s = traceAsyncStart('HTTP:GET', 'some.url');
 *        var future = new Future.delay(5).then((_) {
 *          traceAsyncEnd(s);
 *        });
 *     }
 */
dynamic /* JsObject */ traceAsyncStart(String rangeType, String action) {
  if (traceEnabled) {
    _arg2[0] = rangeType;
    _arg2[1] = action;
    return _beginTimeRange.apply(_arg2, thisArg: _trace);
  }
  return null;
}

dynamic /* JsObject */ traceAsyncEnd(dynamic /* JsObject */ range) {
  if (traceEnabled) {
    _arg1[0] = range;
    return _endTimeRange.apply(_arg1, thisArg: _trace);
  }
  return null;
}

