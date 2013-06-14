import "../_specs.dart";
import '../jasmine_syntax.dart';

main() {
  describe('ng-mustache', () {
    beforeEach(module(angularModule));

    it('should replace {{}} in text', inject((Compiler $compile, Scope $rootScope) {
      var element = $('<div>{{name}}<span>!</span></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template();

      element = $(block.elements);

      block.attach($rootScope);

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    it('should replace {{}} in attribute', inject((Compiler $compile, Scope $rootScope) {
      var element = $('<div some-attr="{{name}}"></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template();

      element = $(block.elements);

      block.attach($rootScope);

      expect(element.attr('some-attr')).toEqual('');
      $rootScope.$digest();
      expect(element.attr('some-attr')).toEqual('OK');
    }));
  });
}
