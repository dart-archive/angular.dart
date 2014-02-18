library animation_handle_spec;

import '../_specs.dart';

main() {
  describe('NoAniamte', () {
    TestBed _;
    beforeEach(inject((TestBed tb) => _ = tb));
    
    it('should exist',
        inject((NgAnimate aniamte) {
      expect(aniamte).toBeDefined();
    }));

    it('should add a css classes to nodes.', () {
      var animate = new NoAnimate();
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');
      animate.addClass(_.rootElements, 'foo');
      expect(_.rootElement).toHaveClass('foo');
    });
    
    it('should remove css classes from nodes.', () {
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
    
    it('should move nodes and elements', () {
      var animate = new NoAnimate();
      _.compile('<div></div>');
      List<Node> a = $('<span>A</span>a').toList();
      List<Node> b = $('<span>B</span>b').toList();
      a.forEach((n) => _.rootElement.append(n));
      b.forEach((n) => _.rootElement.append(n));
      
      expect(_.rootElement.text).toEqual("AaBb");

      animate.move(b, _.rootElement, insertBefore: a.first);
      expect(_.rootElement.text).toEqual("BbAa");
      
      animate.move(a, _.rootElement, insertBefore: b.first);
      expect(_.rootElement.text).toEqual("AaBb");
      
      animate.move(a, _.rootElement);
      expect(_.rootElement.text).toEqual("BbAa");
    });
  });
}
