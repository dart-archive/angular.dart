library ng_if_spec;

import '../_specs.dart';
import 'dart:html' as dom;

class ChildController {
  ChildController(Scope scope) {
    scope.setBy = 'childController';
  }
}

main() {
  describe('NgIf', () {
    var compile, element, rootScope;

    beforeEach(module((AngularModule module) {
      module
        ..controller('Child', ChildController)
        ..directive(LogAttrDirective);
    }));

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      rootScope = scope;
      compile = (html, [applyFn]) {
        element = $(html);
        compiler(element)(injector, element);
        scope.$apply(applyFn);
      };
    }));

    it('should add/remove the element', () {
      compile('<div><span ng-if="isVisible">content</span></div>');

      // The span node should NOT exist in the DOM.
      expect(element.contents().length).toEqual(1);
      expect(element.find('span').html()).toEqual('');

      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      // The span node SHOULD exist in the DOM.
      expect(element.contents().length).toEqual(2);
      expect(element.find('span').html()).toEqual('content');

      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
    });

    it('should create a child scope', () {
      rootScope['setBy'] = 'topLevel';
      compile('<div>' +
              '  <div ng-if="isVisible">'.trim() +
              '    <span ng-controller="Child" id="inside">{{setBy}}</span>'.trim() +
              '  </div>'.trim() +
              '  <span id="outside">{{setBy}}</span>'.trim() +
              '</div>');
      expect(element.contents().length).toEqual(2);

      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      expect(element.contents().length).toEqual(3);
      // The value on the parent scope should be unchanged.
      expect(rootScope['setBy']).toEqual('topLevel');
      expect(element.find('#outside').html()).toEqual('topLevel');
      // A child scope must have been created and hold a different value.
      expect(element.find('#inside').html()).toEqual('childController');
    });

    it('should play nice with other elements beside it', () {
      var values = rootScope['values'] = [1, 2, 3, 4];
      compile('<div>' +
              '<div ng-repeat="i in values"></div>' +
              '<div ng-if="values.length==4"></div>' +
              '<div ng-repeat="i in values"></div>' +
              '</div>');
      expect(element.contents().length).toBe(12);
      rootScope.$apply(() {
        values.removeRange(0, 1);
      });
      expect(element.contents().length).toBe(9);
      rootScope.$apply(() {
        values.insert(0, 1);
      });
      expect(element.contents().length).toBe(12);
    });

    it('should restore the element to its compiled state', () {
      rootScope['isVisible'] = true;
      compile('<div><span class="my-class" ng-if="isVisible">content</span></div>');
      expect(element.contents().length).toEqual(2);
      element.find('span').removeClass('my-class');
      expect(element.find('span').hasClass('my-class')).not.toBe(true);
      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.contents().length).toEqual(1);
      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      // The newly inserted node should be a copy of the compiled state.
      expect(element.find('span').hasClass('my-class')).toBe(true);
    });

    it('should not cause ng-click to throw an exception', () {
      compile('<div><span ng-click="click" ng-if="isVisible">content</span></div>');
      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
    });

    it('should prevent other directives from running when disabled', inject((Logger log) {
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
