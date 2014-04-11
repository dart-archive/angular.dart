library ng_element_spec;

import '../_specs.dart';

void main() {
  describe('ngElement', () {

    describe('classes', () {
      it('should add classes to the element on domWrite',
          (TestBed _, Animate animate) {

        var scope = _.rootScope;
        var element = e('<div></div>');
        var ngElement = new NgElement(element, scope, animate);

        ngElement..addClass('one')..addClass('two three');

        ['one', 'two', 'three'].forEach((className) {
          expect(element).not.toHaveClass(className);
        });

        scope.apply();

        ['one', 'two', 'three'].forEach((className) {
          expect(element).toHaveClass(className);
        });
      });

      it('should remove classes from the element on domWrite',
          (TestBed _, Animate animate) {

        var scope = _.rootScope;
        var element = e('<div class="one two three four"></div>');
        var ngElement = new NgElement(element, scope, animate);

        ngElement..removeClass('one')
                 ..removeClass('two')
                 ..removeClass('three');

        ['one', 'two', 'three', 'four'].forEach((className) {
          expect(element).toHaveClass(className);
        });

        scope.apply();

        ['one', 'two', 'three'].forEach((className) {
          expect(element).not.toHaveClass(className);
        });
        expect(element).toHaveClass('four');
      });

      it('should always apply the last dom operation on the given className',
          (TestBed _, Animate animate) {

        var scope = _.rootScope;
        var element = e('<div></div>');
        var ngElement = new NgElement(element, scope, animate);

        ngElement..addClass('one')
                 ..addClass('one')
                 ..removeClass('one');

        expect(element).not.toHaveClass('one');

        scope.apply();

        expect(element).not.toHaveClass('one');

        ngElement..removeClass('one')
                 ..removeClass('one')
                 ..addClass('one');

        scope.apply();

        expect(element).toHaveClass('one');
      });
    });
  });

  describe('attributes', () {
    it('should set attributes on domWrite to the element',
        (TestBed _, Animate animate) {

      var scope = _.rootScope;
      var element = e('<div></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement.setAttribute('id', 'foo');
      ngElement.setAttribute('title', 'bar');

      ['id', 'title'].forEach((name) {
        expect(element).not.toHaveAttribute(name);
      });

      scope.apply();

      expect(element).toHaveAttribute('id', 'foo');
      expect(element).toHaveAttribute('title', 'bar');
    });

    it('should remove attributes from the element on domWrite ',
        (TestBed _, Animate animate) {

      var scope = _.rootScope;
      var element = e('<div id="foo" title="bar"></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement..removeAttribute('id')
               ..removeAttribute('title');

      expect(element).toHaveAttribute('id', 'foo');
      expect(element).toHaveAttribute('title', 'bar');

      scope.apply();

      expect(element).not.toHaveAttribute('id');
      expect(element).not.toHaveAttribute('title');
    });

    it('should always apply the last operation on the attribute',
        (TestBed _, Animate animate) {

      var scope = _.rootScope;
      var element = e('<div></div>');
      var ngElement = new NgElement(element, scope, animate);

      ngElement..setAttribute('id', 'foo')
               ..setAttribute('id', 'foo')
               ..removeAttribute('id');

      expect(element).not.toHaveAttribute('id');

      scope.apply();

      expect(element).not.toHaveAttribute('id');

      ngElement..removeAttribute('id')
               ..setAttribute('id', 'foobar')
               ..setAttribute('id', 'foo');

      scope.apply();

      expect(element).toHaveAttribute('id', 'foo');

    });
  });
}
