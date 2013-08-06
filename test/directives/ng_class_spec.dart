import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgClass', () {
    var compile, element, rootScope;

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      rootScope = scope;

      compile = (html, [applyFn]) {
        element = $(html);
        compiler(element)(injector, element);
        scope.$apply(applyFn);
      };
    }));


    it('should add and remove class dynamically', async(() {
      compile('<div ng-class="active"></div>');

      rootScope.$apply(() {
        rootScope['active'] = 'active';
      });
      nextTurn(true);

      expect(element.hasClass('active')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'inactive';
      });
      nextTurn(true);

      expect(element.hasClass('active')).toBe(false);
      expect(element.hasClass('inactive')).toBe(true);
    }));


    it('should preserve originally defined classes', async(() {
      compile('<div class="original" ng-class="active"></div>');

      expect(element.hasClass('original')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'something';
      });
      nextTurn(true);

      expect(element.hasClass('original')).toBe(true);
    }));


    it('should preserve classes that has been added after compilation', async(() {
      compile('<div ng-class="active"></div>');

      element[0].classes.add('after-compile');
      expect(element.hasClass('after-compile')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'something';
      });
      nextTurn(true);

      expect(element.hasClass('after-compile')).toBe(true);
    }));


    it('should allow multiple classes separated by a space', async(() {
      compile('<div class="original" ng-class="active"></div>');

      rootScope.$apply(() {
        rootScope['active'] = 'first second';
      });
      nextTurn(true);

      expect(element).toHaveClass('first');
      expect(element).toHaveClass('second');
      expect(element).toHaveClass('original');

      rootScope.$apply(() {
        rootScope['active'] = 'third first';
      });
      nextTurn(true);

      expect(element).toHaveClass('first');
      expect(element).not.toHaveClass('second');
      expect(element).toHaveClass('third');
      expect(element).toHaveClass('original');
    }));


    it('should update value that was set before compilation', async(() {
      rootScope['active'] = 'something';
      compile('<div ng-class="active"></div>');
      nextTurn(true);

      expect(element).toHaveClass('something');
    }));
  });
}
