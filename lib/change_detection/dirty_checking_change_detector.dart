library dirty_checking_change_detector;

import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';

/**
 * [DirtyCheckingChangeDetector] determines which object properties have change by comparing them
 * to the previous value.
 *
 * GOALS:
 *   - Plugable implementation, replaceable with other technologies, such as Object.observe().
 *   - SPEED this needs to be as fast as possible.
 *   - No GC pressure. Since change detection runs often it should not generate any garbage.
 *   - The changes need to be delivered in a single data-structure at once. There are two reasons
 *     for this. (1) It should be easy to measure the cost of change detection vs processing.
 *     (2) The feature may move to VM for performance reason. The VM should be free to implement
 *     it in any way. The only thing we need to know is a list of changes.
 *
 *
 * [DirtyCheckingRecord]
 *
 * Each property to be watched is recorded as a [DirtyCheckingRecord] and kept in a linked
 * list. Linked list are faster the Arrays for iteration. They also allow removal of large
 * blocks of watches in efficient manner.
 *
 * [ChangeRecord]
 *
 * When the results are delivered they are a linked list of [ChangeRecord]s. For efficiency reasons
 * the [DirtyCheckingRecord] and [ChangeRecord] are two different interfaces for the same underlying object
 * this makes reporting efficient since no additional memory allocation needs to happen.
 * (The same object has next_Record as well as nextChangeRecord.)
 */
class DirtyCheckingChangeDetector<H> implements ChangeDetector<H> {
  DirtyCheckingRecord head;
  DirtyCheckingRecord tail;

  DirtyCheckingChangeDetector() {
    /** The head/tail start with a bogus DirtyCheckingRecord which serves as NullValueObject */
    head = tail = new DirtyCheckingRecord.head();
  }

  WatchRecord<H> watch(Object object, String field, H handler, {WatchRecord<H> after}) {
    // TODO(misko): implement proper insertion
    var watch = new DirtyCheckingRecord(object, field, handler);
    watch._previousWatch = tail;
    return tail = tail._nextWatch = watch;
  }

  DirtyCheckingRecord<H> collectChanges() {
    DirtyCheckingRecord changeTail = head;
    DirtyCheckingRecord current = head; // current index

    while( (current = current._nextWatch) != null) {
      if (current.check() != null) {
        changeTail = changeTail.nextChange = current;
      }
    };

    changeTail.nextChange = null;

    return head.nextChange;
  }
  void remove(WatchRecord<H> from, [WatchRecord<H> to]) {
    if (to == null) to = from;
    var previous = (from as DirtyCheckingRecord)._previousWatch;
    var next = (to as DirtyCheckingRecord)._nextWatch;
    if (previous != null) previous._nextWatch = next;
    if (next != null) next._previousWatch = previous;
  }
}

/**
 * [DirtyCheckingRecord] represents as single item to check. The heart of the [DirtyCheckingRecord] is a the
 * [check] method which can read the [currentValue] and compare it to the [previousValue].
 *
 * [DirtyCheckingRecord]s form linked list. This makes traversal, adding, and removing efficient. [DirtyCheckingRecord]
 * also has [nextChange] field which creates a single linked list of all of the changes for
 * efficient traversal.
 */
class DirtyCheckingRecord<H> implements ChangeRecord<H>, WatchRecord<H> {
  static const int _MODE_IDENTITY_ = 0;
  static const int _MODE_OBJECT_ = 1;
  static const int _MODE_MAP_ = 2;
  static const int _MODE_LIST_CHANGE_ = 3;
  static const int _MODE_MAP_CHANGE_ = 4;

  final String field;
  final Symbol _symbol;

  int _mode;

  H handler;
  dynamic previousValue;
  dynamic currentValue;
  DirtyCheckingRecord<H> _nextWatch;
  DirtyCheckingRecord<H> _previousWatch;
  ChangeRecord<H> nextChange;
  dynamic _object;
  InstanceMirror _instanceMirror;

  DirtyCheckingRecord(obj, fieldName, this.handler):
    field = fieldName,
    _symbol = new Symbol(fieldName)
  {
    this.object = obj;
  }

  DirtyCheckingRecord.head(): field = null, _symbol = null, handler = null;

  get object => _object;

  /**
   * Setting an [object] will cause the setter to introspect it and place [DirtyCheckingRecord] into different
   * access modes. If Object it sets up reflection. If [Map] then it sets up map accessor.
   */
  set object(obj) {
    this._object = obj;
    if (obj == null) {
      _mode = _MODE_IDENTITY_;
    } else if (obj is Map) {
      _mode = _MODE_MAP_;
    } else {
      _instanceMirror = reflect(obj);
      _mode = _MODE_OBJECT_;
    }
  }

  ChangeRecord<H> check() {
    var lastValue = this.currentValue;
    var currentValue;

    //TODO(misko): check the performance of this.
    switch(_mode) {
      case _MODE_OBJECT_  : currentValue = _instanceMirror.getField(_symbol).reflectee; break;
      case _MODE_MAP_     : currentValue = object[field];                               break;
      case _MODE_IDENTITY_: currentValue = object;                                      break;
      defualt: throw new StateError('unknown mode');
    }

    if (!identical(lastValue, currentValue)) {
      if (lastValue is String && currentValue is String && lastValue == currentValue) {
        // this is false change in strings we need to recover, and pretend it is the same
        this.currentValue = currentValue; // we save the value so that next time identity will pass
      } else {
        this.previousValue = lastValue;
        this.currentValue = currentValue;
        return this;
      }
    }
    return null;
  }

  remove() {
    throw 'implement removal';
  }
}
