library ng_hide_spec;

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
      };
    }));


    it('should add/remove ng-hide class', () {
      compile('<div ng-hide="isHidden"></div>');

      expect(element).not.toHaveClass('ng-hide');

      rootScope.$apply(() {
        rootScope['isHidden'] = true;
      });
      expect(element).toHaveClass('ng-hide');

      rootScope.$apply(() {
        rootScope['isHidden'] = false;
      });
      expect(element).not.toHaveClass('ng-hide');
    });
  });
}
