library _specs_spec;

import '_specs.dart';

main() {
  describe('expect', () {
    describe('toHaveHtml', () {
      it('should return html', (){
        var div = es('<div>');
        expect(es('<div>')).toHaveHtml('');
      });

      it('should strip ng-binding', () {
        var div = es('<div><span class="ng-binding"></span></div>');
        expect(div).toHaveHtml('<span></span>');
      });
    });

    describe('toHaveText', () {
      it('should work on regular DOM nodes', () {
        expect(es('<span>A<span>C</span></span><span>B</span>')).toHaveText('ACB');
      });

      it('should work with shadow DOM', () {
        var elt = e('<div>DOM content</div>');
        var shadow = elt.createShadowRoot();
        shadow.setInnerHtml(
            '<div>Shadow content</div><content>SHADOW-CONTENT</content>',
            treeSanitizer: new NullTreeSanitizer());
        expect(elt).toHaveText('Shadow contentDOM content');
      });

      it('should ignore comments', () {
        expect(es('<!--e--><span>A<span>C</span></span><span>B</span>')).toHaveText('ACB');
      });
    });
  });

  describe('jquery', () {
    describe('shadowRoot', () {
      it('should return the shadowRoot if one exists', () {
        var elts = $('<div></div>');
        elts[0].createShadowRoot().innerHtml = "Hello shadow";
        expect(elts.shadowRoot()[0].text).toEqual("Hello shadow");
      });

      it('should return empty list if there is no shadowRoot', () {
        expect($('<div></div>').shadowRoot()).toEqual([]);
      });

      it('should print the html for the shadowRoot', () {
        var elts = $('<div></div>');
        elts[0].createShadowRoot().innerHtml = '<div class="ng-binding">Hello shadow</div>';
        expect(elts.shadowRoot()[0]).toHaveHtml('<div>Hello shadow</div>');
      });
    });
  });
}
