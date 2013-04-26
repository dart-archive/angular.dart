library jamine;

import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;

it(name, fn) => test(name, fn);
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}
xdescribe(name, fn) {}

//TODO(dart): why are the beforeEach not nested? -> code.google.com/p/dart/issues

//TODO(dart): I should not have to do this!
// https://code.google.com/p/dart/issues/detail?id=9899
printExceptions(fn) {
  return () {
    try {
      fn();
    } catch (e, stackTrace) {
      var log1 = "${e.toString()}";
      var log2 = "${stackTrace}";
      js.scoped(() {
        js.context.console.log(log1);
        js.context.console.log(log2);
      });
      throw e;
    }
  };
}

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
      printExceptions(fn)();
      tearDown(currentDescribe.tearDown);
    });
  } finally {
    currentDescribe = lastDescribe;
  }
}

beforeEach(fn) => currentDescribe.beforeEachFns.add(printExceptions(fn));
afterEach(fn) => currentDescribe.afterEachFns.add(printExceptions(fn));

main(){}
