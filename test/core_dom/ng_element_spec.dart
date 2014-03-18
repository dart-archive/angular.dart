library ng_element_spec;

import '../_specs.dart';
import 'dart:html' as dom;

void main() {
  describe('ngElement', () {
    TestBed _;
    NgAnimate animate;
    NgElement ngElement;
    JQuery element;

    beforeEach((TestBed testBed, NgAnimate ngAnimate) {
      _ = testBed;
      animate = ngAnimate;
    });

    compile(str) {
      element = _.compile(str);
      ngElement = new NgElement(_.rootElement, _.rootScope, animate);
    }

    it('should add classes on domWrite to the element', () {
      compile('<div></div>');

      ngElement.addClass('one');
      ngElement.addClass('two three');

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(false);
      });

      _.rootScope.apply();

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(true);
      });
    });

    it('should remove classes on domWrite to the element', () {
      compile('<div class="one two three four"></div>');

      ngElement.removeClass('one');
      ngElement.removeClass('two');
      ngElement.removeClass('three');

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(true);
      });
      expect(element.classes.contains('four')).toBe(true);

      _.rootScope.apply();

      ['one','two','three'].forEach((className) {
        expect(element.classes.contains(className)).toBe(false);
      });
      expect(element.classes.contains('four')).toBe(true);
    });

    it('should always apply the last dom operation on the given className', () {
      compile('<div></div>');

      ngElement.addClass('one');
      ngElement.addClass('one');
      ngElement.removeClass('one');

      expect(element.classes.contains('one')).toBe(false);

      _.rootScope.apply();

      expect(element.classes.contains('one')).toBe(false);

      element.classes.add('one');

      ngElement.removeClass('one');
      ngElement.removeClass('one');
      ngElement.addClass('one');

      expect(element.classes.contains('one')).toBe(true);
    });
  });
}
