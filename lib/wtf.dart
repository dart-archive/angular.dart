library angular.wtf;

import "dart:profiler";

bool wtfEnabled = false;
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
 * Use this method to initialize the WTF. It would be
 * nice if this file could depend on dart:js, but that would
 * make it not possible to refer to it in Dart VM. For this
 * reason we expect the init caller to pass in the context
 * JsObject.
 */
traceInit(dynamic /* JsObject */ context) {
  if (context.hasProperty('wtf')) {
    dynamic /* JsObject */ wtf = context['wtf'];
    if (wtf.hasProperty('trace')) {
      wtfEnabled = true;
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

// WTF.trace.events.createScope(string signature, opt_flags)
dynamic /* JsFunction */ traceCreateScope(signature, [flags]) {
  if (wtfEnabled) {
    _arg2[0] = signature;
    _arg2[1] = flags;
    return _createScope.apply(_arg2, thisArg: _events);
  } else {
    return new UserTag(signature);
  }
}

dynamic /* JsObject */ traceEnter(dynamic /* JsFunction */ scope, [args = const []]) {
  if (wtfEnabled) {
    return scope.apply(args);
  } else {
    return scope.makeCurrent();
  }
}

dynamic /* JsObject */ traceLeave(dynamic /* JsObject */ scope) {
  if (wtfEnabled) {
    _arg1[0] = scope;
    _leaveScope.apply(_arg1, thisArg: _trace);
  } else {
    scope.makeCurrent();
  }
}

// WTF.trace.beginTimeRange('my.Type:job', actionName);
dynamic /* JsObject */ traceAsyncStart(String rangeType, String action) {
  if (wtfEnabled) {
    _arg2[0] = rangeType;
    _arg2[1] = action;
    return _beginTimeRange.apply(_arg2, thisArg: _trace);
  }
  return null;
}

dynamic /* JsObject */ traceAsyncEnd(dynamic /* JsObject */ range) {
  if (wtfEnabled) {
    _arg1[0] = range;
    return _endTimeRange.apply(_arg1, thisArg: _trace);
  }
  return null;
}

