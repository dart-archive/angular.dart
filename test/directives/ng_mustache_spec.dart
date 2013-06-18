import "../_specs.dart";

main() {
  describe('ng-mustache', () {
    beforeEach(module(angularModule));

    it('should replace {{}} in text', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div>{{name}}<span>!</span></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template(injector);

      element = $(block.elements);

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    it('should replace {{}} in attribute', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div some-attr="{{name}}"></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template(injector);

      element = $(block.elements);

      expect(element.attr('some-attr')).toEqual('');
      $rootScope.$digest();
      expect(element.attr('some-attr')).toEqual('OK');
    }));
  });
}
