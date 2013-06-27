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


    it('should add and remove class dynamically', () {
      compile('<div ng-class="active"></div>');

      rootScope.$apply(() {
        rootScope['active'] = 'active';
      });
      expect(element.hasClass('active')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'inactive';
      });
      expect(element.hasClass('active')).toBe(false);
      expect(element.hasClass('inactive')).toBe(true);
    });


    it('should preserve originally defined classes', () {
      compile('<div class="original" ng-class="active"></div>');

      expect(element.hasClass('original')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'something';
      });
      expect(element.hasClass('original')).toBe(true);
    });


    it('should preserve classes that has been added after compilation', () {
      compile('<div ng-class="active"></div>');

      element[0].classes.add('after-compile');
      expect(element.hasClass('after-compile')).toBe(true);

      rootScope.$apply(() {
        rootScope['active'] = 'something';
      });
      expect(element.hasClass('after-compile')).toBe(true);
    });


    it('should allow multiple classes separated by a space', () {
      compile('<div class="original" ng-class="active"></div>');

      rootScope.$apply(() {
        rootScope['active'] = 'first second';
      });
      expect(element).toHaveClass('first');
      expect(element).toHaveClass('second');
      expect(element).toHaveClass('original');

      rootScope.$apply(() {
        rootScope['active'] = 'third first';
      });
      expect(element).toHaveClass('first');
      expect(element).not.toHaveClass('second');
      expect(element).toHaveClass('third');
      expect(element).toHaveClass('original');
    });


    it('should update value that was set before compilation', () {
      rootScope['active'] = 'something';
      compile('<div ng-class="active"></div>');
      expect(element).toHaveClass('something');
    });
  });
}
