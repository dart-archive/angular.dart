import "../_specs.dart";

main() {
  describe('BindDirective', () {
    it('should set text', inject((Scope scope, Injector injector, Compiler compiler) {
      var element = $('<div ng-bind="a"></div>');
      compiler(element)(injector, element);
      scope.a = "abc123";
      scope.$digest();
      expect(element.text()).toEqual('abc123');
    }));
  });
}
