library angular.watch_group;

import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';

part 'linked_list.dart';
part 'ast.dart';
part 'prototype_map.dart';

typedef ReactionFn(value, previousValue, object);

/**
 * Extend this class if you wish to pretend to be a function, but you don't know
 * number of arguments with which the function will get called.
 */
abstract class FunctionApply {
  // dartbug.com/16401
  // dynamic call() { throw new StateError('Use apply()'); }
  dynamic apply(List arguments);
}

/**
 * [WatchGroup] is a logical grouping of a set of watches. [WatchGroup]s are
 * organized into a hierarchical tree parent-children configuration.
 * [WatchGroup] builds upon [ChangeDetector] and adds expression (field chains
 * as in `a.b.c`) support as well as support function/closure/method (function
 * invocation as in `a.b()`) watching.
 */
class WatchGroup implements _EvalWatchList, _WatchGroupList {
  /** A unique ID for the WatchGroup */
  final String id;
  /**
   * A marker to be inserted when a group has no watches. We need the marker to
   * hold our position information in the linked list of all [Watch]es.
   */
  final _EvalWatchRecord _marker = new _EvalWatchRecord.marker();

  /** All Expressions are evaluated against a context object. */
  final Object context;

  /** [ChangeDetector] used for field watching */
  final ChangeDetectorGroup<_Handler> _changeDetector;
  /** A cache for sharing sub expression watching. Watching `a` and `a.b` will
  * watch `a` only once. */
  final Map<String, WatchRecord<_Handler>> _cache;
  final RootWatchGroup _rootGroup;

  /// STATS: Number of field watchers which are in use.
  int _fieldCost = 0;
  int _collectionCost = 0;

  /// STATS: Number of field watchers which are in use including child [WatchGroup]s.
  int get fieldCost => _fieldCost;
  int get totalFieldCost {
    var cost = _fieldCost;
    WatchGroup group = _watchGroupHead;
    while(group != null) {
      cost += group.totalFieldCost;
      group = group._nextWatchGroup;
    }
    return cost;
  }

  /// STATS: Number of collection watchers which are in use including child [WatchGroup]s.
  int get collectionCost => _collectionCost;
  int get totalCollectionCost {
    var cost = _collectionCost;
    WatchGroup group = _watchGroupHead;
    while(group != null) {
      cost += group.totalCollectionCost;
      group = group._nextWatchGroup;
    }
    return cost;
  }

  /// STATS: Number of invocation watchers (closures/methods) which are in use.
  int get evalCost => _evalCost;
  int _evalCost = 0;

  /// STATS: Number of invocation watchers which are in use including child [WatchGroup]s.
  int get totalEvalCost {
    var cost = _evalCost;
    WatchGroup group = _watchGroupHead;
    while(group != null) {
      cost += group.evalCost;
      group = group._nextWatchGroup;
    }
    return cost;
  }

  int _nextChildId = 0;
  _EvalWatchRecord _evalWatchHead, _evalWatchTail;
  /// Pointer for creating tree of [WatchGroup]s.
  WatchGroup _watchGroupHead, _watchGroupTail, _previousWatchGroup,
      _nextWatchGroup;
  final WatchGroup _parentWatchGroup;

  WatchGroup._child(_parentWatchGroup, this._changeDetector,
                    this.context, this._cache, this._rootGroup)
      : _parentWatchGroup = _parentWatchGroup,
        id = '${_parentWatchGroup.id}.${_parentWatchGroup._nextChildId++}'
  {
    _marker.watchGrp = this;
    _evalWatchTail = _evalWatchHead = _marker;
  }

  WatchGroup._root(this._changeDetector, this.context)
      : id = '',
        _rootGroup = null,
        _parentWatchGroup = null,
        _cache = new Map<String, WatchRecord<_Handler>>()
  {
    _marker.watchGrp = this;
    _evalWatchTail = _evalWatchHead = _marker;
  }

  Watch watch(AST expression, ReactionFn reactionFn) {
    WatchRecord<_Handler> watchRecord =
        _cache.putIfAbsent(expression.expression,
            () => expression.setupWatch(this));
    return watchRecord.handler.addReactionFn(reactionFn);
  }

  /**
   * Watch a [name] field on [lhs] represented by [expression].
   *
   * - [name] the field to watch.
   * - [lhs] left-hand-side of the field.
   */
  WatchRecord<_Handler> addFieldWatch(AST lhs, String name, String expression) {
    var fieldHandler = new _FieldHandler(this, expression);

    // Create a ChangeRecord for the current field and assign the change record
    // to the handler.
    var watchRecord = _changeDetector.watch(null, name, fieldHandler);
    _fieldCost++;
    fieldHandler.watchRecord = watchRecord;

    WatchRecord<_Handler> lhsWR = _cache.putIfAbsent(lhs.expression,
        () => lhs.setupWatch(this));

    // We set a field forwarding handler on LHS. This will allow the change
    // objects to propagate to the current WatchRecord.
    lhsWR.handler.addForwardHandler(fieldHandler);

    // propagate the value from the LHS to here
    fieldHandler.acceptValue(lhsWR.currentValue);
    return watchRecord;
  }

  WatchRecord<_Handler> addCollectionWatch(AST ast) {
    var collectionHandler = new _CollectionHandler(this, ast.expression);
    var watchRecord = _changeDetector.watch(null, null, collectionHandler);
    _collectionCost++;
    collectionHandler.watchRecord = watchRecord;
    WatchRecord<_Handler> astWR = _cache.putIfAbsent(ast.expression, () => ast.setupWatch(this));

    // We set a field forwarding handler on LHS. This will allow the change objects to propagate
    // to the current WatchRecord.
    astWR.handler.addForwardHandler(collectionHandler);

    // propagate the value from the LHS to here
    collectionHandler.acceptValue(astWR.currentValue);
    return watchRecord;
  }

  /**
   * Watch a [fn] function represented by an [expression].
   *
   * - [fn] function to evaluate.
   * - [argsAST] list of [AST]es which represent arguments passed to function.
   * - [expression] normalized expression used for caching.
   */
  _EvalWatchRecord addFunctionWatch(/* dartbug.com/16401 Function */ fn, List<AST> argsAST,
                                    String expression) =>
      _addEvalWatch(null, fn, null, argsAST, expression);

  /**
   * Watch a method [name]ed represented by an [expression].
   *
   * - [lhs] left-hand-side of the method.
   * - [name] name of the method.
   * - [argsAST] list of [AST]es which represent arguments passed to method.
   * - [expression] normalized expression used for caching.
   */
  _EvalWatchRecord addMethodWatch(AST lhs, String name, List<AST> argsAST,
                                  String expression) =>
      _addEvalWatch(lhs, null, name, argsAST, expression);



  _EvalWatchRecord _addEvalWatch(AST lhsAST, /* dartbug.com/16401 Function */ fn, String name,
                                 List<AST> argsAST, String expression) {
    _InvokeHandler invokeHandler = new _InvokeHandler(this, expression);
    var evalWatchRecord = new _EvalWatchRecord(this, invokeHandler, fn, name,
        argsAST.length);
    invokeHandler.watchRecord = evalWatchRecord;

    if (lhsAST != null) {
      var lhsWR = _cache.putIfAbsent(lhsAST.expression,
          () => lhsAST.setupWatch(this));
      lhsWR.handler.addForwardHandler(invokeHandler);
      invokeHandler.acceptValue(lhsWR.currentValue);
    }

    // Convert the args from AST to WatchRecords
    var i = 0;
    argsAST.
    map((ast) => _cache.putIfAbsent(ast.expression,
        () => ast.setupWatch(this))).forEach((WatchRecord<_Handler> record) {
      var argHandler = new _ArgHandler(this, evalWatchRecord, i++);
      _ArgHandlerList._add(invokeHandler, argHandler);
      record.handler.addForwardHandler(argHandler);
      argHandler.acceptValue(record.currentValue);
    });

    // Must be done last
    _EvalWatchList._add(this, evalWatchRecord);
    _evalCost++;

    return evalWatchRecord;
  }

  WatchGroup get _childWatchGroupTail {
    WatchGroup tail = this;
    WatchGroup nextTail;
    while ((nextTail = tail._watchGroupTail) != null) {
      tail = nextTail;
    }
    return tail;
  }

  /**
   * Create a new child [WatchGroup].
   *
   * - [context] if present the the child [WatchGroup] expressions will evaluate
   * against the new [context]. If not present than child expressions will
   * evaluate on same context allowing the reuse of the expression cache.
   */
  WatchGroup newGroup([Object context]) {
    _EvalWatchRecord prev = _childWatchGroupTail._evalWatchTail;
    _EvalWatchRecord next = prev._nextEvalWatch;
    var childGroup = new WatchGroup._child(
        this,
        _changeDetector.newGroup(),
        context == null ? this.context : context,
        context == null ? this._cache: new Map<String, WatchRecord<_Handler>>(),
        _rootGroup == null ? this : _rootGroup);
    _WatchGroupList._add(this, childGroup);
    var marker = childGroup._marker;

    marker._previousEvalWatch = prev;
    marker._nextEvalWatch = next;
    if (prev != null) prev._nextEvalWatch = marker;
    if (next != null) next._previousEvalWatch = marker;

    return childGroup;
  }

  /**
   * Remove/destroy [WatchGroup] and all of its [Watches].
   */
  void remove() {
    // TODO:(misko) This code is not right.
    // 1) It fails to release [ChangeDetector] [WatchRecord]s.
    // 2) it needs to cleanup caches if the cache is being shared.

    _WatchGroupList._remove(_parentWatchGroup, this);
    _changeDetector.remove();

    // Unlink the _watchRecord
    _EvalWatchRecord firstEvalWatch = _evalWatchHead;
    _EvalWatchRecord lastEvalWatch =
        (_watchGroupTail == null ? this : _watchGroupTail)._evalWatchTail;
    _EvalWatchRecord previous = firstEvalWatch._previousEvalWatch;
    _EvalWatchRecord next = lastEvalWatch._nextEvalWatch;
    if (previous != null) previous._nextEvalWatch = next;
    if (next != null) next._previousEvalWatch = previous;
  }

  toString() {
    var lines = [];
    if (this == _rootGroup) {
      var allWatches = [];
      var watch = _evalWatchHead;
      var prev = null;
      while (watch != null) {
        allWatches.add(watch.toString());
        assert(watch._previousEvalWatch == prev);
        prev = watch;
        watch = watch._nextEvalWatch;
      }
      lines.add('WATCHES: ${allWatches.join(', ')}');
    }

    var watches = [];
    var watch = _evalWatchHead;
    while (watch != _evalWatchTail) {
      watches.add(watch.toString());
      watch = watch._nextEvalWatch;
    }
    watches.add(watch.toString());

    lines.add('WatchGroup[$id](watches: ${watches.join(', ')})');
    var childGroup = _watchGroupHead;
    while (childGroup != null) {
      lines.add('  ' + childGroup.toString().split('\n').join('\n  '));
      childGroup = childGroup._nextWatchGroup;
    }
    return lines.join('\n');
  }
}

/**
 * [RootWatchGroup]
 */
class RootWatchGroup extends WatchGroup {
  Watch _dirtyWatchHead, _dirtyWatchTail;

  RootWatchGroup(ChangeDetector changeDetector, Object context):
      super._root(changeDetector, context);

  get _rootGroup => this;

  /**
   * Detect changes and process the [ReactionFn]s.
   *
   * Algorithm:
   * 1) process the [ChangeDetector#collectChanges].
   * 2) process function/closure/method changes
   * 3) call an [ReactionFn]s
   *
   * Each step is called in sequence. ([ReactionFn]s are not called until all previous steps are
   * completed).
   */
  int detectChanges() {
    // Process the ChangeRecords from the change detector
    ChangeRecord<_Handler> changeRecord =
        (_changeDetector as ChangeDetector<_Handler>).collectChanges();
    while (changeRecord != null) {
      changeRecord.handler.onChange(changeRecord);
      changeRecord = changeRecord.nextChange;
    }

    int count = 0;
    // Process our own function evaluations
    _EvalWatchRecord evalRecord = _evalWatchHead;
    while (evalRecord != null) {
      evalRecord.check();
      evalRecord = evalRecord._nextEvalWatch;
    }

    // Because the handler can forward changes between each other synchronously
    // We need to call reaction functions asynchronously. This processes the
    // asynchronous reaction function queue.
    Watch dirtyWatch = _dirtyWatchHead;
    while(dirtyWatch != null) {
      count++;
      dirtyWatch.invoke();
      dirtyWatch = dirtyWatch._nextDirtyWatch;
    }
    _dirtyWatchHead = _dirtyWatchTail = null;
    return count;
  }

  /**
   * Add Watch into the asynchronous queue for later processing.
   */
  Watch _addDirtyWatch(Watch watch) {
    if (!watch._dirty) {
      watch._dirty = true;
      if (_dirtyWatchTail == null) {
        _dirtyWatchHead = _dirtyWatchTail = watch;
      } else {
        _dirtyWatchTail._nextDirtyWatch = watch;
        _dirtyWatchTail = watch;
      }
      watch._nextDirtyWatch = null;
    }
    return watch;
  }
}

/**
 * [Watch] corresponds to an individual [watch] registration on the watchGrp.
 */
class Watch {
  Watch _previousWatch, _nextWatch;

  final Record<_Handler> _record;
  final ReactionFn reactionFn;

  bool _dirty = false;
  bool _deleted = false;
  Watch _nextDirtyWatch;

  Watch(this._record, this.reactionFn);

  get expression => _record.handler.expression;

  invoke() {
    _dirty = false;
    reactionFn(_record.currentValue, _record.previousValue, _record.object);
  }

  remove() {
    if (_deleted) throw new StateError('Already deleted!');
    _deleted = true;
    var handler = _record.handler;
    _WatchList._remove(handler, this);
    handler.release();
  }
}

/**
 * This class processes changes from the change detector. The changes are
 * forwarded onto the next [_Handler] or queued up in case of reaction function.
 *
 * Given these two expression: 'a.b.c' => rfn1 and 'a.b' => rfn2
 * The resulting data structure is:
 *
 * _Handler             +--> _Handler             +--> _Handler
 *   - delegateHandler -+      - delegateHandler -+      - delegateHandler = null
 *   - expression: 'a'         - expression: 'a.b'       - expression: 'a.b.c'
 *   - watchObject: context    - watchObject: context.a  - watchObject: context.a.b
 *   - watchRecord: 'a'        - watchRecord 'b'         - watchRecord 'c'
 *   - reactionFn: null        - reactionFn: rfn1        - reactionFn: rfn2
 *
 * Notice how the [_Handler]s coalesce their watching. Also notice that any
 * changes detected at one handler are propagated to the next handler.
 */
abstract class _Handler implements _LinkedList, _LinkedListItem, _WatchList {
  _Handler _head, _tail;
  _Handler _next, _previous;
  Watch _watchHead, _watchTail;

  final String expression;
  final WatchGroup watchGrp;

  WatchRecord<_Handler> watchRecord;
  _Handler forwardingHandler;

  _Handler(this.watchGrp, this.expression) {
    assert(watchGrp != null);
    assert(expression != null);
  }

  Watch addReactionFn(ReactionFn reactionFn) {
    assert(_next != this); // verify we are not detached
    return watchGrp._rootGroup._addDirtyWatch(_WatchList._add(this,
        new Watch(watchRecord, reactionFn)));
  }

  void addForwardHandler(_Handler forwardToHandler) {
    assert(forwardToHandler.forwardingHandler == null);
    _LinkedList._add(this, forwardToHandler);
    forwardToHandler.forwardingHandler = this;
  }

  void release() {
    if (_WatchList._isEmpty(this) && _LinkedList._isEmpty(this)) {
      _releaseWatch();
      // Remove ourselves from cache, or else new registrations will go to us,
      // but we are dead
      watchGrp._cache.remove(expression);

      if (forwardingHandler != null) {
        // TODO(misko): why do we need this check?
        _LinkedList._remove(forwardingHandler, this);
        forwardingHandler.release();
      }

      // We can remove ourselves
      assert((_next = _previous = this) == this); // mark ourselves as detached
    }
  }

  _releaseWatch() {
    watchRecord.remove();
    watchGrp._fieldCost--;
  }
  acceptValue(dynamic object) => null;

  void onChange(ChangeRecord<_Handler> record) {
    assert(_next != this); // verify we are not detached
    // If we have reaction functions than queue them up for asynchronous
    // processing.
    Watch watch = _watchHead;
    while(watch != null) {
      watchGrp._rootGroup._addDirtyWatch(watch);
      watch = watch._nextWatch;
    }
    // If we have a delegateHandler then forward the new value to it.
    _Handler delegateHandler = _head;
    while (delegateHandler != null) {
      delegateHandler.acceptValue(record.currentValue);
      delegateHandler = delegateHandler._next;
    }
  }
}

class _ConstantHandler extends _Handler {
  _ConstantHandler(WatchGroup watchGroup, String expression, dynamic constantValue)
      : super(watchGroup, expression)
  {
    watchRecord = new _EvalWatchRecord.constant(this, constantValue);
  }
  release() => null;
}

class _FieldHandler extends _Handler {
  _FieldHandler(watchGrp, expression): super(watchGrp, expression);

  /**
   * This function forwards the watched object to the next [_Handler]
   * synchronously.
   */
  acceptValue(dynamic object) {
    watchRecord.object = object;
    var changeRecord = watchRecord.check();
    if (changeRecord != null) onChange(changeRecord);
  }
}

class _CollectionHandler extends _Handler {
  _CollectionHandler(watchGrp, expression): super(watchGrp, expression);
  /**
   * This function forwards the watched object to the next [_Handler] synchronously.
   */
  acceptValue(dynamic object) {
    watchRecord.object = object;
    var changeRecord = watchRecord.check();
    if (changeRecord != null) onChange(changeRecord);
  }
  _releaseWatch() {
    watchRecord.remove();
    watchGrp._collectionCost--;
  }
}

class _ArgHandler extends _Handler {
  _ArgHandler _previousArgHandler, _nextArgHandler;

  // TODO(misko): Why do we override parent?
  final _EvalWatchRecord watchRecord;
  final int index;

  _releaseWatch() => null;

  _ArgHandler(WatchGroup watchGrp, this.watchRecord, int index)
      : super(watchGrp, 'arg[$index]'), index = index;

  acceptValue(dynamic object) {
    watchRecord.dirtyArgs = true;
    watchRecord.args[index] = object;
  }
}

class _InvokeHandler extends _Handler implements _ArgHandlerList {
  _ArgHandler _argHandlerHead, _argHandlerTail;

  _InvokeHandler(watchGrp, expression): super(watchGrp, expression);

  acceptValue(dynamic object) => watchRecord.object = object;

  _releaseWatch() => (watchRecord as _EvalWatchRecord).remove();

  release() {
    super.release();
    _ArgHandler current = _argHandlerHead;
    while(current != null) {
      current.release();
      current = current._nextArgHandler;
    }
  }
}


class _EvalWatchRecord implements WatchRecord<_Handler>, ChangeRecord<_Handler> {
  static const int _MODE_DELETED_        = -1;
  static const int _MODE_MARKER_         = 0;
  static const int _MODE_FUNCTION_       = 1;
  static const int _MODE_FUNCTION_APPLY_ = 2;
  static const int _MODE_NULL_           = 3;
  static const int _MODE_FIELD_CLOSURE_  = 4;
  static const int _MODE_MAP_CLOSURE_    = 5;
  static const int _MODE_METHOD_         = 6;
  WatchGroup watchGrp;
  final _Handler handler;
  final List args;
  final Symbol symbol;
  final String name;
  int mode;
  /* dartbug.com/16401 Function*/ var fn;
  InstanceMirror _instanceMirror;
  bool dirtyArgs = true;

  dynamic currentValue, previousValue, _object;
  _EvalWatchRecord _previousEvalWatch, _nextEvalWatch;

  _EvalWatchRecord(this.watchGrp, this.handler, this.fn, name, int arity)
      : args = new List(arity),
        name = name,
        symbol = name == null ? null : new Symbol(name)
  {
    if      (fn is FunctionApply) mode = _MODE_FUNCTION_APPLY_;
    else if (fn is Function)      mode = _MODE_FUNCTION_;
    else                          mode = _MODE_NULL_;
  }

  _EvalWatchRecord.marker()
      : mode = _MODE_MARKER_,
        watchGrp = null,
        handler = null,
        args = null,
        fn = null,
        symbol = null,
        name = null;

  _EvalWatchRecord.constant(_Handler handler, dynamic constantValue)
      : mode = _MODE_MARKER_,
        handler = handler,
        currentValue = constantValue,
        watchGrp = null,
        args = null,
        fn = null,
        symbol = null,
        name = null;

  get field => '()';

  get object => _object;

  set object(value) {
    assert(mode != _MODE_DELETED_);
    assert(mode != _MODE_MARKER_);
    assert(mode != _MODE_FUNCTION_);
    assert(mode != _MODE_FUNCTION_APPLY_);
    assert(symbol != null);
    _object = value;

    if (value == null) {
      mode = _MODE_NULL_;
    } else {
      if (value is Map) {
        mode =  _MODE_MAP_CLOSURE_;
      } else {
        _instanceMirror = reflect(value);
        if(_hasMethod(_instanceMirror.type, symbol)) {
          mode = _MODE_METHOD_;
        } else {
          mode = _MODE_FIELD_CLOSURE_;
        }
      }
    }
  }

  ChangeRecord<_Handler> check() {
    var value;
    switch (mode) {
      case _MODE_MARKER_:
      case _MODE_NULL_:
        return null;
      case _MODE_FUNCTION_:
        if (!dirtyArgs) return null;
        value = Function.apply(fn, args);
        dirtyArgs = false;
        break;
      case _MODE_FUNCTION_APPLY_:
        if (!dirtyArgs) return null;
        value = (fn as FunctionApply).apply(args);
        dirtyArgs = false;
        break;
      case _MODE_FIELD_CLOSURE_:
        var closure = _instanceMirror.getField(symbol).reflectee;
        value = closure == null ? null : Function.apply(closure, args);
        break;
      case _MODE_MAP_CLOSURE_:
        var closure = object[name];
        value = closure == null ? null : Function.apply(closure, args);
        break;
      case _MODE_METHOD_:
        value = _instanceMirror.invoke(symbol, args).reflectee;
        break;
      default:
        assert(false);
    }

    var current = currentValue;
    if (!identical(current, value)) {
      if (value is String && current is String && value == current) {
        // it is really the same, recover and save so next time identity is same
        current = value;
      } else {
        previousValue = current;
        currentValue = value;
        handler.onChange(this);
        return this;
      }
    }
    return null;
  }

  get nextChange => null;

  remove() {
    assert(mode != _MODE_DELETED_);
    assert((mode = _MODE_DELETED_) == _MODE_DELETED_); // Mark as deleted.
    watchGrp._evalCost--;
    _EvalWatchList._remove(watchGrp, this);
  }

  toString() {
    if (mode == _MODE_MARKER_) return 'MARKER[$currentValue]';
    return '${watchGrp.id}:${handler.expression}';
  }

  static final Function _hasMethod = (() {
    var objectClassMirror = reflectClass(Object);
    Set<Symbol> objectClassInstanceMethods =
        new Set<Symbol>.from([#toString, #noSuchMethod]);
    try {
      // Use ClassMirror.instanceMembers if available. It contains local
      // as well as inherited members.
      objectClassMirror.instanceMembers;
      // For SDK 1.2 we have to use a somewhat complicated helper for this
      // to work around bugs in the dart2js implementation.
      return (type, symbol) {
        // Always allow instance methods found in the Object class. This makes
        // it easier to work around a few bugs in the dart2js implementation.
        if (objectClassInstanceMethods.contains(symbol)) return true;
        // Work around http://dartbug.com/16309 which causes access to the
        // instance members of certain builtin types to throw exceptions
        // while traversing the superclass chain.
        var mirror;
        try {
          mirror = type.instanceMembers[symbol];
        } on UnsupportedError catch (e) {
          mirror = type.declarations[symbol];
        }
        // Work around http://dartbug.com/15760 which causes noSuchMethod
        // forwarding stubs to be treated as members of all classes. We have
        // already checked for the real instance methods in Object, so if the
        // owner of this method is Object we simply filter it out.
        if (mirror is !MethodMirror) return false;
        return mirror.owner != objectClassMirror;
      };
    } on NoSuchMethodError catch (e) {
      // For SDK 1.0 we fall back to just using the local members.
      return (type, symbol) => type.members[symbol] is MethodMirror;
    } on UnimplementedError catch (e) {
      // For SDK 1.1 we fall back to just using the local declarations.
      return (type, symbol) => type.declarations[symbol] is MethodMirror;
    }
    return null;
  })();

}
