import "../_specs.dart";
import "dart:mirrors";

var VALUE_FOR_A = 'valueFromScope';

class MockScope {
  $watch(String value, doer) {
    if (value == 'a') {
      doer(VALUE_FOR_A);
    } else {
      throw "Not implemented";
    }
  }
}

main() {

  // TODO move the "inject" function into a shared library.
  var injector;

  inject(Function fn) {
    return () {
      if (injector == null) {
        injector = new Injector();
      }
      try {
        injector.invoke(fn);
      } catch (e,s) {
        if (e is MirroredUncaughtExceptionError) {
          throw e.exception_string + "\n ORIGINAL Stack trace:\n" + e.stacktrace.toString();
        }
        throw "Not mirrored" + e.toString() + " Stack trace:" + s.toString();
      }
    };
  }

  beforeEach(() {
    injector = null;
  });

  afterEach(() {
    injector = null;
  });

  describe('BindDirective', inject((Injector injector) {
    it('should set text', () {
      var element = $('<div bind="a"></div>');
      expect(element.text()).toEqual('');


      var module = new Module();
      module.value(List, element);
      module.value(BindValue, new BindValue.fromString('a'));
      //var bind = injector.createChild([module]).get(BindDirective);
      var bind = new Injector([module]).get(BindDirective);

      bind.attach(new MockScope());

      expect(element.text()).toEqual(VALUE_FOR_A);
    });
  }));
}
