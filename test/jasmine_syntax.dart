library jamine;

import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;

it(name, fn) => test(name, fn);
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}
xdescribe(name, fn) {}

class Describe {
  Describe parent;
  String name;
  List<Function> beforeEachFns = [];
  List<Function> afterEachFns = [];

  Describe(this.name, this.parent);

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

describe(name, fn) {
  var lastDescribe = currentDescribe;
  currentDescribe = new Describe(name, lastDescribe);
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

main(){}
