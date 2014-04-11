library no_animate_spec;

import '../_specs.dart';

main() {
  describe('NgAniamte', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should exist',
        (Animate aniamte) {
      expect(aniamte).toBeDefined();
    });

    it('should add a css classes to nodes.', () {
      var animate = new Animate();
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');
      animate.addClass(_.rootElement, 'foo');
      expect(_.rootElement).toHaveClass('foo');
    });

    it('should remove css classes from nodes.', () {
      var animate = new Animate();
      _.compile('<div class="foo"></div>');
      expect(_.rootElement).toHaveClass('foo');
      animate.removeClass(_.rootElement, 'foo');
      expect(_.rootElement).not.toHaveClass('foo');
    });

    it('should insert elements', () {
      var animate = new Animate();
      _.compile('<div></div>');
      expect(_.rootElement.children.length).toBe(0);
      animate.insert([new Element.div()], _.rootElement);
      expect(_.rootElement.children.length).toBe(1);
    });

    it('should remove nodes and elements', () {
      var animate = new Animate();
      _.compile('<div><p>Hello World</p><!--comment--></div>');
      expect(_.rootElement.childNodes.length).toBe(2);
      animate.remove(_.rootElement.childNodes);
      expect(_.rootElement.childNodes.length).toBe(0);
    });

    it('should move nodes and elements', () {
      var animate = new Animate();
      _.compile('<div></div>');
      List<Node> a = es('<span>A</span>a');
      List<Node> b = es('<span>B</span>b');
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
  
  describe('NoOpAnimation', () {
    it('should not do anything async unless the future is asked for', () {
      var completer = new NoOpAnimation();
      expect(completer).toBeDefined();
    });
        
    it('should create a future once onCompleted is accessed', () {
      expect(() => new NoOpAnimation().onCompleted).toThrow();
    });
        
    it('should return a [COMPLETED_IGNORED] result when completed.', async(() {
      bool success = false;
      new NoOpAnimation().onCompleted.then((result) {
        if (result == AnimationResult.COMPLETED_IGNORED) {
          success = true;
        }
      });
      microLeap();
      expect(success).toBe(true);
    }));
  });
}
