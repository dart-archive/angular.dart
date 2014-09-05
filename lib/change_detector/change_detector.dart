library angular.change_detector;

// TODO: check for recent changes in:
//  - dccd
//  - watch group
// Checked on 2014.09.04
// -> disable coalescence (make it optional, add test for both cases)

// TODO:
// - re-enable tracing
// - re-enable stopwatches

// TODO:
//
// - It should no more be possible to add a watch during a rfn. This should allow simplifying the
//   code (the processChanges() loop, and the logic to get the next checkable record).
// - It should no more be possible to remove a watch group from inside a rfn. We should assert that
//   the current watch group has not been detached when returning from a rfn.


// TODO:
// Currently the (H&T) markers participate in the checkable & releasable lists. The code could be
// more efficient if the markers are not part of those lists.
// Note: For efficiency when manipulating groups, the marker should still have their checkNext
// field pointing to the first checkable record in the group (releaseNext/releasable Marker)
//
// Also each group has its own head & tail markers, it could be possible to coalesce head-tail
// but that implies that the head/tail marker of a group could be updated when a group is removed
// or added - this had been implemented but reverted for now until Proto are implemented


// TODO:
// replace _hasFreshListener by initializing _value with a unique value (ie this), should allow
// avoiding to read the mode field

// TODO: implement with ProtoWatchGroup / ProtoRecord
// We need to talk about this more in depth. But my latest thinking is that we can not create
// WatchGroup with context. The context needs to be something which we can assign later. The reason
// for this is that we want to be able to reset the context at runtime. The benefit would be to be
// able to reuse an instance of WatchGroup for performance reasons. Let's discus.

import 'dart:collection';

part 'ast.dart';
part 'map_changes.dart';
part 'collection_changes.dart';
part 'prototype_map.dart';

typedef void EvalExceptionHandler(error, stack);

typedef dynamic FieldGetter(object);
typedef void FieldSetter(object, value);

typedef void ReactionFn(value, previousValue);
typedef void ChangeLog(String expression, current, previous);

abstract class FieldGetterFactory {
  FieldGetter getter(Object object, String name);
}

class AvgStopwatch extends Stopwatch {
  int _count = 0;

  int get count => _count;

  void reset() {
    _count = 0;
    super.reset();
  }

  int increment(int count) => _count += count;

  double get ratePerMs => elapsedMicroseconds == 0
      ? 0.0
      : _count / elapsedMicroseconds * 1000;
}


// TODO: this should not be needed anymore
/**
 * Extend this class if you wish to pretend to be a function, but you don't know
 * number of arguments with which the function will get called with.
 */
abstract class FunctionApply {
  dynamic call() { throw new StateError('Use apply()'); }
  dynamic apply(List arguments);
}

/**
 * [ChangeDetector] allows creating root watch groups holding the [Watch]es
 */
class ChangeDetector {
  static int _nextRootId = 0;

  final FieldGetterFactory _fieldGetterFactory;

  ChangeDetector(this._fieldGetterFactory);

  /// Creates a root watch group
  WatchGroup createWatchGroup(Object context) => new WatchGroup(null, context, _fieldGetterFactory);
}

// TODO: add toString
class WatchGroup {
  Record _headMarker, _tailMarker;

  WatchGroup _root;
  WatchGroup _parent;
  WatchGroup _next, _prev;
  WatchGroup _childHead, _childTail;

  Object _context;

  String _id;
  String get id => _id;

  int _nextChildId = 0;

  // We need to keep track of whether we are processing changes because in such a case the added
  // records must have their context initialized as they will be processed in the same cycle
  bool _processingChanges = false;

  // maps the currently watched expressions to their record to allow coalescence
  final _recordCache = new HashMap<String, Record>();

  final FieldGetterFactory _fieldGetterFactory;

  // TODO: Do we really need this ? (keep the API simple)
  // Watches in this group
  int _watchedFields = 0;
  int _watchedCollections = 0;
  int _watchedEvals = 0;
  int get watchedFields => _watchedFields;
  int get watchedCollections => _watchedCollections;
  int get watchedEvals => _watchedEvals;
  // TODO: test
  int get checkedRecords {
    int count = 0;
    for (Record record= _headMarker._checkNext;
         record != _tailMarker;
         record = record._checkNext) {
      count++;
    }
    return count;
  }

  /// Number of watched fields in this group and child groups
  int get totalWatchedFields {
    var count = _watchedFields;
    for (WatchGroup child = _childHead; child != null; child = child._next) {
      count += child.totalWatchedFields;
    }
    return count;
  }

  /// Number of watched collections in this group and child groups
  int get totalWatchedCollections {
    var count = _watchedCollections;
    for (WatchGroup child = _childHead; child != null; child = child._next) {
      count += child.totalWatchedCollections;
    }
    return count;
  }

  /// Number of watched evals in this group and child groups
  int get totalWatchedEvals {
    var count = _watchedEvals;
    for (WatchGroup child = _childHead; child != null; child = child._next) {
      count += child.totalWatchedEvals;
    }
    return count;
  }

  /// Number of [Record]s in this group and child groups
  int get totalCount {
    var count = 0;
    for (Record current = _headMarker._next; current != _tailMarker; current = current._next) {
      count++;
    }
    for (WatchGroup child = _childHead; child != null; child = child._next) {
      count += child.totalCount;
    }
    return count;
  }

  /// Number of checked [Record]s in this group and child groups
  int get totalCheckedRecords {
    int count = 0;
    for (Record record= _headMarker._checkNext;
         record != _tailMarkerIncludingChildren;
         record = record._checkNext) {
      count++;
    }
    return count;
  }

  WatchGroup(this._parent, this._context, this._fieldGetterFactory) {
    _tailMarker = new Record._marker(this);
    _headMarker = new Record._marker(this);

    // Cross link the head and tail markers
    _headMarker._next = _tailMarker;
    _headMarker._releasableNext = _tailMarker;
    _headMarker._checkNext = _tailMarker;

    _tailMarker._prev = _headMarker;
    _tailMarker._checkPrev = _headMarker;

    if (_parent == null) {
      _root = this;
      _id = '${ChangeDetector._nextRootId++}';
    } else {
      _id = '${_parent._id}.${_parent._nextChildId++}';
      _root = _parent._root;
      // Re-use the previous group [_tailMarker] as our head
      var prevGroupTail = _parent._tailMarkerIncludingChildren;

      assert(prevGroupTail == null || prevGroupTail.isMarker);

      _tailMarker._releasableNext = prevGroupTail._releasableNext;
      _tailMarker._checkNext = prevGroupTail._checkNext;
      _tailMarker._next = prevGroupTail._next;

      _headMarker._prev = prevGroupTail;
      _headMarker._checkPrev = prevGroupTail;

      prevGroupTail._next = _headMarker;
      prevGroupTail._checkNext = _headMarker;
      prevGroupTail._releasableNext = _headMarker;

      if (_tailMarker._next != null) {
        _tailMarker._next._prev = _tailMarker;
        _tailMarker._checkNext._checkPrev = _tailMarker;
      }

      // Link this group in the parent's group list
      if (_parent._childHead == null) {
        _parent._childHead = this;
        _parent._childTail = this;
      } else {
        // Append the child group at the end of the child list
        _parent._childTail._next = this;
        _prev = _parent._childTail;
        _parent._childTail = this;
      }
    }
  }

  /// Creates a child [WatchGroup]
  WatchGroup createChild([Object context]) =>
      new WatchGroup(this, context == null ? _context : context, _fieldGetterFactory);

  /// Watches the [AST] and invoke the [reactionFn] when a change is detected during a call to
  /// [processChanges]
  Watch watch(AST ast, reactionFn) {
    Record trigger = _getRecordFor(ast);
    return new Watch(trigger, reactionFn);
  }

  /// Calls reaction functions when a watched [AST] value has been modified since last call
  int processChanges({EvalExceptionHandler exceptionHandler, ChangeLog changeLog}) {
    _processingChanges = true;
    int changes = 0;
    // We need to keep a reference on the previously checked record to find out the next one
    Record checkPrev = _headMarker;
    for (Record record = _headMarker._checkNext;
         record != _tailMarkerIncludingChildren;
         record = checkPrev._checkNext) {

      try {
        changes += record.processChange(changeLog: changeLog);
      } catch (e, s) {
        if (exceptionHandler == null) {
          rethrow;
        } else {
          exceptionHandler(e, s);
        }
      }

      // TODO: It is no more possible to add a watch during a rfn so this code could be simplified

      // TODO: assert that the watch group is not removed (only needed when returning from a rfn)

      if (record.removeFromCheckQueue) {
        // If the record gets removed from the check queue, do not update `checkPrev`
        if (record.isChecked) record.$removeFromCheckQueue();
      } else if (record._checkNext != null) {
        // Update `checkPrev` to be the current record unless it's no more checked (removed from
        // inside the reaction function)
        checkPrev = record;
      }
    }
    _processingChanges = false;
    return changes;
  }

  /// Whether the group is currently attached (=active)
  bool get isAttached {
    WatchGroup group = this;
    while (group._parent != null) {
      group = group._parent;
    }
    return group == _root;
  }

  /// De-activate the group and free any underlying resources
  void remove() {
    if (this == _root) throw new StateError('Root ChangeDetector can not be removed');

    // Release the resources associated with the records
    for (Record record = _headMarker._releasableNext;
         record != _tailMarkerIncludingChildren;
         record = record._releasableNext) {
      record.release();
    }

    _recordCache.clear();

    // Unlink the records
    var nextGroupHead = _tailMarkerIncludingChildren._next;
    var prevGroupTail = _headMarker._prev;

    assert(nextGroupHead == null || nextGroupHead.isMarker);
    assert(prevGroupTail == null || prevGroupTail.isMarker);

    if (prevGroupTail != null) {
      prevGroupTail._next = nextGroupHead;
      prevGroupTail._checkNext = nextGroupHead;
      prevGroupTail._releasableNext = nextGroupHead;
    }

    if (nextGroupHead != null) {
      nextGroupHead._prev = prevGroupTail;
      nextGroupHead._checkPrev = prevGroupTail;
    }

    // Unlink the group
    var prevGroup = _prev;
    var nextGroup = _next;

    if (prevGroup == null) {
      if (_parent != null) _parent._childHead = nextGroup;
    } else {
      prevGroup._next = nextGroup;
    }

    if (nextGroup == null) {
      if (_parent != null) _parent._childTail = prevGroup;
    } else {
      nextGroup._prev = prevGroup;
    }

    _parent = null;
    _prev = null;
    _next = null;
  }

  /// Called when setting up a watch to watch a constant
  Record addConstantRecord(String expression, value) {
    Record record = new Record.constant(this, expression, value);
    _addRecord(record);
    return record;
  }

  /// Called when setting up a watch to watch a field
  Record addFieldRecord(AST lhs, String name, String expression) {
    Record lhsRecord = _getRecordFor(lhs);
    _watchedFields++;
    Record fieldRecord = new Record.field(this, expression, name);
    _addRecord(fieldRecord);
    lhsRecord._addListener(fieldRecord);
    return fieldRecord;
  }

  /// Called when setting up a watch to watch a collection (`Map` or `Iterable`)
  Record addCollectionRecord(CollectionAST ast) {
    Record valueRecord = _getRecordFor(ast.valueAST);
    _watchedCollections++;
    Record fieldRecord = new Record.collection(this, ast.expression);
    _addRecord(fieldRecord);
    valueRecord._addListener(fieldRecord);

    return fieldRecord;
  }

  /// Called when setting up a watch to watch a function
  Record addFunctionRecord(Function fn, List<AST> argsAST, Map<Symbol, AST> namedArgsAST,
                           String expression, bool isPure) =>
      _addEvalRecord(null, fn, null, argsAST, namedArgsAST, expression, isPure);

  /// Called when setting up a watch to watch a method
  Record addMethodRecord(AST lhs, String name, List<AST> argsAST, Map<Symbol, AST> namedArgsAST,
                         String expression) =>
      _addEvalRecord(lhs, null, name, argsAST, namedArgsAST, expression, false);

  Record _addEvalRecord(AST lhs, Function fn, String name, List<AST> argsAST,
                        Map<Symbol, AST> namedArgsAST, String expression, bool isPure) {
    _watchedEvals++;
    Record evalRecord = new Record.eval(this, expression, fn, name, argsAST.length, isPure);

    var argsListeners = [];

    // Trigger an evaluation of the eval when a positional parameter changes
    for (var i = 0; i < argsAST.length; i++) {
      var ast = argsAST[i];
      Record record = _getRecordFor(ast);
      var listener = new PositionalArgumentListener(evalRecord, i);
      record._addListener(listener);
      argsListeners.add(listener);
    }

    // Trigger an evaluation of the eval when a named parameter changes
    if (namedArgsAST.isNotEmpty) {
      evalRecord._namedArgs = new HashMap();
      namedArgsAST.forEach((Symbol symbol, AST ast) {
        evalRecord._namedArgs[symbol] = null;
        Record record = _getRecordFor(ast);
        var listener = new NamedArgumentListener(evalRecord, symbol);
        record._addListener(listener);
        argsListeners.add(listener);
      });
    }

    if (lhs != null) {
      var lhsRecord = _getRecordFor(lhs);
      _addRecord(evalRecord);
      lhsRecord._addListener(evalRecord);
    } else {
      _addRecord(evalRecord);
    }

    // Release the arguments listeners when the eval listener is released
    if (argsListeners.isNotEmpty) {
      evalRecord._releaseFn = (_) {
        for (ChangeListener listener in argsListeners) {
          listener.remove();
        }
      };
    }

    return evalRecord;
  }

  void _addRecord(Record record) {
    // Insert the record right before the tail
    record._prev = _tailMarker._prev;
    record._prev._next = record;
    record._next = _tailMarker;
    _tailMarker._prev = record;
    // Add the record to the check queue
    // Records must be checked at least when they are added then they might be removed from the
    // check queue ie if they use notification.
    record._moveToCheckQueue();
  }

  /// Get the record for the given [AST] from the cache. Add it on miss.
  Record _getRecordFor(AST ast) {
    String expression = ast.expression;
    Record record = _recordCache[expression];
    // We can only share records for collection when they have not yet fired. After they have first
    // fired the underlying `CollectionChangeRecord` or `MapChangeRecord` is initialized and can
    // not be re-used.
    // TODO: should the following be optimized - see once Proto has been implemented
    // Because a collection can be embedded in any AST (ie `|stringify(#collection(foo))`) it is not
    // possible to re-use the record if it has already fired as the collection changes would not be
    // detected properly. The current implementation only re-use the record when it has not fired
    // yet (which is not optimal if the AST does not contain a collection).
    if (record == null || record._hasFired) {
      record = ast.setupRecord(this);
      _recordCache[expression] = record;
    }
    return record;
  }

  /// Returns the tail marker for the last child group
  Record get _tailMarkerIncludingChildren {
    var lastChild = this;
    while (lastChild._childTail != null) {
      lastChild = lastChild._childTail;
    }
    return lastChild._tailMarker;
  }
}

class Watch extends ChangeListener {
  Function _reactionFn;

  Watch(Record triggerRecord, this._reactionFn) {
    triggerRecord._addListener(this);
  }

  String get expression => _triggerRecord._expression;

  /// Calls the [_reactionFn] when the observed [Record] value changes
  void _onChange(value, previous) {
    assert(_triggerRecord._watchGroup.isAttached);
    super._onChange(value, previous);
    _reactionFn(value, previous);
  }

  /// Removes this watch from its [WacthGroup]
  void remove() {
    if (_triggerRecord == null) throw "Already deleted!";
    super.remove();
  }
}

/// [ChangeListener] listens on [Record] changes
abstract class ChangeListener {
  Record _triggerRecord;
  ChangeListener _listenerNext;
  // We need to keep track of the listener who have not fired yet to fire them on the first
  // cycle after they have been added
  bool _hasFired = false;

  /// De-registers this change listener
  /// Calling [remove] might result in [Record]s being removed when they were only used by the
  /// current listener.
  void remove() {
    if (_triggerRecord != null) {
      // The [WatchGroup] has been detached, no need to remove individual [Record] / [Watch]
      if (!_triggerRecord._watchGroup.isAttached) return;
      if (identical(_triggerRecord._listenerHead, this)) {
        _triggerRecord._listenerHead = _listenerNext;
        if (_triggerRecord._listenerHead == null) {
          // The trigger record does not trigger any listeners any more, remove it
          _triggerRecord.remove();
        }
      } else {
        ChangeListener currentListener = _triggerRecord._listenerHead;
        while (!identical(currentListener._listenerNext, this)) {
          currentListener = currentListener._listenerNext;
          assert(currentListener != null);
        }
        // Unlink the listener (either a [Record] or a [Watch])
        currentListener._listenerNext = _listenerNext;
      }
      _triggerRecord = null;
      _listenerNext = null;
    }
  }

  /// Called when the [_triggerRecord] value changes
  void _onChange(value, previous) {
    _hasFired = true;
  }
}

/// A `PositionalArgumentListener` is created for each of the function positional argument.
/// Its role is to forward the value when it is changed and mark the arguments as dirty
class PositionalArgumentListener extends ChangeListener {
  Record _record;
  int _index;

  PositionalArgumentListener(this._record, this._index) {
    assert(_index < _record._args.length);
  }

  void _onChange(value, previous) {
    super._onChange(value, previous);
    _record._args[_index] = value;
    _record.areArgsDirty = true;
  }
}

/// A `NamedArgumentListener` is created for each of the function named argument.
/// Its role is to forward the value when it is changed and mark the arguments as dirty
class NamedArgumentListener extends ChangeListener {
  Record _record;
  Symbol _symbol;

  NamedArgumentListener(this._record, this._symbol) {
    assert(_record._namedArgs.containsKey(_symbol));
  }

  void _onChange(value, previous) {
    super._onChange(value, previous);
    _record._namedArgs[_symbol] = value;
    _record.areArgsDirty = true;
  }
}

class Record extends ChangeListener {
  // flags
  static const int _FLAG_IS_MARKER                = 0x001000;
  static const int _FLAG_IS_COLLECTION            = 0x002000;
  static const int _FLAG_IS_CONSTANT              = 0x004000;
  static const int _FLAG_HAS_FRESH_LISTENER       = 0x010000;
  static const int _FLAG_REMOVE_FROM_CHECK_QUEUE  = 0x020000;
  static const int _FLAG_HAS_DIRTY_ARGS           = 0x040000;

  // modes
  static const int _MASK_MODE = 0x000fff;

  static const int _FLAG_MODE_FIELD               = 0x000100;
  static const int _FLAG_MODE_EVAL                = 0x000200;
  static const int _MODE_NULL_FIELD               = 0x000000 | _FLAG_MODE_FIELD;
  static const int _MODE_IDENTITY                 = 0x000001 | _FLAG_MODE_FIELD;
  static const int _MODE_GETTER                   = 0x000002 | _FLAG_MODE_FIELD;
  static const int _MODE_GETTER_OR_METHOD_CLOSURE = 0x000003 | _FLAG_MODE_FIELD;
  static const int _MODE_MAP_FIELD                = 0x000004 | _FLAG_MODE_FIELD;
  static const int _MODE_ITERABLE                 = 0x000005 | _FLAG_MODE_FIELD;
  static const int _MODE_MAP                      = 0x000006 | _FLAG_MODE_FIELD;
  static const int _MODE_NULL_EVAL                = 0x000000 | _FLAG_MODE_EVAL;
  static const int _MODE_PURE_FUNCTION            = 0x000001 | _FLAG_MODE_EVAL;
  static const int _MODE_FUNCTION                 = 0x000002 | _FLAG_MODE_EVAL;
  static const int _MODE_PURE_FUNCTION_APPLY      = 0x000003 | _FLAG_MODE_EVAL;
  static const int _MODE_FIELD_OR_METHOD_CLOSURE  = 0x000004 | _FLAG_MODE_EVAL;
  static const int _MODE_METHOD                   = 0x000005 | _FLAG_MODE_EVAL;
  static const int _MODE_FIELD_CLOSURE            = 0x000006 | _FLAG_MODE_EVAL;
  static const int _MODE_MAP_CLOSURE              = 0x000007 | _FLAG_MODE_EVAL;

  Function _fnOrGetter;
  String _name;

  final List _args;
  Map<Symbol, dynamic> _namedArgs;

  /// The "_$" prefix denotes fields that should be accessed through getters / setters from outside
  /// this class
  Function _$releaseFn;
  int _$mode = 0;

  WatchGroup _watchGroup;

  // List of all the records in the system
  Record _next, _prev;

  // List of record that need to be dirty-checked
  Record _checkNext, _checkPrev;

  // List of records that need to be released
  Record _releasableNext;

  // List of dependent ChangeListeners
  ChangeListener _listenerHead;

  // Context for evaluation
  var _context;

  // The associated expression
  String _expression;

  // The value observed during the last `processChange` call
  var _value;

  // Whether listeners have been added since the [_processChange] last return.
  // When this is the case, we must ensure that the added listeners are triggered even if no changes
  // are detected as they must always fire in the [_processChange] cycle following their addition.
  bool get _hasFreshListener => _$mode & _FLAG_HAS_FRESH_LISTENER != 0;

  void set _hasFreshListener(bool fresh) {
    if (fresh) {
      _$mode |= _FLAG_HAS_FRESH_LISTENER;
      if (fresh && !isChecked) _moveToCheckQueue();
    } else {
      _$mode &= ~_FLAG_HAS_FRESH_LISTENER;
    }
  }

  /// Whether this record is dirty checked (when not, changes are notified)
  bool get isChecked => _checkNext != null;

  bool get isMarker => _$mode & _FLAG_IS_MARKER != 0;

  bool get isCollectionMode => _$mode & _FLAG_IS_COLLECTION != 0;
  bool get isEvalMode => _$mode & _FLAG_MODE_EVAL != 0;
  bool get isFieldMode => _$mode & _FLAG_MODE_FIELD  != 0;
  bool get isConstant => _$mode & _FLAG_IS_CONSTANT != 0;
  bool get isRelesable => _releasableNext != null;

  bool get areArgsDirty {
    assert(isEvalMode);
    return _$mode & _FLAG_HAS_DIRTY_ARGS != 0;
  }

  void set areArgsDirty(bool dirty) {
    assert(isEvalMode);
    if (dirty) {
      _$mode |= _FLAG_HAS_DIRTY_ARGS;
    } else {
      _$mode &= ~_FLAG_HAS_DIRTY_ARGS;
    }
  }

  int get _mode => _$mode & _MASK_MODE;

  void set _mode(mode) {
    assert(mode & ~_MASK_MODE == 0);
    _$mode = _$mode & ~_MASK_MODE | mode;
  }

  /// Mark the record to be removed from the check queue
  void set removeFromCheckQueue(remove) {
    if (remove) {
      _$mode |= _FLAG_REMOVE_FROM_CHECK_QUEUE;
    } else {
      _$mode &= ~_FLAG_REMOVE_FROM_CHECK_QUEUE;
    }
  }

  bool get removeFromCheckQueue => _$mode & _FLAG_REMOVE_FROM_CHECK_QUEUE != 0;

  // Release the resources associated with the record
  void set _releaseFn(Function releaseFn) {
    assert(releaseFn != null);
    _$releaseFn = releaseFn;
    _releasableNext = _watchGroup._headMarker._releasableNext;
    _watchGroup._headMarker._releasableNext = this;
  }

  FieldGetterFactory get _fieldGetterFactory => _watchGroup._fieldGetterFactory;

  Record._marker(this._watchGroup)
    : _args = null
  {
    assert((_expression = 'marker') != null);
    _$mode |= _FLAG_IS_MARKER;
  }

  Record.field(this._watchGroup, this._expression, this._name)
      : _args = null
  {
    _$mode = _FLAG_MODE_FIELD;
  }

  Record.collection(this._watchGroup, this._expression)
      : _args = null
  {
    _$mode = _FLAG_MODE_FIELD;
  }

  Record.eval(this._watchGroup, this._expression, this._fnOrGetter, this._name, int arity,
              bool pure)
    : _args = new List(arity)
  {
    if (_fnOrGetter is FunctionApply) {
      if (!pure) throw "Cannot watch a non-pure FunctionApply '$_expression'";
      _mode = _MODE_PURE_FUNCTION_APPLY;
    } else if (_fnOrGetter is Function) {
      _mode = pure ? _MODE_PURE_FUNCTION : _MODE_FUNCTION;
    } else {
      _mode = _MODE_NULL_EVAL;
    }
  }

  Record.constant(this._watchGroup, this._expression, value)
      : _args = null
  {
    _value = value;
    _$mode = _FLAG_IS_CONSTANT;
  }

  /**
   * Setting an [object] will cause the setter to introspect it and place
   * [DirtyCheckingRecord] into different access modes. If Object it sets up
   * reflection. If [Map] then it sets up map accessor.
   */
  void set context(context) {
    assert(!isConstant);
    _context = context;

    if (isFieldMode) {
      _setFieldContext(context);
    } else {
      assert(isEvalMode);
      _setEvalContext(context);
    }
  }

  void release() {
    assert(isMarker || _$releaseFn != null);
    if (!isMarker) _$releaseFn(this);
  }

  void _onChange(currentValue, previousValue) {
    super._onChange(currentValue, previousValue);
    context = currentValue;
  }

  void remove() {
    assert(_watchGroup.isAttached);

    // Update watch counters
    if (isCollectionMode) {
      assert(!isConstant);
      _watchGroup._watchedCollections--;
    } else if (isFieldMode) {
      assert(!isConstant);
      _watchGroup._watchedFields--;
    } else if (isEvalMode) {
      assert(!isConstant);
      _watchGroup._watchedEvals--;
    }

    _watchGroup._recordCache.remove(_expression);

    // Release associated resources when any
    if (_$releaseFn != null) {
      release();
      // Unlink the record from the releasable list
      var previousReleasable = _watchGroup._headMarker;
      while (!identical(previousReleasable._releasableNext,this)) {
        assert(previousReleasable._releasableNext != _watchGroup._tailMarker);
        previousReleasable = previousReleasable._releasableNext;
      }
      previousReleasable._releasableNext = _releasableNext;
    }

    // Unlink the record from the checkable list
    if (isChecked) $removeFromCheckQueue();

    // Assert that no more watches are triggered by this record
    assert(_listenerHead == null);

    // Unlink the record from the record list
    var prevRecord = _prev;
    var nextRecord = _next;
    prevRecord._next = nextRecord;
    nextRecord._prev = prevRecord;

    super.remove();
  }

  /// Returns the number of invoked reaction function
  int processChange({ChangeLog changeLog}) {
    if (isMarker) return 0;
    assert(_mode != null);

    if (isConstant) {
       // Constant records should only get checked when they are added or when listeners are added
       // then they must be removed from the check queue as they can not change.
       assert(!_hasFired || _hasFreshListener);
       int rfnCount = _notifyFreshListeners(changeLog, _value);
       removeFromCheckQueue = true;
       return rfnCount;
    }

    _hasFired = true;

    if (isFieldMode) {
      return _processFieldChange(changeLog: changeLog);
    } else {
      assert(isEvalMode);
      return _processEvalChange(changeLog: changeLog);
    }
  }

  String toString() {
    var asString;
    if (isMarker) {
      asString = '${_watchGroup._headMarker == this ? 'head' : 'tail'} marker';
    } else {
      var attrs = [];
      if (isFieldMode) attrs.add('type=field');
      if (isEvalMode) attrs.add('type=eval');
      if (isConstant) attrs.add('type=constant');
      if (isCollectionMode) attrs.add('collection');
      if (_hasFreshListener) attrs.add('has fresh listeners');
      if (_hasFired) attrs.add('has fired');
      if (isChecked) attrs.add('is Checked');
      attrs.add('mode=$_mode');
      asString = attrs.join(', ');
    }
    return "Record '$_expression' [$asString]";
  }

  void _setFieldContext(context) {
    _$mode &= ~_FLAG_IS_COLLECTION;

    if (context == null) {
      _mode = _MODE_IDENTITY;
      _fnOrGetter = null;
      return;
    }

    if (_name == null) {
      _fnOrGetter = null;
      if (context is Map) {
        _$mode |= _FLAG_IS_COLLECTION;
        if (_mode != _MODE_MAP) {
          _mode =  _MODE_MAP;
          _value = new MapChangeRecord();
        }
      } else if (context is Iterable) {
        _$mode |= _FLAG_IS_COLLECTION;
        if (_mode != _MODE_ITERABLE) {
          _mode = _MODE_ITERABLE;
          _value = new CollectionChangeRecord();
        }
      } else {
        _mode = _MODE_IDENTITY;
      }

      return;
    }

    if (context is Map) {
      _mode =  _MODE_MAP_FIELD;
      _fnOrGetter = null;
    } else {
      _mode = _MODE_GETTER_OR_METHOD_CLOSURE;
      _fnOrGetter = _fieldGetterFactory.getter(context, _name);
    }
  }

  void _setEvalContext(context) {
    assert(_mode != _MODE_FUNCTION);
    assert(_mode != _MODE_PURE_FUNCTION);
    assert(_mode != _MODE_PURE_FUNCTION_APPLY);
    _context = context;

    if (context == null) {
      _mode = _MODE_NULL_EVAL;
    } else {
      if (context is Map) {
        _mode =  _MODE_MAP_CLOSURE;
      } else {
        _mode = _MODE_FIELD_OR_METHOD_CLOSURE;
        _fnOrGetter = _fieldGetterFactory.getter(context, _name);
      }
    }
  }

  int _processFieldChange({ChangeLog changeLog}) {
    var value;
    switch (_mode) {
      case _MODE_NULL_FIELD:
        return 0;
      case _MODE_GETTER:
        value = _fnOrGetter(_context);
        break;
      case _MODE_GETTER_OR_METHOD_CLOSURE:
        // NOTE: When Dart looks up a method "foo" on object "x", it returns a
        // new closure for each lookup.  They compare equal via "==" but are no
        // identical().  There's no point getting a new value each time and
        // decide it's the same so we'll skip further checking after the first
        // time.
        value = _fnOrGetter(_context);
        if (value is Function && !identical(value, _fnOrGetter(_context))) {
          _mode = _MODE_NULL_FIELD;
        } else {
          _mode = _MODE_GETTER;
        }
        break;
      case _MODE_MAP_FIELD:
        value = _context[_name];
        break;
      case _MODE_IDENTITY:
        value = _context;
        _mode = _MODE_NULL_FIELD;
        break;
      case _MODE_MAP:
        return (_value as MapChangeRecord)._check(_context) ?
            _notifyListeners(changeLog, _value, null):
            _notifyFreshListeners(changeLog, _value);
      case _MODE_ITERABLE:
        return (_value as CollectionChangeRecord)._check(_context) ?
            _notifyListeners(changeLog, _value, null):
            _notifyFreshListeners(changeLog, _value);
      default:
        assert(false);
    }

    if (!_looseIdentical(value, _value)) {
      var previousValue = _value;
      _value = value;
      return _notifyListeners(changeLog, value, previousValue);
    } else {
      return _notifyFreshListeners(changeLog, value);
    }
    return 0;
  }

  int _processEvalChange({ChangeLog changeLog}) {
    var value;
    switch (_mode) {
      case _MODE_NULL_EVAL:
        return 0;
      case _MODE_PURE_FUNCTION:
        if (!areArgsDirty) return 0;
        value = Function.apply(_fnOrGetter, _args, _namedArgs);
        areArgsDirty = false;
        break;
      case _MODE_FUNCTION:
      case _MODE_METHOD:
        value = Function.apply(_fnOrGetter, _args, _namedArgs);
        areArgsDirty = false;
        break;
      case _MODE_PURE_FUNCTION_APPLY:
        if (!areArgsDirty) return 0;
        value = (_fnOrGetter as FunctionApply).apply(_args);
        areArgsDirty = false;
        break;
      case _MODE_FIELD_OR_METHOD_CLOSURE:
        var closure = _fnOrGetter(_context);
        // NOTE: When Dart looks up a method "foo" on object "x", it returns a
        // new closure for each lookup.  They compare equal via "==" but are no
        // identical().  There's no point getting a new value each time and
        // decide it's the same so we'll skip further checking after the first
        // time.
        if (closure is Function && !identical(closure, _fnOrGetter(_context))) {
          _fnOrGetter = closure;
          _mode = _MODE_METHOD;
        } else {
          _mode = _MODE_FIELD_CLOSURE;
        }
        value = (closure == null) ? null : Function.apply(closure, _args, _namedArgs);
        break;
      case _MODE_FIELD_CLOSURE:
        var closure = _fnOrGetter(_context);
        value = (closure == null) ? null : Function.apply(closure, _args, _namedArgs);
        break;
      case _MODE_MAP_CLOSURE:
        var closure = _context[_name];
        value = (closure == null) ? null : Function.apply(closure, _args, _namedArgs);
        break;
      default:
        throw ("$_mode is not supported in FunctionRecord.check()");
    }

    if (!_looseIdentical(_value, value)) {
      var previousValue = _value;
      _value = value;
      return _notifyListeners(changeLog, value, previousValue);
    } else {
      return _notifyFreshListeners(changeLog, value);
    }
    return 0;
  }

  void $removeFromCheckQueue() {
    assert(_checkNext != null && _checkPrev != null);
    _checkPrev._checkNext = _checkNext;
    _checkNext._checkPrev = _checkPrev;
    _checkNext = null;
    _checkPrev = null;
  }

  void _moveToCheckQueue() {
    assert(!isChecked);
    Record prevCheckable = _prev;

    while (!prevCheckable.isChecked) {
      // Assert that we do not pass the watch group
      assert(prevCheckable != _watchGroup._headMarker._prev);
      prevCheckable = prevCheckable._prev;
    }

    _checkNext = prevCheckable._checkNext;
    _checkNext._checkPrev = this;
    _checkPrev = prevCheckable;
    _checkPrev._checkNext = this;
  }

  int _notifyListeners(ChangeLog changeLog, currentValue, previousValue) {
    int invokedWatches = 0;
    if (changeLog != null) changeLog(_expression, currentValue, previousValue);
    for (ChangeListener listener = _listenerHead;
         listener != null;
         listener = listener._listenerNext) {
      listener._onChange(currentValue, previousValue);
      if (listener is Watch) invokedWatches++;
    }
    _hasFreshListener = false;
    return invokedWatches;
  }

  /// Notify the listeners added after the last check and not fired yet
  int _notifyFreshListeners(ChangeLog changeLog, value) {
    int invokedWatches = 0;
    if (_hasFreshListener) {
      if (changeLog != null) changeLog(_expression, value, null);
      for (ChangeListener listener = _listenerHead;
           listener != null;
           listener = listener._listenerNext) {
        if (!listener._hasFired) {
          if (listener is Watch) invokedWatches++;
          listener._onChange(value, null);
        }
      }
      _hasFreshListener = false;
    }
    return invokedWatches;
  }

  void _addListener(ChangeListener listener) {
    assert(listener._triggerRecord == null);
    // Records must be present in the record list before a listener is added
    assert(listener is! Record ||
           listener._prev != null && listener._next != null);

    if (_listenerHead == null) {
      _listenerHead = listener;
    } else {
      ChangeListener changeListener = this._listenerHead;
      while (changeListener._listenerNext != null) {
        changeListener = changeListener._listenerNext;
      }
      changeListener._listenerNext = listener;
    }

    listener._triggerRecord = this;

    // Listeners must be processed in the same cycle when they are added from a reaction function
    // (ie `_watchGroup._processingChanges == true`) then the `Record` context must be
    // initialized. When a listener is added outside of a reaction function, we do not need to
    // initialize the context until the next cycle which is achieved by setting
    // `_hasFreshListener = true`
    if (_watchGroup._processingChanges) {
      if (listener is Record) listener.context = _value;
      // Setting the context is a no-op for constant records we need to set the fresh listeners
      // flag to true to make sure the listeners will be triggered
      if (isConstant) _hasFreshListener = true;
    } else {
      _hasFreshListener = true;
    }
  }
}
