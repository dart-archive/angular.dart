part of angular.touch;

/**
 * Base class for Swipe Gesture. Decides whether a swipe is performed
 * and gives the x, y direction of the swipe.
 */
abstract class _SwipeGesture {
  static const int NO_SWIPE = -1;
  static const int DOWN = 0;
  static const int UP = 1;
  static const int LEFT = 2;
  static const int RIGHT = 3;
  
  // Less than 100 pixels of move in each direction does not count.
  static const int _POS_TOLERANCE = 100;
  // If swipe lasts more than 1s, it is not a swipe.
  static const int _TIME_TOLERANCE = 1000;

  // Function to be called on swipe.
  Function fn;

  // Subclasses decide on swipe direction whether to call fn or not.
  bool get shouldFire;

  int _startX;
  int _startY;
  int _startTime;
  int xDirection;
  int yDirection;
  
  _SwipeGesture(dom.Element target) {
    target.onTouchStart.listen(_handleTouchStartEvent);
    target.onTouchEnd.listen(_handleTouchEndEvent);
  }
  
  void handleTouchStart(int x, int y, int timestamp) {
    // Reset values every time swipe starts
    xDirection = NO_SWIPE;
    yDirection = NO_SWIPE;
    _startX = x;
    _startY = y;
    _startTime = timestamp;
  }

  void handleTouchEnd(int x, int y, int timestamp) {
    int touchDuration = timestamp - _startTime;
    if (touchDuration > _TIME_TOLERANCE) {
      return;
    }
    if (y > _startY + _POS_TOLERANCE) {
      yDirection = DOWN;
    } else if (y < _startY - _POS_TOLERANCE) {
      yDirection = UP;
    }
    if (x > _startX + _POS_TOLERANCE) {
      xDirection = RIGHT;
    } else if (x < _startX - _POS_TOLERANCE) {
      xDirection = LEFT;
    }
    if (fn != null && shouldFire) {
      fn();
    }
  }
  
  void _handleTouchStartEvent(dom.TouchEvent ev) {
    // Guaranteed to have at least one touch in changedTouches.
    dom.Touch t = ev.changedTouches.first;
    handleTouchStart(t.client.x, t.client.y, ev.timeStamp);
  }
  
  void _handleTouchEndEvent(dom.TouchEvent ev) {
    // Guaranteed to have at least one touch in changedTouches.
    dom.Touch t = ev.changedTouches.first;
    handleTouchEnd(t.client.x, t.client.y, ev.timeStamp);
  }
}

/**
 * The `ng-swipe-right` directive allows execution of callbacks when user
 * swipes her finger to the right.
 * Also see [NgSwipeLeft].
 */
@Decorator(
    selector: '[ng-swipe-right]',
    map: const {'ng-swipe-right':'&fn'})
class NgSwipeRight extends _SwipeGesture {
  NgSwipeRight(dom.Element target): super(target);
  
  bool get shouldFire => xDirection == _SwipeGesture.RIGHT &&
                         yDirection == _SwipeGesture.NO_SWIPE;
}

/**
 * The `ng-swipe-left` directive allows execution of callbacks when user
 * swipes his finger to the left.
 * Also see [NgSwipeRight].
 */
@Decorator(
    selector: '[ng-swipe-left]',
    map: const {'ng-swipe-left':'&fn'})
class NgSwipeLeft extends _SwipeGesture {
  NgSwipeLeft(dom.Element target): super(target);
  
  bool get shouldFire => xDirection == _SwipeGesture.LEFT &&
                         yDirection == _SwipeGesture.NO_SWIPE;
}
