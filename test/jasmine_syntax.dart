library jasmine;

import 'package:unittest/unittest.dart' as unit;
import 'package:angular/utils.dart' as utils;

var _beforeEachFnsForCurrentTest = [];
var _afterEachFnsForCurrentTest = [];

_withSetup(fn) => () {
  _beforeEachFnsForCurrentTest.sort((a, b) => Comparable.compare(b[1], a[1]));
  _beforeEachFnsForCurrentTest.forEach((fn) => fn[0]());
  try {
    return fn();
  } finally {
    _beforeEachFnsForCurrentTest = [];
    var _aeFns = _afterEachFnsForCurrentTest;
    _afterEachFnsForCurrentTest = [];
    _aeFns.reversed.forEach((fn) => fn());
  }
};



it(name, fn) => unit.test(name, _withSetup(fn));
iit(name, fn) => unit.solo_test(name, _withSetup(fn));
xit(name, fn) {}
xdescribe(name, fn) {}
ddescribe(name, fn) => describe(name, fn, true);

class Describe {
  Describe parent;
  String name;
  bool exclusive;
  List<List> beforeEachFns = [];
  List<Function> afterEachFns = [];

  Describe(this.name, this.parent, [bool this.exclusive=false]) {
    if (parent != null && parent.exclusive) {
      exclusive = true;
    }
  }

  setUp() {
    _beforeEachFnsForCurrentTest.addAll(beforeEachFns);
    _afterEachFnsForCurrentTest.addAll(afterEachFns);
  }
}

Describe currentDescribe = new Describe('', null);
bool ddescribeActive = false;

describe(name, fn, [bool exclusive=false]) {
  var lastDescribe = currentDescribe;
  currentDescribe = new Describe(name, lastDescribe, exclusive);
  if (exclusive) {
    name = 'DDESCRIBE: $name';
    ddescribeActive = true;
  }
  try {
    unit.group(name, () {
      unit.setUp(currentDescribe.setUp);
      fn();
    });
  } finally {
    currentDescribe = lastDescribe;
  }
}

beforeEach(fn, {priority: 0}) => currentDescribe.beforeEachFns.add([fn, priority]);
afterEach(fn) => currentDescribe.afterEachFns.insert(0, fn);

var jasmine = new Jasmine();

class SpyFunctionInvocationResult {
  final List args;
  SpyFunctionInvocationResult(this.args);
}

class SpyFunction {
  String name;
  List<List<dynamic>> invocations = [];
  List<List<dynamic>> invocationsWithoutTrailingNulls = [];
  var _andCallFakeFn;

  SpyFunction([this.name]);
  call([a0, a1, a2, a3, a4, a5]) {
    var args = [];
    args.add(a0);
    args.add(a1);
    args.add(a2);
    args.add(a3);
    args.add(a4);
    args.add(a5);
    invocations.add(args);

    var withoutNulls = new List.from(args);
    while (!withoutNulls.isEmpty && withoutNulls.last == null) {
      withoutNulls.removeLast();
    }
    invocationsWithoutTrailingNulls.add(withoutNulls);

    if (_andCallFakeFn != null) {
      utils.relaxFnApply(_andCallFakeFn, args);
    }
  }

  andCallFake(fn) {
    _andCallFakeFn = fn;
    return this;
  }

  reset() => invocations = [];

  num get count => invocations.length;
  bool get called => count > 0;

  num get callCount => count;
  get argsForCall => invocationsWithoutTrailingNulls;

  firstArgsMatch(a,b,c,d,e,f) {
    var fi = invocations.first;
    assert(fi.length == 6);
    if ("${fi[0]}" != "$a") return false;
    if ("${fi[1]}" != "$b") return false;
    if ("${fi[2]}" != "$c") return false;
    if ("${fi[3]}" != "$d") return false;
    if ("${fi[4]}" != "$e") return false;
    if ("${fi[5]}" != "$f") return false;

    return true;
  }

  get mostRecentCall {
    if (invocations.isEmpty) {
      throw ["No calls"];
    }
    return new SpyFunctionInvocationResult(invocations.last);
  }
}

class Jasmine {
  createSpy([String name]) {
    return new SpyFunction(name);
  }

  SpyFunction spyOn(receiver, methodName) {
    throw ["spyOn not implemented"];
  }
}

main(){
  unit.setUp(currentDescribe.setUp);
}
