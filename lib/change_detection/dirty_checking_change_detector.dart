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
 *   - No GC pressure. Since change detection runs often it should perform no memory allocations.
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
 * the [DirtyCheckingRecord] and [ChangeRecord] are two different interfaces for the same
 * underlying object this makes reporting efficient since no additional memory allocation needs to
 * be allocated.
 */
class DirtyCheckingChangeDetectorGroup<H> implements ChangeDetector<H> {
  /**
   * A group must have at least one record so that it can act as a placeholder. This
   * record has minimal cost and never detects change. Once actual records get
   * added the marker record gets removed, but it gets reinserted if all other
   * records are removed.
   */
  final _DirtyCheckingRecord marker = new _DirtyCheckingRecord.marker();

  /**
   * All records for group are kept together and are denoted by head/tail.
   */
  _DirtyCheckingRecord _recordHead, _recordTail;

  /** Parent group or null if root */
  DirtyCheckingChangeDetectorGroup _parentGroup, _groupHead, _groupTail, _groupPrevious, _groupNext;

  DirtyCheckingChangeDetectorGroup(this._parentGroup) {
    // we need to insert the marker record at the begining.
    if (_parentGroup == null) {
      _recordHead = _recordTail = marker;
    } else {
      DirtyCheckingChangeDetectorGroup groupTail = _parentGroup._groupTail;
      _recordTail = (groupTail == null ? _parentGroup : groupTail)._recordTail;
      _recordHead = _recordTail = _recordAdd(marker);
    }
  }

  WatchRecord<H> watch(Object object, String field, H handler) {
    return _recordAdd(new _DirtyCheckingRecord(this, object, field, handler));
  }


  ChangeDetector<H> newGroup() {
    var child = new DirtyCheckingChangeDetectorGroup(this);
    if (_groupHead == null) {
      _groupHead = _groupTail = child;
    } else {
      child._groupPrevious = _groupTail;
      _groupTail._groupNext = child;
      _groupTail = child;
    }
    return child;
  }
  /**
   * Bulk remove all records.
   */
  void remove() {
    _DirtyCheckingRecord previousRecord = _recordHead._previousWatch;
    _DirtyCheckingRecord nextRecord = (_groupTail == null ? this : _groupTail)._recordTail._nextWatch;

    if (previousRecord != null) previousRecord._nextWatch = nextRecord;
    if (nextRecord != null) nextRecord._previousWatch = previousRecord;

    var prevGroup = _groupPrevious;
    var nextGroup = _groupNext;

    if (prevGroup == null) _parentGroup._groupHead = nextGroup; else prevGroup._groupNext = nextGroup;
    if (nextGroup == null) _parentGroup._groupTail = prevGroup; else nextGroup._groupPrevious = prevGroup;
  }

  _recordAdd(_DirtyCheckingRecord record) {
    _DirtyCheckingRecord previous = _recordTail;
    _DirtyCheckingRecord next = previous == null ? null : previous._nextWatch;

    record._nextWatch = next;
    record._previousWatch = previous;

    if (previous != null) previous._nextWatch = record;
    if (next != null) next._previousWatch = record;

    _recordTail = record;

    if (previous == marker) _recordRemove(marker);

    return record;
  }

  _recordRemove(_DirtyCheckingRecord record) {
    _DirtyCheckingRecord previous = record._previousWatch;
    _DirtyCheckingRecord next = record._nextWatch;

    if (record == _recordHead && record == _recordTail) {
      // we are the last one, must leave marker behind.
      _recordHead = _recordTail = marker;
      marker._nextWatch = next;
      marker._previousWatch = previous;
      if (previous != null) previous._nextWatch = marker;
      if (next != null) next._previousWatch = marker;
    } else {
      if (record == _recordTail) _recordTail = previous;
      if (record == _recordHead) _recordHead = next;
      if (previous != null) previous._nextWatch = next;
      if (next != null) next._previousWatch = previous;
    }
  }
}

class DirtyCheckingChangeDetector<H> extends DirtyCheckingChangeDetectorGroup<H> implements ChangeDetector<H> {
  DirtyCheckingChangeDetector(): super(null);

  _DirtyCheckingRecord<H> collectChanges() {
    _DirtyCheckingRecord changeHead = null;
    _DirtyCheckingRecord changeTail = null;
    _DirtyCheckingRecord current = _recordHead; // current index

    while(current != null) {
      if (current.check() != null) {
        if (changeHead == null) {
          changeHead = changeTail = current;
        } else {
          changeTail = changeTail.nextChange = current;
        }
      }
      current = current._nextWatch;
    };
    if (changeTail != null) changeTail.nextChange = null;
    return changeHead;
  }

  remove() {
    throw new StateError('Root ChangeDetector can not be removed');
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
class _DirtyCheckingRecord<H> implements ChangeRecord<H>, WatchRecord<H> {
  static const int _MODE_MARKER_ = 0;
  static const int _MODE_IDENTITY_ = 1;
  static const int _MODE_OBJECT_ = 2;
  static const int _MODE_MAP_ = 3;
  static const int _MODE_LIST_CHANGE_ = 4;
  static const int _MODE_MAP_CHANGE_ = 5;

  final DirtyCheckingChangeDetectorGroup group;
  final String field;
  final Symbol _symbol;
  final H handler;

  int _mode;

  dynamic previousValue;
  dynamic currentValue;
  _DirtyCheckingRecord<H> _nextWatch;
  _DirtyCheckingRecord<H> _previousWatch;
  ChangeRecord<H> nextChange;
  dynamic _object;
  InstanceMirror _instanceMirror;

  _DirtyCheckingRecord(this.group, obj, fieldName, this.handler):
    field = fieldName,
    _symbol = new Symbol(fieldName)
  {
    this.object = obj;
  }

  _DirtyCheckingRecord.marker():
      group = null, field = null, _symbol = null, handler = null, _mode = _MODE_MARKER_;

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
      case _MODE_MARKER_  : return null;
      case _MODE_OBJECT_  : currentValue = _instanceMirror.getField(_symbol).reflectee; break;
      case _MODE_MAP_     : currentValue = object[field];                               break;
      case _MODE_IDENTITY_: currentValue = object;                                      break;
      defualt: assert('unknown mode');
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
    group._recordRemove(this);
  }
}
