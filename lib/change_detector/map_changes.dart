part of angular.change_detector;

class _MapChangeRecord<K, V> implements MapChangeRecord<K, V> {
  final _records = new HashMap<dynamic, KeyValueRecord>();
  Map _map;

  Map get map => _map;

  KeyValueRecord<K, V> _mapHead;
  KeyValueRecord<K, V> _previousMapHead;
  KeyValueRecord<K, V> _changesHead, _changesTail;
  KeyValueRecord<K, V> _additionsHead, _additionsTail;
  KeyValueRecord<K, V> _removalsHead, _removalsTail;

  bool get isDirty => _additionsHead != null ||
                     _changesHead != null ||
                     _removalsHead != null;

  KeyValueRecord<K, V> r;

  void forEachItem(void f(MapKeyValue<K, V> change)) {
    for (r = _mapHead; r != null; r = r._next) {
      f(r);
    }
  }

  void forEachPreviousItem(void f(MapKeyValue<K, V> change)) {
    for (r = _previousMapHead; r != null; r = r._nextPrevious) {
      f(r);
    }
  }

  void forEachChange(void f(MapKeyValue<K, V> change)) {
    for (r = _changesHead; r != null; r = r._nextChanged) {
      f(r);
    }
  }

  void forEachAddition(void f(MapKeyValue<K, V> addition)){
    for (r = _additionsHead; r != null; r = r._nextAdded) {
      f(r);
    }
  }

  void forEachRemoval(void f(MapKeyValue<K, V> removal)){
    for (r = _removalsHead; r != null; r = r._nextRemoved) {
      f(r);
    }
  }

  bool _check(Map map) {
    _reset();
    _map = map;
    Map records = _records;
    KeyValueRecord oldSeqRecord = _mapHead;
    KeyValueRecord lastOldSeqRecord;
    KeyValueRecord lastNewSeqRecord;
    var seqChanged = false;
    map.forEach((key, value) {
      var newSeqRecord;
      if (oldSeqRecord != null && key == oldSeqRecord.key) {
        newSeqRecord = oldSeqRecord;
        if (!_looseIdentical(value, oldSeqRecord._currentValue)) {
          var prev = oldSeqRecord._previousValue = oldSeqRecord._currentValue;
          oldSeqRecord._currentValue = value;
          _addToChanges(oldSeqRecord);
        }
      } else {
        seqChanged = true;
        if (oldSeqRecord != null) {
          oldSeqRecord._next = null;
          _removeFromSeq(lastOldSeqRecord, oldSeqRecord);
          _addToRemovals(oldSeqRecord);
        }
        if (records.containsKey(key)) {
          newSeqRecord = records[key];
        } else {
          newSeqRecord = records[key] = new KeyValueRecord(key);
          newSeqRecord._currentValue = value;
          _addToAdditions(newSeqRecord);
        }
      }

      if (seqChanged) {
        if (_isInRemovals(newSeqRecord)) {
          _removeFromRemovals(newSeqRecord);
        }
        if (lastNewSeqRecord == null) {
          _mapHead = newSeqRecord;
        } else {
          lastNewSeqRecord._next = newSeqRecord;
        }
      }
      lastOldSeqRecord = oldSeqRecord;
      lastNewSeqRecord = newSeqRecord;
      oldSeqRecord = oldSeqRecord == null ? null : oldSeqRecord._next;
    });
    _truncate(lastOldSeqRecord, oldSeqRecord);
    return isDirty;
  }

  void _reset() {
    if (isDirty) {
      // Record the state of the mapping
      for (KeyValueRecord record = _previousMapHead = _mapHead;
           record != null;
           record = record._next) {
        record._nextPrevious = record._next;
      }
      _undoDeltas();
    }
  }

  void _undoDeltas() {
    KeyValueRecord<K, V> r;

    for (r = _changesHead; r != null; r = r._nextChanged) {
      r._previousValue = r._currentValue;
    }

    for (r = _additionsHead; r != null; r = r._nextAdded) {
      r._previousValue = r._currentValue;
    }

    assert((() {
      var r = _changesHead;
      while (r != null) {
        var nextRecord = r._nextChanged;
        r._nextChanged = null;
        r = nextRecord;
      }

      r = _additionsHead;
      while (r != null) {
        var nextRecord = r._nextAdded;
        r._nextAdded = null;
        r = nextRecord;
      }

      r = _removalsHead;
      while (r != null) {
        var nextRecord = r._nextRemoved;
        r._nextRemoved = null;
        r = nextRecord;
      }

      return true;
    })());
    _changesHead = _changesTail = null;
    _additionsHead = _additionsTail = null;
    _removalsHead = _removalsTail = null;
  }

  void _truncate(KeyValueRecord lastRecord, KeyValueRecord record) {
    while (record != null) {
      if (lastRecord == null) {
        _mapHead = null;
      } else {
        lastRecord._next = null;
      }
      var nextRecord = record._next;
      assert((() {
        record._next = null;
        return true;
      })());
      _addToRemovals(record);
      lastRecord = record;
      record = nextRecord;
    }

    for (var r = _removalsHead; r != null; r = r._nextRemoved) {
      r._previousValue = r._currentValue;
      r._currentValue = null;
      _records.remove(r.key);
    }
  }

  bool _isInRemovals(KeyValueRecord record) =>
      record == _removalsHead ||
      record._nextRemoved != null ||
      record._prevRemoved != null;

  void _addToRemovals(KeyValueRecord record) {
    assert(record._next == null);
    assert(record._nextAdded == null);
    assert(record._nextChanged == null);
    assert(record._nextRemoved == null);
    assert(record._prevRemoved == null);
    if (_removalsHead == null) {
      _removalsHead = _removalsTail = record;
    } else {
      _removalsTail._nextRemoved = record;
      record._prevRemoved = _removalsTail;
      _removalsTail = record;
    }
  }

  void _removeFromSeq(KeyValueRecord prev, KeyValueRecord record) {
    KeyValueRecord next = record._next;
    if (prev == null) {
      _mapHead = next;
    } else {
      prev._next = next;
    }
    assert((() {
      record._next = null;
      return true;
    })());
  }

  void _removeFromRemovals(KeyValueRecord record) {
    assert(record._next == null);
    assert(record._nextAdded == null);
    assert(record._nextChanged == null);

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
    record._prevRemoved = record._nextRemoved = null;
  }

  void _addToAdditions(KeyValueRecord record) {
    assert(record._next == null);
    assert(record._nextAdded == null);
    assert(record._nextChanged == null);
    assert(record._nextRemoved == null);
    assert(record._prevRemoved == null);
    if (_additionsHead == null) {
      _additionsHead = _additionsTail = record;
    } else {
      _additionsTail._nextAdded = record;
      _additionsTail = record;
    }
  }

  void _addToChanges(KeyValueRecord record) {
    assert(record._nextAdded == null);
    assert(record._nextChanged == null);
    assert(record._nextRemoved == null);
    assert(record._prevRemoved == null);
    if (_changesHead == null) {
      _changesHead = _changesTail = record;
    } else {
      _changesTail._nextChanged = record;
      _changesTail = record;
    }
  }

  String toString() {
    List itemsList = [], previousList = [], changesList = [], additionsList = [], removalsList = [];
    KeyValueRecord<K, V> r;
    for (r = _mapHead; r != null; r = r._next) {
      itemsList.add("$r");
    }
    for (r = _previousMapHead; r != null; r = r._nextPrevious) {
      previousList.add("$r");
    }
    for (r = _changesHead; r != null; r = r._nextChanged) {
      changesList.add("$r");
    }
    for (r = _additionsHead; r != null; r = r._nextAdded) {
      additionsList.add("$r");
    }
    for (r = _removalsHead; r != null; r = r._nextRemoved) {
      removalsList.add("$r");
    }
    return """
map: ${itemsList.join(", ")}
previous: ${previousList.join(", ")}
changes: ${changesList.join(", ")}
additions: ${additionsList.join(", ")}
removals: ${removalsList.join(", ")}
""";
  }
}

class KeyValueRecord<K, V> implements MapKeyValue<K, V> {
  final K key;
  V _previousValue, _currentValue;

  V get previousValue => _previousValue;
  V get currentValue => _currentValue;

  KeyValueRecord<K, V> _nextPrevious;
  KeyValueRecord<K, V> _next;
  KeyValueRecord<K, V> _nextAdded;
  KeyValueRecord<K, V> _nextRemoved, _prevRemoved;
  KeyValueRecord<K, V> _nextChanged;

  KeyValueRecord(this.key);

  String toString() => _previousValue == _currentValue
        ? "$key"
        : '$key[$_previousValue -> $_currentValue]';
}


/**
 * Returns whether the [dst] and [src] are loosely identical:
 * * true when the value are identical,
 * * true when both values are equal strings,
 * * true when both values are NaN
 *
 * If both values are equal string, src is assigned to dst.
 */
bool _looseIdentical(dst, src) {
  if (identical(dst, src)) return true;

  if (dst is String && src is String && dst == src) {
    // this is false change in strings we need to recover, and pretend it is the same. We save the
    // value so that next time identity can pass
    return true;
  }

  //  we need this for JavaScript since in JS NaN !== NaN.
  if (dst is num && (dst as num).isNaN && src is num && (src as num).isNaN) return true;

  return false;
}
