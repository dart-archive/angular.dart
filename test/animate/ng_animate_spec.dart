library ng_animate_spec;

import '../_specs.dart';

main() {
  module((Module module) {
    module
      ..bind(AnimationOptimizer)
      ..bind(NgAnimate)
      ..bind(NgAnimateChildren);
  });
  describe('ng-animate', () {
    TestBed _;
    AnimationOptimizer optimizer;
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module
          ..bind(AnimationOptimizer)
          ..bind(NgAnimate)
          ..bind(NgAnimateChildren);
      });
      inject((TestBed tb, AnimationOptimizer opt) {
        _ = tb;
        optimizer = opt;
      });
    });

    afterEach(() {
      tearDownInjector();
    });

    it('should control animations on elements', () {
      _.compile('<div ng-animate="never"><div></div></div>');
      _.rootScope.apply();

      expect(optimizer.shouldAnimate(_.rootElement)).toBeFalsy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();

      _.compile('<div ng-animate="always">'
        + '<div ng-animate="never"></div></div>');
      _.rootScope.apply();
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();


      _.compile('<div ng-animate="never">'
      + '<div ng-animate="always"></div></div>');
      _.rootScope.apply();
      expect(optimizer.shouldAnimate(_.rootElement)).toBeFalsy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();
    });

    it('should control animations and override running animations', () {
      var animation = new NoOpAnimation();
      _.compile('<div><div ng-animate="always"></div></div>');
      _.rootScope.apply();
      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();

      animation = new NoOpAnimation();
      _.compile('<div><div ng-animate="auto"></div></div>');
      _.rootScope.apply();
      optimizer.track(animation, _.rootElement);
      expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
      expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
    });

    describe("children", () {
      it('should prevent child animations', () {
        _.compile('<div ng-animate-children="never"><div></div></div>');

        expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
        expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeFalsy();
      });

      it('should forcibly allow child animations', () {
        _.compile('<div ng-animate-children="always"><div></div></div>');
        optimizer.track(new NoOpAnimation(), _.rootElement);

        expect(optimizer.shouldAnimate(_.rootElement)).toBeTruthy();
        expect(optimizer.shouldAnimate(_.rootElement.children[0])).toBeTruthy();
      });
    });
  });
}
