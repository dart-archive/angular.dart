import '../_specs.dart';
import 'dart:html' as dom;


main() {
  beforeEach(module(angularModule));

  describe('NgClick', () {
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


    it('should evaluate the expression on click', () {
      compile('<button ng-click="abc = true"></button>');
      triggerEvent(element, 'click');
      expect(rootScope['abc']).toEqual(true);
    });
  });
}
