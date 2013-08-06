import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgShow', () {
    var compile, element, rootScope;

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(injector, element);
        scope.$apply(applyFn);
        nextTurn(true);
      };
    }));


    it('should add/remove ng-show class', async(() {
      compile('<div ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('ng-show');

      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      nextTurn(true);

      expect(element).toHaveClass('ng-show');

      rootScope.$apply(() {
        rootScope['isVisible'] = false;
      });
      nextTurn(true);

      expect(element).not.toHaveClass('ng-show');
    }));

    it('should work together with ng-class', async(() {
      compile('<div ng-class="currentCls" ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      rootScope.$apply(() {
        rootScope['currentCls'] = 'active';
      });
      nextTurn(true);

      expect(element).toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      rootScope.$apply(() {
        rootScope['isVisible'] = true;
      });
      nextTurn(true);

      expect(element).toHaveClass('active');
      expect(element).toHaveClass('ng-show');
    }));
  });
}
