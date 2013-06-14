library jamine;

import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;

it(name, fn) {
  if (currentDescribe.exclusive) {
    solo_test(name, fn);
  } else {
    test(name, fn);
  }
}
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}
xdescribe(name, fn) {}
ddescribe(name, fn) => describe(name, fn, true);


class Describe {
  Describe parent;
  String name;
  bool exclusive;
  List<Function> beforeEachFns = [];
  List<Function> afterEachFns = [];

  Describe(this.name, this.parent, [bool this.exclusive=false]) {
    if (parent != null && parent.exclusive) {
      exclusive = true;
    }
  }

  setUp() {
    if (parent != null) {
      parent.setUp();
    }
    beforeEachFns.forEach((fn) => fn());
  }

  tearDown() {
    afterEachFns.reverse.forEach((fn) => fn());
    if (parent != null) {
      parent.tearDown();
    }
  }
}

Describe currentDescribe = new Describe('', null);

describe(name, fn, [bool exclusive=false]) {
  var lastDescribe = currentDescribe;
  currentDescribe = new Describe(name, lastDescribe, exclusive);
  try {
    group(name, () {
      setUp(currentDescribe.setUp);
      fn();
      tearDown(currentDescribe.tearDown);
    });
  } finally {
    currentDescribe = lastDescribe;
  }
}

beforeEach(fn) => currentDescribe.beforeEachFns.add(fn);
afterEach(fn) => currentDescribe.afterEachFns.add(fn);

var jasmine = new Jasmine();

class SpyFunction {
  String name;
  List<List<dynamic>> invocations = [];

  SpyFunction([this.name]);
  call([a0, a1, a2, a3, a4, a5, a6]) {
    var args = [];
    if (?a0) args.add(a0);
    if (?a1) args.add(a1);
    if (?a2) args.add(a2);
    if (?a3) args.add(a3);
    if (?a4) args.add(a4);
    if (?a5) args.add(a5);
    if (?a6) args.add(a6);
    invocations.add(args);
  }

  reset() => invocations = [];

  num get count => invocations.length;
  bool get called => count > 0;
}

class Jasmine {
  createSpy([String name]) {
    return new SpyFunction(name);
  }
}

main(){}
