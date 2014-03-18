library angular.mock.jquery_spec;

import '../_specs.dart';

main() {
  describe('jquery', () {
    describe('html', () {
      it('get', (){
        var div = $('<div>');
        expect(div.html()).toEqual('');
      });

      it('should strip ng-binding', () {
        var div = $('<div><span class="ng-binding"></span></div>');
        expect(div.html()).toEqual('<span></span>');
      });

      it('set', (){
        var div = $('<div>');
        expect(div.html('text')).toBe(div);
        expect(div.html()).toEqual('text');
      });
    });

    describe('shadowRoot', () {
      it('should return the shadowRoot if one exists', () {
        var elts = $('<div></div>');
        elts[0].createShadowRoot().innerHtml = "Hello shadow";
        expect(elts.shadowRoot().text()).toEqual("Hello shadow");
      });

      it('should return empty list if there is no shadowRoot', () {
        expect($('<div></div>').shadowRoot()).toEqual([]);
      });

      it('should print the html for the shadowRoot', () {
        var elts = $('<div></div>');
        elts[0].createShadowRoot().innerHtml = '<div class="ng-binding">Hello shadow</div>';
        expect(elts.shadowRoot().html()).toEqual('<div>Hello shadow</div>');
      });
    });

    describe('textWithShadow', () {
      it('should work on regular DOM nodes', () {
        expect($('<span>A<span>C</span></span><span>B</span>').textWithShadow()).toEqual('ACB');
      });

      it('should work with shadow DOM', () {
        var elt = $('<div>DOM content</div>');
        var shadow = elt[0].createShadowRoot();
        shadow.setInnerHtml(
            '<div>Shadow content</div><content>SHADOW-CONTENT</content>',
            treeSanitizer: new NullTreeSanitizer());
        expect(elt.textWithShadow()).toEqual('Shadow contentDOM content');
      });

      it('should ignore comments', () {
        expect($('<!--e--><span>A<span>C</span></span><span>B</span>').textWithShadow()).toEqual('ACB');
      });
    });
  });
}
