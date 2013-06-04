import "_specs.dart";

main() {
  describe('renderedText', () {
    it('should work on regular DOM nodes', () {
      expect(renderedText($('<span>A<span>C</span></span><span>B</span>'))).toEqual('ACB');
    });

    it('should work with shadow DOM', () {
      var elt = $('<div>DOM content</div>');
      var shadow = elt[0].createShadowRoot();
      shadow.innerHtml = '<div>Shadow content</div><content>SHADOW-CONTENT</content>';
      expect(renderedText(elt)).toEqual('Shadow contentDOM content');
    });

    it('should ignore comments', () {
      expect(renderedText($('<!--e--><span>A<span>C</span></span><span>B</span>'))).toEqual('ACB');
    });
  });


  describe('jquery', () {
    describe('html', () {
      it('get', (){
        var div = $('<div>');
        expect(div.html()).toEqual('');
      });

      it('set', (){
        var div = $('<div>');
        expect(div.html('text')).toBe(div);
        expect(div.html()).toEqual('text');
      });
    });

  });
}
