library ng_cloak_spec;

import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgCloak', () {
    var compile, element, rootScope;

    triggerEvent(elementWrapper, name) {
      elementWrapper[0].dispatchEvent(new dom.Event.eventType('MouseEvent', name));
    }

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(injector, element);
        scope.$apply(applyFn);
      };
    }));


    it('should remove ng-cloak when compiled', () {
      compile('<div><span ng-cloak></span></div>');
      expect(element.html()).toEqual('<span></span>');
    });
  });
}
