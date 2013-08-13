import "../_specs.dart";

main() {
  describe('ng-mustache', () {
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
      var element = $('<div some-attr="{{name}}" other-attr="{{age}}"></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      $rootScope.age = 23;
      var block = template(injector);

      element = $(block.elements);

      expect(element.attr('some-attr')).toEqual('');
      expect(element.attr('other-attr')).toEqual('');
      $rootScope.$digest();
      expect(element.attr('some-attr')).toEqual('OK');
      expect(element.attr('other-attr')).toEqual('23');
    }));
  });
}
