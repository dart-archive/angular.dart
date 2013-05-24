import "../_specs.dart";
import "dart:mirrors";


main() {
  describe('BindDirective', () {
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
  });
}
