import "../_specs.dart";

main() {
  describe('BindDirective', () {
    it('should set text', inject((Scope scope) {
      var element = $('<div></div>');
      expect(element.text()).toEqual('');

      var module = new Module();
      module.value(Element, element[0]);
      module.value(DirectiveValue, new DirectiveValue.fromString('a'));
      var bind = new Injector([module]).get(NgBindAttrDirective);

      var VALUE_FOR_A = 'valueFromScope';

      scope['a'] = VALUE_FOR_A;
      bind.attach(scope);
      scope.$digest();

      expect(element.text()).toEqual(VALUE_FOR_A);
    }));
  });
}
