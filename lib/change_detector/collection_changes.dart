part of angular.change_detector;

class CollectionChangeRecord<V> {
  Iterable _iterable;
  int _length;

  /// Keeps track of the used records at any point in time (during & across `_check()` calls)
  DuplicateMap _linkedRecords;

  /// Keeps track of the removed records at any point in time during `_check()` calls.
  DuplicateMap _unlinkedRecords;

  CollectionChangeItem<V> _previousItHead;
  CollectionChangeItem<V> _itHead, _itTail;
  CollectionChangeItem<V> _additionsHead, _additionsTail;
  CollectionChangeItem<V> _movesHead, _movesTail;
  CollectionChangeItem<V> _removalsHead, _removalsTail;

  void forEachItem(void f(CollectionChangeItem<V> item)) {
    for (var r = _itHead; r != null; r = r._next) {
      f(r);
    }
  }

  void forEachPreviousItem(void f(CollectionChangeItem<V> previousItem)) {
    for (var r = _previousItHead; r != null; r = r._nextPrevious) {
      f(r);
    }
  }

  void forEachAddition(void f(CollectionChangeItem<V> addition)){
    for (var r = _additionsHead; r != null; r = r._nextAdded) {
      f(r);
    }
  }

  void forEachMove(void f(CollectionChangeItem<V> change)) {
    for (var r = _movesHead; r != null; r = r._nextMoved) {
      f(r);
    }
  }

  void forEachRemoval(void f(CollectionChangeItem<V> removal)){
    for (var r = _removalsHead; r != null; r = r._nextRemoved) {
      f(r);
    }
  }

  Iterable get iterable => _iterable;
  int get length => _length;

  bool _check(Iterable collection) {
    _reset();

    if (collection is UnmodifiableListView && identical(_iterable, collection)) {
      // Short circuit and assume that the list has not been modified.
      return false;
    }

    CollectionChangeItem<V> record = _itHead;
    bool maybeDirty = false;

    if (collection is List) {
      List list = collection;
      _length = list.length;
      for (int index = 0; index < _length; index++) {
        var item = list[index];
        if (record == null || !_looseIdentical(record.item, item)) {
          record = mismatch(record, item, index);
          maybeDirty = true;
        } else if (maybeDirty) {
          // TODO(misko): can we limit this to duplicates only?
          record = verifyReinsertion(record, item, index);
        }
        record = record._next;
      }
    } else {
      int index = 0;
      for (var item in collection) {
        if (record == null || !_looseIdentical(record.item, item)) {
          record = mismatch(record, item, index);
          maybeDirty = true;
        } else if (maybeDirty) {
          // TODO(misko): can we limit this to duplicates only?
          record = verifyReinsertion(record, item, index);
        }
        record = record._next;
        index++;
      }
      _length = index;
    }

    _truncate(record);
    _iterable = collection;
    return isDirty;
  }

  /**
   * Reset the state of the change objects to show no changes. This means set previousKey to
   * currentKey, and clear all of the queues (additions, moves, removals).
   */
  void _reset() {
    if (isDirty) {
      // Record the state of the collection
      for (CollectionChangeItem<V> r = _previousItHead = _itHead; r != null; r = r._next) {
        r._nextPrevious = r._next;
      }
      _undoDeltas();
    }
  }

  /// Set the [previousIndex]es of moved and added items to their [currentIndex]es
  /// Reset the list of additions, moves and removals
  void _undoDeltas() {
    CollectionChangeItem<V> record;

    record = _additionsHead;
    while (record != null) {
      record.previousIndex = record.currentIndex;
      record = record._nextAdded;
    }
    _additionsHead = _additionsTail = null;

    record = _movesHead;
    while (record != null) {
      record.previousIndex = record.currentIndex;
      var nextRecord = record._nextMoved;
      assert((record._nextMoved = null) == null);
      record = nextRecord;
    }
    _movesHead = _movesTail = null;
    _removalsHead = _removalsTail = null;
    assert(isDirty == false);
  }

  /// A [_CollectionChangeRecord] is considered dirty if it has additions, moves or removals.
  bool get isDirty => _additionsHead != null ||
                      _movesHead != null ||
                      _removalsHead != null;

  /**
   * This is the core function which handles differences between collections.
   *
   * - [record] is the record which we saw at this position last time. If [:null:] then it is a new
   *   item.
   * - [item] is the current item in the collection
   * - [index] is the position of the item in the collection
   */
  CollectionChangeItem<V> mismatch(CollectionChangeItem<V> record, item, int index) {
    // The previous record after which we will append the current one.
    CollectionChangeItem<V> previousRecord;

    if (record == null) {
      previousRecord = _itTail;
    } else {
      previousRecord = record._prev;
      // Remove the record from the collection since we know it does not match the item.
      _remove(record);
    }

    // Attempt to see if we have seen the item before.
    record = _linkedRecords == null ? null : _linkedRecords.get(item, index);
    if (record != null) {
      // We have seen this before, we need to move it forward in the collection.
      _moveAfter(record, previousRecord, index);
    } else {
      // Never seen it, check evicted list.
      record = _unlinkedRecords == null ? null : _unlinkedRecords.get(item);
      if (record != null) {
        // It is an item which we have evicted earlier: reinsert it back into the list.
        _reinsertAfter(record, previousRecord, index);
      } else {
        // It is a new item: add it.
        record = _addAfter(new CollectionChangeItem<V>(item), previousRecord, index);
      }
    }
    return record;
  }

  /**
   * This check is only needed if an array contains duplicates. (Short circuit of nothing dirty)
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
   * Double check that we have not evicted a duplicate item. We need to check if the item type may
   * have already been removed:
   * The insertion of b will evict the first 'a'. If we don't reinsert it now it will be reinserted
   * at the end. Which will show up as the two 'a's switching position. This is incorrect, since a
   * better way to think of it is as insert of 'b' rather then switch 'a' with 'b' and then add 'a'
   * at the end.
   */
  CollectionChangeItem<V> verifyReinsertion(CollectionChangeItem record, item, int index) {
    CollectionChangeItem<V> reinsertRecord = _unlinkedRecords == null ?
        null :
        _unlinkedRecords.get(item);
    if (reinsertRecord != null) {
      record = _reinsertAfter(reinsertRecord, record._prev, index);
    } else if (record.currentIndex != index) {
      record.currentIndex = index;
      _addToMoves(record, index);
    }
    return record;
  }

  /**
   * Get rid of any excess [CollectionChangeItem]s from the previous collection
   *
   * - [record] The first excess [CollectionChangeItem].
   */
  void _truncate(CollectionChangeItem<V> record) {
    // Anything after that needs to be removed;
    while (record != null) {
      CollectionChangeItem<V> nextRecord = record._next;
      _addToRemovals(_unlink(record));
      record = nextRecord;
    }
    if (_unlinkedRecords != null) _unlinkedRecords.clear();

    if (_additionsTail != null) _additionsTail._nextAdded = null;
    if (_movesTail != null) _movesTail._nextMoved = null;
    if (_itTail != null) _itTail._next = null;
    if (_removalsTail != null) _removalsTail._nextRemoved = null;
  }

  CollectionChangeItem<V> _reinsertAfter(CollectionChangeItem<V> record,
                                         CollectionChangeItem<V> prevRecord, int index) {
    if (_unlinkedRecords != null) _unlinkedRecords.remove(record);
    var prev = record._prevRemoved;
    var next = record._nextRemoved;

    if (prev == null) {
      _removalsHead = next;
    } else {
      prev._nextRemoved = next;
    }
    if (next == null) {
      _removalsTail = prev;
    } else {
      next._prevRemoved = prev;
    }

    _insertAfter(record, prevRecord, index);
    _addToMoves(record, index);
    return record;
  }

  CollectionChangeItem<V> _moveAfter(CollectionChangeItem<V> record,
                                     CollectionChangeItem<V> prevRecord, int index) {
    _unlink(record);
    _insertAfter(record, prevRecord, index);
    _addToMoves(record, index);
    return record;
  }

  CollectionChangeItem<V> _addAfter(CollectionChangeItem<V> record,
                                    CollectionChangeItem<V> prevRecord, int index) {
    _insertAfter(record, prevRecord, index);

    if (_additionsTail == null) {
      assert(_additionsHead == null);
      _additionsTail = _additionsHead = record;
    } else {
      assert(_additionsTail._nextAdded == null);
      assert(record._nextAdded == null);
      _additionsTail = _additionsTail._nextAdded = record;
    }
    return record;
  }

  CollectionChangeItem<V> _insertAfter(CollectionChangeItem<V> record,
                                       CollectionChangeItem<V> prevRecord, int index) {
    assert(record != prevRecord);
    assert(record._next == null);
    assert(record._prev == null);

    CollectionChangeItem<V> next = prevRecord == null ? _itHead : prevRecord._next;
    assert(next != record);
    assert(prevRecord != record);
    record._next = next;
    record._prev = prevRecord;
    if (next == null) {
      _itTail = record;
    } else {
      next._prev = record;
    }
    if (prevRecord == null) {
      _itHead = record;
    } else {
      prevRecord._next = record;
    }

    if (_linkedRecords == null) _linkedRecords = new DuplicateMap();
    _linkedRecords.put(record);

    record.currentIndex = index;
    return record;
  }

  CollectionChangeItem<V> _remove(CollectionChangeItem record) => _addToRemovals(_unlink(record));

  CollectionChangeItem<V> _unlink(CollectionChangeItem record) {
    if (_linkedRecords != null) _linkedRecords.remove(record);

    var prev = record._prev;
    var next = record._next;

    assert((record._prev = null) == null);
    assert((record._next = null) == null);

    if (prev == null) {
      _itHead = next;
    } else {
      prev._next = next;
    }
    if (next == null) {
      _itTail = prev;
    } else {
      next._prev = prev;
    }

    return record;
  }

  CollectionChangeItem<V> _addToMoves(CollectionChangeItem<V> record, int toIndex) {
    assert(record._nextMoved == null);

    if (record.previousIndex == toIndex) return record;

    if (_movesTail == null) {
      assert(_movesHead == null);
      _movesTail = _movesHead = record;
    } else {
      assert(_movesTail._nextMoved == null);
      _movesTail = _movesTail._nextMoved = record;
    }

    return record;
  }

  CollectionChangeItem<V> _addToRemovals(CollectionChangeItem<V> record) {
    if (_unlinkedRecords == null) _unlinkedRecords = new DuplicateMap();
    _unlinkedRecords.put(record);
    record.currentIndex = null;
    record._nextRemoved = null;

    if (_removalsTail == null) {
      assert(_removalsHead == null);
      _removalsTail = _removalsHead = record;
      record._prevRemoved = null;
    } else {
      assert(_removalsTail._nextRemoved == null);
      assert(record._nextRemoved == null);
      record._prevRemoved = _removalsTail;
      _removalsTail = _removalsTail._nextRemoved = record;
    }
    return record;
  }

  String toString() {
    CollectionChangeItem<V> r;

    var list = [];
    for (r = _itHead; r != null; r = r._next) {
      list.add(r);
    }

    var previous = [];
    for (r = _previousItHead; r != null; r = r._nextPrevious) {
      previous.add(r);
    }

    var additions = [];
    for (r = _additionsHead; r != null; r = r._nextAdded) {
      additions.add(r);
    }
    var moves = [];
    for (r = _movesHead; r != null; r = r._nextMoved) {
      moves.add(r);
    }

    var removals = [];
    for (r = _removalsHead; r != null; r = r._nextRemoved) {
      removals.add(r);
    }

    return """
collection: ${list.join(", ")}
previous: ${previous.join(", ")}
additions: ${additions.join(", ")}
moves: ${moves.join(", ")}
removals: ${removals.join(", ")}
""";
  }
}

class CollectionChangeItem<V>  {
  int currentIndex;
  int previousIndex;
  V item;

  CollectionChangeItem<V> _nextPrevious;
  CollectionChangeItem<V> _prev, _next;
  CollectionChangeItem<V> _prevDup, _nextDup;
  CollectionChangeItem<V> _prevRemoved, _nextRemoved;
  CollectionChangeItem<V> _nextAdded;
  CollectionChangeItem<V> _nextMoved;

  CollectionChangeItem(this.item);

  String toString() => previousIndex == currentIndex
      ? '$item'
      : '$item[$previousIndex -> $currentIndex]';
}

/// A linked list of [CollectionChangeItem]s with the same [CollectionChangeItem.item]
class _DuplicateItemRecordList {
  CollectionChangeItem _head, _tail;

  /**
   * Append the [record] to the list of duplicates.
   *
   * Note: by design all records in the list of duplicates hold the save value in [record.item].
   */
  void add(CollectionChangeItem record) {
    if (_head == null) {
      _head = _tail = record;
      record._nextDup = null;
      record._prevDup = null;
    } else {
      assert(record.item ==  _head.item ||
             record.item is num && record.item.isNaN && _head.item is num && _head.item.isNaN);
      _tail._nextDup = record;
      record._prevDup = _tail;
      record._nextDup = null;
      _tail = record;
    }
  }

  /// Returns an [CollectionChangeItem] having [CollectionChangeItem.item] == [item] and
  /// [CollectionChangeItem.currentIndex] >= [afterIndex]
  CollectionChangeItem get(item, int afterIndex) {
    CollectionChangeItem record;
    for (record = _head; record != null; record = record._nextDup) {
      if ((afterIndex == null || afterIndex < record.currentIndex) &&
           _looseIdentical(record.item, item)) {
          return record;
        }
      }
    return null;
  }

  /**
   * Remove one [CollectionChangeItem] from the list of duplicates.
   *
   * Returns whether the list of duplicates is empty.
   */
  bool remove(CollectionChangeItem record) {
    assert(() {
      // verify that the record being removed is in the list.
      for (CollectionChangeItem cursor = _head; cursor != null; cursor = cursor._nextDup) {
        if (identical(cursor, record)) return true;
      }
      return false;
    });

    var prev = record._prevDup;
    var next = record._nextDup;
    if (prev == null) {
      _head = next;
    } else {
      prev._nextDup = next;
    }
    if (next == null) {
      _tail = prev;
    } else {
      next._prevDup = prev;
    }
    return _head == null;
  }
}

/**
 * [DuplicateMap] maps [CollectionChangeItem.value] to a list of [CollectionChangeItem] having the
 * same value (duplicates).
 *
 * The list of duplicates is implemented by [_DuplicateItemRecordList].
 */
class DuplicateMap {
  static final _nanKey = const Object();
  final map = new HashMap<dynamic, _DuplicateItemRecordList>();

  void put(CollectionChangeItem record) {
    var key = _getKey(record.item);
    _DuplicateItemRecordList duplicates = map[key];
    if (duplicates == null) {
      duplicates = map[key] = new _DuplicateItemRecordList();
    }
    duplicates.add(record);
  }

  /**
   * Retrieve the `value` using [key]. Because the [CollectionChangeItem] value maybe one which we
   * have already iterated over, we use the [afterIndex] to pretend it is not there.
   *
   * Use case: `[a, b, c, a, a]` if we are at index `3` which is the second `a` then asking if we
   * have any more `a`s needs to return the last `a` not the first or second.
   */
  CollectionChangeItem get(value, [int afterIndex]) {
    var key = _getKey(value);
    _DuplicateItemRecordList recordList = map[key];
    return recordList == null ? null : recordList.get(value, afterIndex);
  }

  /**
   * Removes an [CollectionChangeItem] from the list of duplicates.
   *
   * The list of duplicates also is removed from the map if it gets empty.
   */
  CollectionChangeItem remove(CollectionChangeItem record) {
    var key = _getKey(record.item);
    assert(map.containsKey(key));
    _DuplicateItemRecordList recordList = map[key];
    // Remove the list of duplicates when it gets empty
    if (recordList.remove(record)) map.remove(key);
    return record;
  }

  bool get isEmpty => map.isEmpty;

  void clear() {
    map.clear();
  }

  /// Required to handle num.NAN as a Map value
  dynamic _getKey(value) => value is num && value.isNaN ? _nanKey : value;

  String toString() => "DuplicateMap($map)";
}
