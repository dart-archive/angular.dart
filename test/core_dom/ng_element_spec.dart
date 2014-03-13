library ng_element_spec;

import '../_specs.dart';
import 'dart:html' as dom;

void main() {
  describe('ngElement', () {

    it('should add classes on domWrite to the element',
      inject((TestBed _, NgAnimate animate) {

      var scope = _.rootScope;
      var element = _.compile('<div></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement.addClass('one');
      ngElement.addClass('two three');

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(false);
      });

      scope.apply();

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(true);
      });
    }));

    it('should remove classes on domWrite to the element',
      inject((TestBed _, NgAnimate animate) {

      var scope = _.rootScope;
      var element = _.compile('<div class="one two three four"></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement.removeClass('one');
      ngElement.removeClass('two');
      ngElement.removeClass('three');

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(true);
      });
      expect(element.classes.contains('four')).toBe(true);

      scope.apply();

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(false);
      });
      expect(element.classes.contains('four')).toBe(true);
    }));

    it('should always apply the last dom operation on the given className',
      inject((TestBed _, NgAnimate animate) {

      var scope = _.rootScope;
      var element = _.compile('<div></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement.addClass('one');
      ngElement.addClass('one');
      ngElement.removeClass('one');

      expect(element.classes.contains('one')).toBe(false);

      scope.apply();

      expect(element.classes.contains('one')).toBe(false);

      element.classes.add('one');

      ngElement.removeClass('one');
      ngElement.removeClass('one');
      ngElement.addClass('one');

      expect(element.classes.contains('one')).toBe(true);
    }));
  });
}
