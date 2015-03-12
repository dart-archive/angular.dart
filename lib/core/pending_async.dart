library angular.core.pending_async;

import 'dart:async';
import 'package:di/annotations.dart';

typedef void WhenStableCallback();

/**
 * Tracks pending operations and notifies when they are all complete.
 */
@Injectable()
class PendingAsync {
  /// a count of the number of pending async operations.
  int _numPending = 0;
  List<WhenStableCallback> _callbacks;

  /**
   * A count of the number of tracked pending async operations.
   */
  int get numPending => _numPending;

  /**
   * Register a callback to be called synchronously when the number of tracked
   * pending async operations reaches a count of zero from a non-zero count.
   */
  void whenStable(WhenStableCallback cb) {
    if (_numPending == 0) {
      cb();
      return;
    }
    if (_callbacks == null) {
      _callbacks = <WhenStableCallback>[cb];
    } else {
      _callbacks.add(cb);
    }
  }

  /**
   * Increase the counter of the number of tracked pending operations.  Returns
   * the new count of the number of tracked pending operations.
   */
  int increaseCount([int delta = 1]) {
    if (delta == 0) {
      return _numPending;
    }
    _numPending += delta;
    if (_numPending < 0) {
      throw "Attempting to reduce pending async count below zero.";
    } else if (_numPending == 0) {
      _runAllCallbacks();
    }
    return _numPending;
  }

  /**
   * Decrease the counter of the number of tracked pending operations.  Returns
   * the new count of the number of tracked pending operations.
   */
  int decreaseCount([int delta = 1]) => increaseCount(-delta);

  void _runAllCallbacks() {
    while (_callbacks != null) {
      var callbacks = _callbacks;
      _callbacks = null;
      callbacks.forEach((fn) { fn(); });
    }
  }
}
