import '../_specs.dart';
import '../_log.dart';
import 'dart:html' as dom;


main() {
  describe('NgIf', () {
    var compile, element, rootScope;

    beforeEach(module((AngularModule module) {
      module
        ..directive(LogAttrDirective);
    }));

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(injector, element);
        scope.$apply(applyFn);
      };
    }));

    it('should add/remove the element', () {
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

    it('should not cause ng-click to throw an exception', () {
      compile('<div><span ng-click="click" ng-if="isVisible">content</span></div>');
      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
    });

    it('should prevent other directives from running when disabled', inject((Log log) {
      compile('<div><li log="ALWAYS"></li><span log="JAMES" ng-if="isVisible">content</span></div>');

      expect(element.find('span').html()).toEqual('');

      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
      expect(log.result()).toEqual('ALWAYS');


      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      expect(element.find('span').html()).toEqual('content');
      expect(log.result()).toEqual('ALWAYS; JAMES');

    }));
  });
}
