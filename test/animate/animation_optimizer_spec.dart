library animation_optimizer_spec;

import '../_specs.dart';

main() {
  describe('AnimationLoop', () {
    TestBed _;
    AnimationOptimizer optimizer;
    beforeEach(inject((TestBed tb, Expando expand) {
      _ = tb;
      optimizer = new AnimationOptimizer(expand);
    }));
    
    it('should track and forget animations on elements', () {
      var animation = new NoOpAnimation();
      _.compile('<div></div>');
      
      expect(optimizer.isAnimating(_.rootElement)).toBeFalsy();
      optimizer.track(animation, _.rootElement);
      expect(optimizer.isAnimating(_.rootElement)).toBeTruthy();
      optimizer.forget(animation);
      expect(optimizer.isAnimating(_.rootElement)).toBeFalsy();
    });
    
    it('should prevent animations on child elements', () {
      var animation = new NoOpAnimation();
      _.compile('<div><div></div></div>');
      

      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();
      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();
    });
    
    it('should allow multiple animations on the same element', () {
      var animation1 = new NoOpAnimation();
      var animation2 = new NoOpAnimation();
      _.compile('<div><div></div></div>');
      
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      optimizer.track(animation1, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      optimizer.track(animation2, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation1);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      optimizer.forget(animation2);
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();
    });
  });
}
