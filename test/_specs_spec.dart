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
}
