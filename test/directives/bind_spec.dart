import "../_specs.dart";

main() {
  // NOTE(deboer): beforeEach and nested describes don't play nicely.  Repeat.
  beforeEach(() => currentSpecInjector = new SpecInjector());
  beforeEach(module(angularModule));
  afterEach(() => currentSpecInjector = null);

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
