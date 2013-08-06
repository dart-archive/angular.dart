import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgHide', () {
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


    it('should add/remove ng-hide class', async(() {
      compile('<div ng-hide="isHidden"></div>');

      expect(element).not.toHaveClass('ng-hide');

      rootScope.$apply(() {
        rootScope['isHidden'] = true;
      });
      nextTurn(true);

      expect(element).toHaveClass('ng-hide');

      rootScope.$apply(() {
        rootScope['isHidden'] = false;
      });
      nextTurn(true);

      expect(element).not.toHaveClass('ng-hide');
    }));
  });
}
