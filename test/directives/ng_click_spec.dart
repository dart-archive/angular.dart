import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgClick', () {
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


    it('should evaluate the expression on click', () {
      compile(r'<button ng-click="abc = true; event = $event"></button>');
      triggerEvent(element, 'click');
      expect(rootScope['abc']).toEqual(true);
      expect(rootScope['event'] is dom.MouseEvent).toEqual(true);
    });
  });
}
