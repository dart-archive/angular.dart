library ng_swipe_spec;

import '../_specs.dart';

/**
 * Unfortunately, it is not possible to test swipe using events since
 * TouchEvent cannot be constructed using fake dom.Touch elements.
 * See: dartbug.com/8314
 * TODO(8314): Once this is fixed, should update the tests.
 */
void main() {
  describe('ng-swipe-right', () {
    NgSwipeRight swipe = new NgSwipeRight(new DivElement());

    it('should not fire when distance is not enough', () {
      swipe.handleTouchStart(10, 10, 0);
      swipe.handleTouchEnd(15, 15, 1);
      expect(swipe.shouldFire).toBeFalse();
    });

    it('should fire on swipe to the right', () {
      swipe.handleTouchStart(10, 10, 0);
      swipe.handleTouchEnd(130, 15, 1);
      expect(swipe.shouldFire).toBeTrue();
    });

    it('should not fire on swipe to the left', () {
      swipe.handleTouchStart(130, 10, 0);
      swipe.handleTouchEnd(10, 15, 1);
      expect(swipe.shouldFire).toBeFalse();
    });

    it('should not fire on slow swipe', () {
      swipe.handleTouchStart(10, 10, 0);
      // 2 seconds later
      swipe.handleTouchEnd(130, 15, 2000);
      expect(swipe.shouldFire).toBeFalse();
    });
  });

  describe('ng-swipe-left', () {
    NgSwipeLeft swipe = new NgSwipeLeft(new DivElement());

    it('should not fire when distance is not enough', () {
      swipe.handleTouchStart(10, 10, 0);
      swipe.handleTouchEnd(15, 15, 1);
      expect(swipe.shouldFire).toBeFalse();
    });

    it('should not fire on swipe to the right', () {
      swipe.handleTouchStart(10, 10, 0);
      swipe.handleTouchEnd(130, 15, 1);
      expect(swipe.shouldFire).toBeFalse();
    });

    it('should fire on swipe to the left', () {
      swipe.handleTouchStart(130, 10, 0);
      swipe.handleTouchEnd(10, 15, 1);
      expect(swipe.shouldFire).toBeTrue();
    });

    it('should not fire on swipe on slow swipe', () {
      swipe.handleTouchStart(130, 10, 0);
      // 2 seconds later
      swipe.handleTouchEnd(10, 15, 2000);
      expect(swipe.shouldFire).toBeFalse();
    });
  });
}
