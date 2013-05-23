import "../_specs.dart";

main() {

  // TODO move the "inject" function into a shared library.
  var specInjector = new SpecInjector();
  var inject = specInjector.inject;

  beforeEach(() {
    specInjector.reset();
  });

  afterEach(() {
    specInjector.reset();
  });

  describe('BindDirective', inject((Injector injector) {
    it('should set text', () {
      var element = $('<div bind="a"></div>');
      expect(element.text()).toEqual('');

      var module = new Module();
      module.value(Element, element[0]);
      module.value(DirectiveValue, new DirectiveValue.fromString('a'));
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
