library dirty_checking_change_detector;

import 'dart:mirrors';
import 'dart:collection';
import 'package:angular/change_detection/change_detection.dart';

typedef FieldGetter(object);

class GetterCache {
  Map<String, FieldGetter> _map;

  GetterCache(this._map);

  FieldGetter call(String name) => _map[name];
}

/**
 * [DirtyCheckingChangeDetector] determines which object properties have changed
 * by comparing them to the their previous value.
 *
 * GOALS:
 *   - Plugable implementation, replaceable with other technologies, such as
 *   Object.observe().
 *   - SPEED this needs to be as fast as possible.
 *   - No GC pressure. Since change detection runs often it should perform no
 *   memory allocations.
 *   - The changes need to be delivered in a single data-structure at once.
 *   There are two reasons for this:
 *     1. It should be easy to measure the cost of change detection vs
 *     processing.
 *     2. The feature may move to VM for performance reason. The VM should be
 *     free to implement it in any way. The only requirement is that the list of
 *     changes need to be delivered.
 *
 * [DirtyCheckingRecord]
 *
 * Each property to be watched is recorded as a [DirtyCheckingRecord] and kept
 * in a linked list. Linked list are faster than Arrays for iteration. They also
 * allow removal of large blocks of watches in an efficient manner.
 *
 * [ChangeRecord]
 *
 * When the results are delivered they are a linked list of [ChangeRecord]s. For
 * efficiency reasons the [DirtyCheckingRecord] and [ChangeRecord] are two
 * different interfaces for the same underlying object this makes reporting
 * efficient since no additional memory allocation is performed.
 */
class DirtyCheckingChangeDetectorGroup<H> implements ChangeDetectorGroup<H> {
  /**
   * A group must have at least one record so that it can act as a placeholder.
   * This record has minimal cost and never detects change. Once actual records
   * get added the marker record gets removed, but it gets reinserted if all
   * other records are removed.
   */
  final DirtyCheckingRecord _marker = new DirtyCheckingRecord.marker();

  final GetterCache _getterCache;

  /**
   * All records for group are kept together and are denoted by head/tail.
   */
  DirtyCheckingRecord _head, _tail;

  /**
   * ChangeDetectorGroup is organized hierarchically, a root group can have
   * child groups and so on. We keep track of parent, children and next,
   * previous here.
   */
  DirtyCheckingChangeDetectorGroup _parent, _childHead, _childTail, _prev, _next;

  DirtyCheckingChangeDetectorGroup(this._parent, this._getterCache) {
    // we need to insert the marker record at the beginning.
    if (_parent == null) {
      _head = _marker;
      _tail = _marker;
    } else {
      // we need to find the tail of previous record
      // If we are first then it is the tail of the parent group
      // otherwise it is the tail of the previous group
      DirtyCheckingChangeDetectorGroup tail = _parent._childTail;
      _tail = (tail == null ? _parent : tail)._tail;
      // _recordAdd uses _tail from above.
      _head = _tail = _recordAdd(_marker);
    }
  }

  /**
   * Returns the number of watches in this group (including child groups).
   */
  get count {
    int count = 0;
    DirtyCheckingRecord cursor = _head == _marker ?
        _head._nextWatch :
        _head;
    while (cursor != null) {
      count++;
      cursor = cursor._nextWatch;
    }
    return count;
  }

  WatchRecord<H> watch(Object object, String field, H handler) {
    var getter = field == null ? null : _getterCache(field);
    return _recordAdd(new DirtyCheckingRecord(this, object, field, getter,
        handler));
  }

  /**
   * Create a child [ChangeDetector] group.
   */
  DirtyCheckingChangeDetectorGroup<H> newGroup() {
    var child = new DirtyCheckingChangeDetectorGroup(this, _getterCache);
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
    DirtyCheckingRecord previousRecord = _head._prevWatch;
    var childTail = _childTail == null ? this : _childTail;
    DirtyCheckingRecord nextRecord = childTail._tail._nextWatch;

    if (previousRecord != null) previousRecord._nextWatch = nextRecord;
    if (nextRecord != null) nextRecord._prevWatch = previousRecord;

    var prevGroup = _prev;
    var nextGroup = _next;

    if (prevGroup == null) {
      _parent._childHead = nextGroup;
    } else {
      prevGroup._next = nextGroup;
    }
    if (nextGroup == null) {
      _parent._childTail = prevGroup;
    } else {
      nextGroup._prev = prevGroup;
    }
  }

  _recordAdd(DirtyCheckingRecord record) {
    DirtyCheckingRecord previous = _tail;
    DirtyCheckingRecord next = previous == null ? null : previous._nextWatch;

    record._nextWatch = next;
    record._prevWatch = previous;

    if (previous != null) previous._nextWatch = record;
    if (next != null) next._prevWatch = record;

    _tail = record;

    if (previous == _marker) _recordRemove(_marker);

    return record;
  }

  _recordRemove(DirtyCheckingRecord record) {
    DirtyCheckingRecord previous = record._prevWatch;
    DirtyCheckingRecord next = record._nextWatch;

    if (record == _head && record == _tail) {
      // we are the last one, must leave marker behind.
      _head = _tail = _marker;
      _marker._nextWatch = next;
      _marker._prevWatch = previous;
      if (previous != null) previous._nextWatch = _marker;
      if (next != null) next._prevWatch = _marker;
    } else {
      if (record == _tail) _tail = previous;
      if (record == _head) _head = next;
      if (previous != null) previous._nextWatch = next;
      if (next != null) next._prevWatch = previous;
    }
  }

  toString() {
    var lines = [];
    if (_parent == null) {
      var allRecords = [];
      DirtyCheckingRecord record = _head;
      while (record != null) {
        allRecords.add(record.toString());
        record = record._nextWatch;
      }
      lines.add('FIELDS: ${allRecords.join(', ')}');
    }

    var records = [];
    DirtyCheckingRecord record = _head;
    while (record != _tail) {
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

class DirtyCheckingChangeDetector<H> extends DirtyCheckingChangeDetectorGroup<H>
    implements ChangeDetector<H> {
  DirtyCheckingChangeDetector(GetterCache getterCache): super(null, getterCache);

  DirtyCheckingRecord<H> collectChanges() {
    DirtyCheckingRecord changeHead = null;
    DirtyCheckingRecord changeTail = null;
    DirtyCheckingRecord current = _head; // current index

    while (current != null) {
      if (current.check() != null) {
        if (changeHead == null) {
          changeHead = changeTail = current;
        } else {
          changeTail = changeTail.nextChange = current;
        }
      }
      current = current._nextWatch;
    }
    if (changeTail != null) changeTail.nextChange = null;
    return changeHead;
  }

  remove() {
    throw new StateError('Root ChangeDetector can not be removed');
  }
}

/**
 * [DirtyCheckingRecord] represents as single item to check. The heart of the
 * [DirtyCheckingRecord] is a the [check] method which can read the
 * [currentValue] and compare it to the [previousValue].
 *
 * [DirtyCheckingRecord]s form linked list. This makes traversal, adding, and
 * removing efficient. [DirtyCheckingRecord] also has a [nextChange] field which
 * creates a single linked list of all of the changes for efficient traversal.
 */
class DirtyCheckingRecord<H> implements ChangeRecord<H>, WatchRecord<H> {
  static const List<String> _MODE_NAMES =
      const ['MARKER', 'IDENT', 'REFLECT', 'GETTER', 'MAP[]', 'ITERABLE', 'MAP'];
  static const int _MODE_MARKER_ = 0;
  static const int _MODE_IDENTITY_ = 1;
  static const int _MODE_REFLECT_ = 2;
  static const int _MODE_GETTER_ = 3;
  static const int _MODE_MAP_FIELD_ = 4;
  static const int _MODE_ITERABLE_ = 5;
  static const int _MODE_MAP_ = 6;

  final DirtyCheckingChangeDetectorGroup _group;
  final String field;
  final Symbol _symbol;
  final FieldGetter _getter;
  final H handler;

  int _mode;

  var previousValue;
  var currentValue;
  DirtyCheckingRecord<H> _nextWatch;
  DirtyCheckingRecord<H> _prevWatch;
  ChangeRecord<H> nextChange;
  var _object;
  InstanceMirror _instanceMirror;

  DirtyCheckingRecord(this._group, object, fieldName, this._getter, this.handler)
      : field = fieldName,
        _symbol = fieldName == null ? null : new Symbol(fieldName)
  {
    this.object = object;
  }

  DirtyCheckingRecord.marker()
      : handler = null,
        field = null,
        _group = null,
        _symbol = null,
        _getter = null,
        _mode = _MODE_MARKER_;

  get object => _object;

  /**
   * Setting an [object] will cause the setter to introspect it and place
   * [DirtyCheckingRecord] into different access modes. If Object it sets up
   * reflection. If [Map] then it sets up map accessor.
   */
  set object(obj) {
    this._object = obj;
    if (obj == null) {
      _mode = _MODE_IDENTITY_;
    } else if (field == null) {
      _instanceMirror = null;
      if (obj is Map) {
        _mode =  _MODE_MAP_;
        assert('implement' == false);
        currentValue = null; //new _MapChangeRecord();
      } else if (obj is Iterable) {
        if (_mode == _MODE_ITERABLE_) return; // Last one was collection as well, don't reset state.
        _mode =  _MODE_ITERABLE_;
        currentValue = new _CollectionChangeRecord();
      } else {
        _mode = _MODE_IDENTITY_;
      }
    } else {
      if (obj is Map) {
        _mode =  _MODE_MAP_FIELD_;
        _instanceMirror = null;
      } else if (_getter != null) {
        _mode = _MODE_GETTER_;
        _instanceMirror = null;
      } else {
        _mode = _MODE_REFLECT_;
        _instanceMirror = reflect(obj);
      }
    }
  }

  ChangeRecord<H> check() {
    assert(_mode != null);
    var current;
    switch (_mode) {
      case _MODE_MARKER_:
        return null;
      case _MODE_REFLECT_:
        current = _instanceMirror.getField(_symbol).reflectee;
        break;
      case _MODE_GETTER_:
        current = _getter(object);
        break;
      case _MODE_MAP_FIELD_:
        current = object[field];
        break;
      case _MODE_IDENTITY_:
        current = object;
        break;
      case _MODE_MAP_:
        return mapCheck(object) ? this : null;
      case _MODE_ITERABLE_:
        return iterableCheck(object) ? this : null;
      default:
        assert(false);
    }

    var last = currentValue;
    if (!identical(last, current)) {
      if (last is String && current is String &&
          last == current) {
        // This is false change in strings we need to recover, and pretend it
        // is the same. We save the value so that next time identity will pass
        currentValue = current;
      } else if (last is num && last.isNaN && current is num && current.isNaN) {
        // we need this for JavaScript since in JS NaN !== NaN.
      } else {
        previousValue = last;
        currentValue = current;
        return this;
      }
    }
    return null;
  }

  mapCheck(Map map) {
    assert('TODO: implement!' == true);
    /*
    _MapChangeRecord mapChangeRecord = currentValue as _MapChangeRecord;
    ItemRecord record = mapChangeRecord._collectionHead;
    mapChangeRecord.truncate(record);
    map.forEach((key, value) {
      if (record == null || !identical(value, record.item)) { }
    });
    return mapChangeRecord.isDirty;
    */
  }


  /**
   * Check the [Iterable] [collection] for changes.
   */
  iterableCheck(Iterable collection) {
    _CollectionChangeRecord collectionChangeRecord =
        currentValue as _CollectionChangeRecord;
    collectionChangeRecord._reset();
    ItemRecord record = collectionChangeRecord._collectionHead;
    bool maybeDirty = false;
    if ((collection is UnmodifiableListView) &&
        identical(collectionChangeRecord._iterable, collection)) {
      // Short circuit and assume that the list has not been modified.
      return false;
    } else if (collection is List) {
      List list = collection;
      for(int index = 0, length = list.length; index < length; index++) {
        var item = list[index];
        if (record == null || !identical(item, record.item)) {
          record = collectionChangeRecord.mismatch(record, item, index);
          maybeDirty = true;
        } else if (maybeDirty) {
          // TODO(misko): can we limit this to duplicates only?
          record = collectionChangeRecord.verifyReinsertion(record, item, index);
        }
        record = record._nextRec;
      }
    } else {
      int index = 0;
      for(var item in collection) {
        if (record == null || !identical(item, record.item)) {
          record = collectionChangeRecord.mismatch(record, item, index);
          maybeDirty = true;
        } else if (maybeDirty) {
          // TODO(misko): can we limit this to duplicates only?
          record = collectionChangeRecord.verifyReinsertion(record, item, index);
        }
        record = record._nextRec;
        index++;
      }
    }
    collectionChangeRecord.truncate(record);
    collectionChangeRecord._iterable = collection;
    return collectionChangeRecord.isDirty;
  }

  remove() {
    _group._recordRemove(this);
  }

  toString() => '${_MODE_NAMES[_mode]}[$field]';
}

final Object _INITIAL_ = new Object();

//class _MapChangeRecord<K, V> implements CollectionChangeRecord<K, V> {
//}

class _CollectionChangeRecord<K, V> implements CollectionChangeRecord<K, V> {
  Iterable _iterable;
  /** Used to keep track of items during moves. */
  DuplicateMap _items = new DuplicateMap();

  /** Used to keep track of removed items. */
  DuplicateMap _removedItems = new DuplicateMap();

  ItemRecord<K, V> _collectionHead, _collectionTail;
  ItemRecord<K, V> _additionsHead, _additionsTail;
  ItemRecord<K, V> _movesHead, _movesTail;
  ItemRecord<K, V> _removalsHead, _removalsTail;

  CollectionChangeItem<K, V> get collectionHead => _collectionHead;
  CollectionChangeItem<K, V> get additionsHead => _additionsHead;
  CollectionChangeItem<K, V> get movesHead => _movesHead;
  CollectionChangeItem<K, V> get removalsHead => _removalsHead;

  Iterable get iterable => _iterable;

  /**
   * Reset the state of the change objects to show no changes. This means set
   * previousKey to currentKey, and clear all of the queues (additions, moves,
   * removals).
   */
  _reset() {
    ItemRecord record;

    record = _additionsHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextAddedRec;
    }
    _additionsHead = _additionsTail = null;

    record = _movesHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextMovedRec;
    }
    _movesHead = _movesTail = null;

    record = _removalsHead;
    while(record != null) {
      record.previousKey = record.currentKey;
      record = record._nextRemovedRec;
    }
    _removalsHead = _removalsTail = null;
  }

  /**
   * A [_CollectionChangeRecord] is considered dirty if it has additions, moves
   * or removals.
   */
  get isDirty => _additionsHead != null || _movesHead != null ||
      _removalsHead != null;

  /**
   * This is the core function which handles differences between collections.
   *
   * - [record] is the record which we saw at this position last time. If `null`
   *   then it is a new item.
   * - [item] is the current item in the collection
   * - [index] is the position of the item in the collection
   */
  mismatch(ItemRecord record, dynamic item, int index) {
    // Guard against bogus String changes
    if (record != null && item is String && record.item is String &&
        record == item) {
      // this is false change in strings we need to recover, and pretend it is
      // the same. We save the value so that next time identity will pass
      return record..item = item;
    }

    // find the previous record os that we know where to insert after.
    ItemRecord prev = record == null ? _collectionTail : record._prevRec;

    // Remove the record from the collection since we know it does not match the item.
    if (record != null) _collection_remove(record);
    // Attempt to see if we have seen the item before.
    record = _items.get(item, index);
    if (record != null) {
      // We have seen this before, we need to move it forward in the collection.
      _collection_moveAfter(record, prev, index);
    } else {
      // Never seen it, check evicted list.
      record = _removedItems.get(item);
      if (record != null) {
        // It is an item which we have earlier evict it, reinsert it back into the list.
        _collection_reinsertAfter(record, prev, index);
      } else {
        // It is a new item add it.
        record = _collection_addAfter(new ItemRecord(item), prev, index);
      }
    }
    return record;
  }

  /**
   * This check is only needed if an array contains duplicates. (Short circuit
   * of nothing dirty)
   *
   * Use case: `[a, a]` => `[b, a, a]`
   *
   * If we did not have this check then the insertion of `b` would:
   *   1) evict first `a`
   *   2) insert `b` at `0` index.
   *   3) leave `a` at index `1` as is. <-- this is wrong!
   *   3) reinsert `a` at index 2. <-- this is wrong!
   *
   * The correct behavior is:
   *   1) evict first `a`
   *   2) insert `b` at `0` index.
   *   3) reinsert `a` at index 1.
   *   3) move `a` at from `1` to `2`.
   *
   *
   * Double check that we have not evicted a duplicate item. We need to check if
   * the item type may have already been removed:
   * The insertion of b will evict the first 'a'. If we don't reinsert it now it
   * will be reinserted at the end. Which will show up as the two 'a's switching
   * position. This is incorrect, since a better way to think of it is as insert
   * of 'b' rather then switch 'a' with 'b' and then add 'a' at the end.
   */
  verifyReinsertion(ItemRecord record, dynamic item, int index) {
    ItemRecord reinsertRecord = _removedItems.get(item);
    if (reinsertRecord != null) {
      record = _collection_reinsertAfter(reinsertRecord, record._prevRec, index);
    } else if (record.currentKey != index) {
      record.currentKey = index;
      _moves_add(record);
    }
    return record;
  }

  /**
   * Get rid of any excess [ItemRecord]s from the previous collection
   *
   * - [record] The first excess [ItemRecord].
   */
  void truncate(ItemRecord record) {
    // Anything after that needs to be removed;
    while(record != null) {
      ItemRecord nextRecord = record._nextRec;
      _removals_add(_collection_unlink(record));
      record = nextRecord;
    }
    _removedItems.clear();
  }

  ItemRecord _collection_reinsertAfter(ItemRecord record, ItemRecord insertPrev, int index) {
    _removedItems.remove(record);
    var prev = record._prevRemovedRec;
    var next = record._nextRemovedRec;

    assert((record._prevRemovedRec = null) == null);
    assert((record._nextRemovedRec = null) == null);

    if (prev == null) {
      _removalsHead = next;
    } else {
      prev._nextRemovedRec = next;
    }
    if (next == null) {
      _removalsTail = prev;
    } else {
      next._prevRemovedRec = prev;
    }

    _collection_insertAfter(record, insertPrev, index);
    _moves_add(record);
    return record;
  }

  ItemRecord _collection_moveAfter(ItemRecord record, ItemRecord prev, int index) {
    _collection_unlink(record);
    _collection_insertAfter(record, prev, index);
    _moves_add(record);
    return record;
  }

  ItemRecord _collection_addAfter(ItemRecord record, ItemRecord prev, int index) {
    _collection_insertAfter(record, prev, index);

    if (_additionsTail == null) {
      assert(_additionsHead == null);
      _additionsTail = _additionsHead = record;
    } else {
      assert(_additionsTail._nextAddedRec == null);
      assert(record._nextAddedRec == null);
      _additionsTail = _additionsTail._nextAddedRec = record;
    }
    return record;
  }

  ItemRecord _collection_insertAfter(ItemRecord record, ItemRecord prev, int index) {
    assert(record != prev);
    assert(record._nextRec == null);
    assert(record._prevRec == null);

    ItemRecord next = prev == null ? _collectionHead : prev._nextRec;
    assert(next != record);
    assert(prev != record);
    record._nextRec = next;
    record._prevRec = prev;
    if (next == null) {
      _collectionTail = record;
    } else {
      next._prevRec = record;
    }
    if (prev == null) {
      _collectionHead = record;
    } else {
      prev._nextRec = record;
    }

    _items.put(record);
    record.currentKey = index;
    return record;
  }

  ItemRecord _collection_remove(ItemRecord record) =>
      _removals_add(_collection_unlink(record));

  ItemRecord _collection_unlink(ItemRecord record) {
    _items.remove(record);

    var prev = record._prevRec;
    var next = record._nextRec;

    assert((record._prevRec = null) == null);
    assert((record._nextRec = null) == null);

    if (prev == null) {
      _collectionHead = next;
    } else {
      prev._nextRec = next;
    }
    if (next == null) {
      _collectionTail = prev;
    } else {
      next._prevRec = prev;
    }

    return record;
  }

  ItemRecord _moves_add(ItemRecord record) {
    if (_movesTail == null) {
      assert(_movesHead == null);
      _movesTail = _movesHead = record;
    } else {
      assert(_movesTail._nextMovedRec == null);
      assert(record._nextMovedRec == null);
      _movesTail = _movesTail._nextMovedRec = record;
    }

    return record;
  }

  ItemRecord _removals_add(ItemRecord record) {
    record.currentKey = null;
    _removedItems.put(record);

    if (_removalsTail == null) {
      assert(_removalsHead == null);
      _removalsTail = _removalsHead = record;
    } else {
      assert(_removalsTail._nextRemovedRec == null);
      assert(record._nextRemovedRec == null);
      record._prevRemovedRec = _removalsTail;
      _removalsTail = _removalsTail._nextRemovedRec = record;
    }
    return record;
  }

  toString() {
    ItemRecord record;

    var list = [];
    record = _collectionHead;
    while(record != null) {
      list.add(record);
      record = record._nextRec;
    }

    var additions = [];
    record = _additionsHead;
    while(record != null) {
      additions.add(record);
      record = record._nextAddedRec;
    }

    var moves = [];
    record = _movesHead;
    while(record != null) {
      moves.add(record);
      record = record._nextMovedRec;
    }

    var removals = [];
    record = _removalsHead;
    while(record != null) {
      removals.add(record);
      record = record._nextRemovedRec;
    }

    return """
collection: ${list.join(", ")}
additions: ${additions.join(", ")}
moves: ${moves.join(", ")}
removals: ${removals.join(", ")}'
    """;
  }
}

class ItemRecord<K, V> implements CollectionItem<K, V>, AddedItem<K, V>, MovedItem<K, V>, RemovedItem<K, V> {
  K previousKey = null;
  K currentKey = null;
  V item = _INITIAL_;

  ItemRecord<K, V> _prevRec, _nextRec;
  ItemRecord<K, V> _prevDupRec, _nextDupRec;
  ItemRecord<K, V> _prevRemovedRec, _nextRemovedRec;
  ItemRecord<K, V> _nextAddedRec, _nextMovedRec;

  CollectionItem<K, V> get nextCollectionItem => _nextRec;
  RemovedItem<K, V> get nextRemovedItem => _nextRemovedRec;
  AddedItem<K, V> get nextAddedItem => _nextAddedRec;
  MovedItem<K, V> get nextMovedItem => _nextMovedRec;

  ItemRecord(this.item);

  toString() => previousKey == currentKey ?
      '$item' :
      '$item[$previousKey -> $currentKey]';
}

class _DuplicateItemRecordList {
  ItemRecord head, tail;

  add(ItemRecord record, ItemRecord beforeRecord) {
    assert(record._prevDupRec == null);
    assert(record._nextDupRec == null);
    assert(beforeRecord == null ? true : beforeRecord.item == record.item);
    if (head == null) {
      assert(beforeRecord == null);
      head = tail = record;
    } else {
      assert(record.item == head.item);
      if (beforeRecord == null) {
        tail._nextDupRec = record;
        record._prevDupRec = tail;
        tail = record;
      } else {
        var prev = beforeRecord._prevDupRec;
        var next = beforeRecord;
        record._prevDupRec = prev;
        record._nextDupRec = next;
        if (prev == null) head = record; else prev._nextDupRec = record;
        next._prevDupRec = record;
      }
    }
  }

  ItemRecord get(dynamic key, int hideIndex) {
    ItemRecord record = head;
    while(record != null) {
      if (hideIndex == null ? true : hideIndex < record.currentKey &&
          identical(record.item, key)) {
        return record;
      }
      record = record._nextDupRec;
    }
    return record;
  }

  bool remove(ItemRecord record) {
    assert(() {
      // verify that the record being removed is someplace in the list.
      ItemRecord cursor = head;
      while(cursor != null) {
        if (identical(cursor, record)) return true;
        cursor = cursor._nextDupRec;
      }
      return false;
    });

    var prev = record._prevDupRec;
    var next = record._nextDupRec;
    if (prev == null) {
      head = next;
    } else {
      prev._nextDupRec = next;
    }
    if (next == null) {
      tail = prev;
    } else {
      next._prevDupRec = prev;
    }

    assert((record._prevDupRec = null) == null);
    assert((record._nextDupRec = null) == null);

    return head == null;
  }
}

/**
 * This is a custom map which supports duplicate [ItemRecord] values for each key.
 */
class DuplicateMap {
  final Map<dynamic, _DuplicateItemRecordList> map =
      new Map<dynamic, _DuplicateItemRecordList>();

  void put(ItemRecord record, [ItemRecord beforeRecord = null]) {
    assert(record._nextDupRec == null);
    assert(record._prevDupRec == null);
    map.putIfAbsent(record.item, () =>
        new _DuplicateItemRecordList()).add(record, beforeRecord);
  }

  /**
   * Retrieve the `value` using [key]. Because the [ItemRecord] value maybe one
   * which we have already iterated over, we use the [hideIndex] to pretend it
   * is not there.
   *
   * Use case: `[a, b, c, a, a]` if we are at index `3` which is the second `a`
   * then asking if we have any more `a`s needs to return the last `a` not the
   * first or second.
   */
  ItemRecord get(dynamic key, [int hideIndex]) {
    _DuplicateItemRecordList recordList = map[key];
    ItemRecord item = recordList == null ? null : recordList.get(key, hideIndex);
    return item;
  }

  ItemRecord remove(ItemRecord record) {
    _DuplicateItemRecordList recordList = map[record.item];
    assert(recordList != null);
    if (recordList.remove(record)) {
      map.remove(record.item);
    }
    return record;
  }

  clear() => map.clear();
}
