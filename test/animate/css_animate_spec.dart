library css_animation_spec;

import 'dart:async';

import '../_specs.dart';

main() {
  describe('CssAnimate', () {
    TestBed _;
    Animate animate;

    beforeEach(inject((TestBed tb) {
      _ = tb;
      animate = new CssAnimate(
          new MockAnimationRunner(), new NoAnimate());
    }));

    it('should add a css class to nodes', async(() {
      _.compile('<div></div>');
      expect(_.rootElement).not.toHaveClass('foo');
      
      animate.addClass(_.rootElements, 'foo');
      expect(_.rootElement).toHaveClass('foo');
    }));
    
    it('should remove a css class from nodes', async(() {
      _.compile('<div class="baz foo bar"></div>');
      expect(_.rootElement).toHaveClass('foo');

      animate.removeClass(_.rootElements, 'foo');
      expect(_.rootElement).not.toHaveClass('foo');
    }));
    
    it('should insert nodes', async(() {
      _.compile('<div></div>');
      expect(_.rootElement.children.length).toBe(0);

      animate.insert([new Element.div()], _.rootElement);
      expect(_.rootElement.children.length).toBe(1);
    }));
    
    it('should remove nodes', async(() {
      _.compile('<div><p>Hello World</p><!--comment--></div>');
      expect(_.rootElement.childNodes.length).toBe(2);

      animate.remove(_.rootElement.childNodes);
      // This might lead to a flash of unstyled content before
      // removal. It would be nice if this was un-needed.
      microLeap();
      expect(_.rootElement.childNodes.length).toBe(0);
    }));
    
    it('should move nodes', async(() {
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
    }));
    
    xit('should compute duration based on event style', () {      
    });
    
    xit('should animate multiple elements', () {
      // FIXME: Implement
    });
    
    xit('should prevent child animations', () {
      // FIXME: Implement
    });
    
    xit('should interrupt existing animations', () {
      // FIXME: Implement
    });
    
    xit('should play any Animation', () {
      // FIXME: Implement
    });
    
    xit('should interrupt arbetrary animations', () {
      // FIXME: Implement
    });
  });
}

class MockAnimationRunner extends Mock implements AnimationRunner {
  bool hasRunningParentAnimationValue = false;
  
  AnimationHandle play(Animation animation) {
    animation.attach();
    animation.start(new DateTime.now(), 0.0);
    animation.update(new DateTime.now(), 0.0);
    animation.detach(new DateTime.now(), 0.0);
    return new MockAnimationHandle();
  }
  
  bool hasRunningParentAnimation(Element element) {
    return hasRunningParentAnimationValue;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAnimationHandle extends Mock implements AnimationHandle {
  Future<AnimationResult> get onCompleted {
    var cmp = new Completer<AnimationResult>();
    cmp.complete(AnimationResult.COMPLETED);
    return cmp.future;
  }
  
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}