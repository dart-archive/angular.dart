import '../_specs.dart';
import 'dart:html' as dom;


main() {
  beforeEach(module(angularModule));

  describe('NgCloak', () {
    var compile, element, rootScope;

    triggerEvent(elementWrapper, name) {
      elementWrapper[0].dispatchEvent(new dom.Event.eventType('MouseEvent', name));
    }

    beforeEach(inject((Scope scope, Compiler compiler) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(element).attach(scope);
        scope.$apply(applyFn);
      };
    }));


    it('should remove ng-cloak when compiled', () {
      compile('<div><span ng-cloak></span></div>');
      expect(element.html()).toEqual('<span></span>');
    });
  });
}
