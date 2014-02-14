library animation_handle_spec;

import '../_specs.dart';

main() {
  ddescribe('NoAniamte', () {
    TestBed _;
    beforeEach(inject((TestBed tb) => _ = tb));
    
    it('should exist',
        inject((Animate aniamte) {
      expect(aniamte).toBeDefined();
    }));

    it('should add css classes to elements.', () {
      var animate = new NoAnimate();
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');
      animate.addClass(_.rootElements, 'foo');
      expect(_.rootElement).toHaveClass('foo');
    });
    
    it('should remove css classes to elements.', () {
      var animate = new NoAnimate();
      _.compile('<div class="foo"></div>');
      expect(_.rootElement).toHaveClass('foo');
      animate.removeClass(_.rootElements, 'foo');
      expect(_.rootElement).not.toHaveClass('foo');
    });
    
    it('should insert elements', () {
      var animate = new NoAnimate();
      _.compile('<div></div>');
      expect(_.rootElement.children.length).toBe(0);
      animate.insert([new Element.div()], _.rootElement);
      expect(_.rootElement.children.length).toBe(1);
    });
    
    it('should remove nodes and elements', () {
      var animate = new NoAnimate();
      _.compile('<div><p>Hello World</p><!--comment--></div>');
      expect(_.rootElement.childNodes.length).toBe(2);
      animate.remove(_.rootElement.childNodes);
      expect(_.rootElement.childNodes.length).toBe(0);
    });
    
    xit('should move nodes and elements', () {
      // FIXME detect move
    });
  });
}
