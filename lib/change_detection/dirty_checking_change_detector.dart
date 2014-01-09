library dirty_checking_change_detector;

import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';

/**
 * [DirtyCheckingChangeDetector] determines which object properties have change by comparing them
 * to the their previous value.
 *
 * GOALS:
 *   - Plugable implementation, replaceable with other technologies, such as Object.observe().
 *   - SPEED this needs to be as fast as possible.
 *   - No GC pressure. Since change detection runs often it should perform no memory allocations.
 *   - The changes need to be delivered in a single data-structure at once. There are two reasons
 *     for this. (1) It should be easy to measure the cost of change detection vs processing.
 *     (2) The feature may move to VM for performance reason. The VM should be free to implement
 *     it in any way. The only requirement is that the list of changes need to be deliver.
 *
 *
 * [_DirtyCheckingRecord]
 *
 * Each property to be watched is recorded as a [_DirtyCheckingRecord] and kept in a linked
 * list. Linked list are faster than Arrays for iteration. They also allow removal of large
 * blocks of watches in efficient manner.
 *
 * [ChangeRecord]
 *
 * When the results are delivered they are a linked list of [ChangeRecord]s. For efficiency reasons
 * the [_DirtyCheckingRecord] and [ChangeRecord] are two different interfaces for the same
 * underlying object this makes reporting efficient since no additional memory allocation needs to
 * be allocated.
 */
class DirtyCheckingChangeDetectorGroup<H> implements ChangeDetectorGroup<H> {
  /**
   * A group must have at least one record so that it can act as a placeholder. This
   * record has minimal cost and never detects change. Once actual records get
   * added the marker record gets removed, but it gets reinserted if all other
   * records are removed.
   */
  final _DirtyCheckingRecord _marker = new _DirtyCheckingRecord.marker();

  /**
   * All records for group are kept together and are denoted by head/tail.
   */
  _DirtyCheckingRecord _recordHead, _recordTail;

  /**
   * ChangeDetectorGroup is organized hierarchically, a root group can have child groups and so on.
   * We keep track of parent, children and next, previous here.
   */
  DirtyCheckingChangeDetectorGroup _parent, _childHead, _childTail, _prev, _next;

  DirtyCheckingChangeDetectorGroup(this._parent) {
    // we need to insert the marker record at the beginning.
    if (_parent == null) {
      _recordHead = _recordTail = _marker;
    } else {
      // we need to find the tail of previous record
      // If we are first then it is the tail of the parent group
      // otherwise it is the tail of the previous group
      DirtyCheckingChangeDetectorGroup tail = _parent._childTail;
      _recordTail = (tail == null ? _parent : tail)._recordTail;
      _recordHead = _recordTail = _recordAdd(_marker);
    }
  }

  /**
   * Returns the number of watches in this group (including child groups).
   */
  get count {
    int count = 0;
    _DirtyCheckingRecord cursor = _recordHead == _marker ? _recordHead._nextWatch : _recordHead;
    while (cursor != null) {
      count++;
      cursor = cursor._nextWatch;
    }
    return count;
  }

  WatchRecord<H> watch(Object object, String field, H handler) {
    return _recordAdd(new _DirtyCheckingRecord(this, object, field, handler));
  }


  /**
   * Create a child [ChangeDetector] group.
   */
  DirtyCheckingChangeDetectorGroup<H> newGroup() {
    var child = new DirtyCheckingChangeDetectorGroup(this);
    if (_childHead == null) {
      _childHead = _childTail = child;
    } else {
      child._prev = _childTail;
      _childTail._next = child;
      _childTail = child;
    }
    return child;
  }

  /**
   * Bulk remove all records.
   */
  void remove() {
    _DirtyCheckingRecord previousRecord = _recordHead._prevWatch;
    _DirtyCheckingRecord nextRecord = (_childTail == null ? this : _childTail)._recordTail._nextWatch;

    if (previousRecord != null) previousRecord._nextWatch = nextRecord;
    if (nextRecord != null) nextRecord._prevWatch = previousRecord;

    var prevGroup = _prev;
    var nextGroup = _next;

    if (prevGroup == null) _parent._childHead = nextGroup; else prevGroup._next = nextGroup;
    if (nextGroup == null) _parent._childTail = prevGroup; else nextGroup._prev = prevGroup;
  }

  _recordAdd(_DirtyCheckingRecord record) {
    _DirtyCheckingRecord previous = _recordTail;
    _DirtyCheckingRecord next = previous == null ? null : previous._nextWatch;

    record._nextWatch = next;
    record._prevWatch = previous;

    if (previous != null) previous._nextWatch = record;
    if (next != null) next._prevWatch = record;

    _recordTail = record;

    if (previous == _marker) _recordRemove(_marker);

    return record;
  }

  _recordRemove(_DirtyCheckingRecord record) {
    _DirtyCheckingRecord previous = record._prevWatch;
    _DirtyCheckingRecord next = record._nextWatch;

    if (record == _recordHead && record == _recordTail) {
      // we are the last one, must leave marker behind.
      _recordHead = _recordTail = _marker;
      _marker._nextWatch = next;
      _marker._prevWatch = previous;
      if (previous != null) previous._nextWatch = _marker;
      if (next != null) next._prevWatch = _marker;
    } else {
      if (record == _recordTail) _recordTail = previous;
      if (record == _recordHead) _recordHead = next;
      if (previous != null) previous._nextWatch = next;
      if (next != null) next._prevWatch = previous;
    }
  }

  toString() {
    var lines = [];
    if (_parent == null) {
      var allRecords = [];
      _DirtyCheckingRecord record = _recordHead;
      while (record != null) {
        allRecords.add(record.toString());
        record = record._nextWatch;
      }
      lines.add('FIELDS: ${allRecords.join(', ')}');
    }

    var records = [];
    _DirtyCheckingRecord record = _recordHead;
    while (record != _recordTail) {
      records.add(record.toString());
      record = record._nextWatch;
    }
    records.add(record.toString());

    lines.add('DirtyCheckingChangeDetectorGroup(fields: ${records.join(', ')})');
    var childGroup = _childHead;
    while (childGroup != null) {
      lines.add('  ' + childGroup.toString().split('\n').join('\n  '));
      childGroup = childGroup._next;
    }
    return lines.join('\n');
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
  static const List<String> _MODE_NAMES =
      const ['MARKER', 'IDENT', 'OBJECT', 'MAP', 'LIST_CHANGE', 'MAP_CHANGE'];
  static const int _MODE_MARKER_ = 0;
  static const int _MODE_IDENTITY_ = 1;
  static const int _MODE_FIELD_ = 2;
  static const int _MODE_MAP_FIELD_ = 3;
  static const int _MODE_ITERABLE_ = 4;
  static const int _MODE_MAP_ = 5;

  final DirtyCheckingChangeDetectorGroup _group;
  final String field;
  final Symbol _symbol;
  final H handler;

  int _mode;

  dynamic previousValue;
  dynamic currentValue;
  _DirtyCheckingRecord<H> _nextWatch;
  _DirtyCheckingRecord<H> _prevWatch;
  ChangeRecord<H> nextChange;
  dynamic _object;
  InstanceMirror _instanceMirror;

  _DirtyCheckingRecord(this._group, obj, fieldName, this.handler):
    field = fieldName,
    _symbol = fieldName == null ? null : new Symbol(fieldName)
  {
    this.object = obj;
  }

  _DirtyCheckingRecord.marker():
      _group = null, field = null, _symbol = null, handler = null, _mode = _MODE_MARKER_;

  get object => _object;

  /**
   * Setting an [object] will cause the setter to introspect it and place [DirtyCheckingRecord] into different
   * access modes. If Object it sets up reflection. If [Map] then it sets up map accessor.
   */
  set object(obj) {
    this._object = obj;
    if (obj == null) {
      _mode = _MODE_IDENTITY_;
    } else if (field == null) {
      _instanceMirror = null;
      if (obj is Map) {
        _mode =  _MODE_MAP_;
      } else if (obj is Iterable) {
        _mode =  _MODE_ITERABLE_;
        currentValue = new _CollectionChangeRecord();
      } else {
        throw new StateError('Non collections must have fields.');
      }
    } else {
      if (obj is Map) {
        _mode =  _MODE_MAP_FIELD_;
        _instanceMirror = null;
      } else {
        _mode = _MODE_FIELD_;
        _instanceMirror = reflect(obj);
      }
    }
  }

  ChangeRecord<H> check() {
    var currentValue;
    int mode = _mode;

    if      (_MODE_MARKER_    == mode) return null;
    else if (_MODE_FIELD_     == mode) currentValue = _instanceMirror.getField(_symbol).reflectee;
    else if (_MODE_MAP_FIELD_ == mode) currentValue = object[field];
    else if (_MODE_IDENTITY_  == mode) currentValue = object;
    else if (_MODE_MAP_       == mode) return mapCheck(object) ? this : null;
    else if (_MODE_ITERABLE_  == mode) return iterableCheck(object) ? this : null;
    else assert('unknown mode' == null);

    var lastValue = this.currentValue;
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

  mapCheck(Map map) {
    assert('implement' == null);
  }


  /**
   * Check the [Iterable] [collection] for changes.
   */
  iterableCheck(Iterable collection) {
    _CollectionChangeRecord cRecord = currentValue as _CollectionChangeRecord;
    cRecord._reset();
    _ItemRecord record = cRecord._collectionHead;
    _ItemRecord prevRecord = null;
    int index = 0;
    if (collection is List) {
      for(var i = 0, ii = collection.length; i < ii; i++) {
        record = _checkItem(cRecord, prevRecord, record, collection[i], i);
        prevRecord = record;
        record = record._nextCollectionItem;
      }
    } else {
      for(var item in collection) {
        record = _checkItem(cRecord, prevRecord, record, item, index++);
        prevRecord = record;
        record = record._nextCollectionItem;
      }
    }
    cRecord._truncate(record);
    return cRecord.isDirty;
  }

  _ItemRecord _checkItem(_CollectionChangeRecord cRecord, _ItemRecord prevRecord, _ItemRecord record, dynamic item, int index) {
    if (record == null) {
      record = cRecord._addition(prevRecord, item, index);
    } else if (!identical(item, record.item)) {
      if (item is String && record.item is String && record == item) {
        // this is false change in strings we need to recover, and pretend it is the same
        record.item = item; // we save the value so that next time identity will pass
      } else {
        record = cRecord._mismatch(record, item, index);
      }
    }
    return record;
  }

  remove() {
    _group._recordRemove(this);
  }

  toString() {
    return '${_MODE_NAMES[_mode]}[$field]';
  }
}

final Object _INITIAL_ = new Object();

class _CollectionChangeRecord<K, V> implements CollectionChangeRecord<K, V> {
  /** Used to keep track of items during moves. */
  Map<Object, _ItemRecord> _items = new Map<Object, _ItemRecord>();

  /** Used to keep track of removed items. */
  Map<Object, _ItemRecord> _removedItems = new Map<Object, _ItemRecord>();

  _ItemRecord<K, V> _collectionHead, _collectionTail;
  _ItemRecord<K, V> _additionsHead, _additionsTail;
  _ItemRecord<K, V> _movesHead, _movesTail;
  _ItemRecord<K, V> _removalsHead, _removalsTail;

  CollectionChangeItem<K, V> get collectionHead => _collectionHead;
  CollectionChangeItem<K, V> get additionsHead => _additionsHead;
  CollectionChangeItem<K, V> get movesHead => _movesHead;
  CollectionChangeItem<K, V> get removalsHead => _removalsHead;

  /**
   * Reset the state of the change objects to show no changes. This means
   * Set previousKey to currentKey, and clear all of the queues (additions, moves, removals).
   */
  _reset() {
    _ItemRecord record;

    record = _additionsHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextAddedItem;
    }

    record = _movesHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextMovedItem;
    }

    record = _removalsHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextRemovedItem;
    }

    assert(() {
      _ItemRecord record;

      record = _additionsHead;
      while(record != null) {
        var prevRecord = record;
        record = record._nextAddedItem;
        prevRecord._nextAddedItem = null;
      }

      record = _movesHead;
      while(record != null) {
        var prevRecord = record;
        record = record._nextMovedItem;
        prevRecord._nextMovedItem = null;
      }

      record = _removalsHead;
      while(record != null) {
        var prevRecord = record;
        record = record._nextRemovedItem;
        prevRecord._nextRemovedItem = null;
      }

      return true;
    });
    _additionsHead = _additionsTail = null;
    _movesHead     = _movesTail     = null;
    _removalsHead = _removalsTail = null;
  }

  /**
   * A [_CollectionChangeRecord] is considered dirty if it has additions, moves or removals.
   */
  get isDirty => _additionsHead != null || _movesHead != null || _removalsHead != null;

  _addition(_ItemRecord prevRecord, dynamic item, int index) {
    _ItemRecord record = _removedItems.remove(item);
    if (record == null) {
      record = new _ItemRecord(item, index);
      _additionsAdd(record);
    } else {
      _removalsRemove(record);
      record.currentKey = index;
      _movesAdd(record);
    }
    _collectionInsertAfter(record, prevRecord);
    _items[item] = record; // TODO(misko): deal with duplicates

    return record;
  }

  _mismatch(_ItemRecord mismatchRecord, dynamic item, int index) {
    _ItemRecord prevRecord = mismatchRecord._prevCollectionItem;
    _evict(mismatchRecord);
    _ItemRecord existingRecord = _items[item];
    if (existingRecord == null) {
      // Never seen it, this is a new item
      return _addition(prevRecord, item, index);
    } else {
      // We have seen this before, we need to move it.
      _moveRecord(existingRecord, prevRecord);
      existingRecord.currentKey = index;
    }
    return existingRecord;
  }

  _moveRecord(_ItemRecord record, _ItemRecord prev) {
    _collectionRemove(record);
    _ItemRecord next = prev == null ? _collectionHead : prev._nextCollectionItem;
    record._nextCollectionItem = next;
    record._prevCollectionItem = prev;
    if (prev == null) _collectionHead = record; else prev._nextCollectionItem = record;
    if (next == null) _collectionTail = record; else next._prevCollectionItem = record;
    _movesAdd(record);
  }

  _evict(_ItemRecord record) {
    record.currentKey = null;
    _collectionRemove(record);
    _removalsAdd(record);
    record.currentKey = null;
    _items.remove(record.item);
    _removedItems[record.item] = record;
  }

  _truncate(_ItemRecord record) {
    if (record != null) {
      // terminate the list
      var prev = record._prevCollectionItem;
      if (prev == null) _collectionHead = record; else prev._nextCollectionItem = null;
      _collectionTail = prev;
    }

    _removedItems.clear();

    // Anything after that needs to be removed;
    while(record != null) {
      record.currentKey = null;
      _ItemRecord next = record._nextCollectionItem;
      assert((record._prevCollectionItem = null) == null);
      assert((record._nextCollectionItem = null) == null);
      _removalsAdd(record);
      assert(_items.containsKey(record.item));
      _items.remove(record.item);
      record = next;
    }
  }

  _ItemRecord _collectionInsertAfter(_ItemRecord record, _ItemRecord prev) {
    assert(record._nextCollectionItem == null);
    assert(record._prevCollectionItem == null);

    _ItemRecord next = prev == null ? null : prev._nextCollectionItem;
    record._nextCollectionItem = next;
    record._prevCollectionItem = prev;
    if (next == null) _collectionTail = record; else next._prevCollectionItem = record;
    if (prev == null) _collectionHead = record; else prev._nextCollectionItem = record;
  }

  _additionsAdd(_ItemRecord record) {
    if (_additionsTail == null) {
      assert(_additionsHead == null);
      _additionsTail = _additionsHead = record;
    } else {
      assert(_additionsTail._nextAddedItem == null);
      assert(record._nextAddedItem == null);
      _additionsTail = _additionsTail._nextAddedItem = record;
    }
  }

  _movesAdd(_ItemRecord record) {
    if (_movesTail == null) {
      assert(_movesHead == null);
      _movesTail = _movesHead = record;
    } else {
      assert(_movesTail._nextMovedItem == null);
      assert(record._nextMovedItem == null);
      _movesTail = _movesTail._nextMovedItem = record;
    }
  }

  _removalsAdd(_ItemRecord record) {
    if (_removalsTail == null) {
      assert(_removalsHead == null);
      _removalsTail = _removalsHead = record;
    } else {
      assert(_removalsTail._nextRemovedItem == null);
      assert(record._nextRemovedItem == null);
      record._prevRemovedItem = _removalsTail;
      _removalsTail = _removalsTail._nextRemovedItem = record;
    }
    _items.remove(record.item);
  }

  _collectionRemove(_ItemRecord record) {
    var prev = record._prevCollectionItem;
    var next = record._nextCollectionItem;

    assert((record._prevCollectionItem = null) == null);
    assert((record._nextCollectionItem = null) == null);

    if (prev == null) _collectionHead = next; else prev._nextCollectionItem = next;
    if (next == null) _collectionTail = prev; else next._prevCollectionItem = prev;
  }

  _removalsRemove(_ItemRecord record) {
    var prev = record._prevRemovedItem;
    var next = record._nextRemovedItem;

    assert((record._prevRemovedItem = null) == null);
    assert((record._nextRemovedItem = null) == null);

    if (prev == null) _removalsHead = next; else prev._nextRemovedItem = next;
    if (next == null) _removalsTail = prev; else next._prevRemovedItem = prev;
  }

  toString() {
    _ItemRecord record;

    var list = [];
    record = _collectionHead;
    while(record != null) {list.add(record); record = record._nextCollectionItem;};

    var additions = [];
    record = _additionsHead;
    while(record != null) {additions.add(record); record = record._nextAddedItem;};

    var moves = [];
    record = _movesHead;
    while(record != null) {moves.add(record); record = record._nextMovedItem;};

    var removals = [];
    record = _removalsHead;
    while(record != null) {removals.add(record); record = record._nextRemovedItem;};

    var lines = [];
    lines.add('collection: ${list.join(", ")}');
    lines.add('additions: ${additions.join(", ")}');
    lines.add('moves: ${moves.join(", ")}');
    lines.add('removals: ${removals.join(", ")}');
    return lines.join('\n');
  }
}

class _ItemRecord<K, V> implements CollectionItem<K, V>, AddedItem<K, V>, MovedItem<K, V>, RemovedItem<K, V> {
  K previousKey = null;
  K currentKey = null;
  V item = _INITIAL_;

  _ItemRecord<K, V> _prevCollectionItem, _nextCollectionItem;
  _ItemRecord<K, V> _prevRemovedItem, _nextRemovedItem;
  _ItemRecord<K, V> _nextAddedItem, _nextMovedItem;

  CollectionItem<K, V> get nextCollectionItem => _nextCollectionItem;
  RemovedItem<K, V> get nextRemovedItem => _nextRemovedItem;
  AddedItem<K, V> get nextAddedItem => _nextAddedItem;
  MovedItem<K, V> get nextMovedItem => _nextMovedItem;

  _ItemRecord(this.item, this.currentKey);

  toString() => previousKey == currentKey
      ? '$item' : '$item[$previousKey -> $currentKey]';
}
