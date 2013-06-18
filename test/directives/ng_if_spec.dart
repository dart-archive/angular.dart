import '../_specs.dart';
import 'dart:html' as dom;


main() {
  beforeEach(module(angularModule));

  describe('NgIf', () {
    var compile, element, rootScope;

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(injector, element);
        scope.$apply(applyFn);
      };
    }));


    xit('should add/remove the element', () {
      compile('<div><span ng-if="isVisible">content</span></div>');

      expect(element.find('span').html()).toEqual('');

      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      expect(element.find('span').html()).toEqual('content');

      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
    });
  });
}
