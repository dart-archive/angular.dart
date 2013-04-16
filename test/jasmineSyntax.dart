import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;
import 'debug.dart';
export 'debug.dart';

it(name, fn) => test(name, fn);
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}

//TODO(dart): why are the beforeEach not nested? -> code.google.com/p/dart/issues

//TODO(dart): I should not have to do this!
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

describe(name, fn) => group(name, printExceptions(fn));

beforeEach(fn) => setUp(printExceptions(fn));
afterEach(fn) => tearDown(printExceptions(fn));

main(){}
