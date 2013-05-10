import "../_specs.dart";
import "dart:mirrors";


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
      var bind = new Injector([module]).get(NgBindAttrDirective);

      var scope = new Scope();
      var VALUE_FOR_A = 'valueFromScope';

      scope['a'] = VALUE_FOR_A;
      bind.attach(scope);
      scope.$digest();

      expect(element.text()).toEqual(VALUE_FOR_A);
    });
  }));
}
