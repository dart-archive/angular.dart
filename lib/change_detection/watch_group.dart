library angular.watch_group;

import 'package:angular/change_detection/change_detection.dart';

part 'linked_list.dart';
part 'ast.dart';

typedef ReactionFn(dynamic value, dynamic previousValue, dynamic object);

/**
 * [WatchGroup] is a logical grouping of a set of watches.
 */
class WatchGroup implements _EvalWatchList {
  final Object context;
  final ChangeDetector<_Handler> _changeDetector;
  final Map<String, WatchRecord<_Handler>> _cache
        = new Map<String, WatchRecord<_Handler>>();

  int get fieldCost => _fieldCost;
  int _fieldCost = 0;

  int get evalCost => _evalCost;
  int _evalCost = 0;

  Watch _dirtyWatchHead, _dirtyWatchTail;
  EvalWatchRecord _evalWatchHead, _evalWatchTail;

  WatchGroup(this._changeDetector, this.context);

  Watch watch(AST expression, ReactionFn reactionFn) {
    WatchRecord<_Handler> watchRecord =
        _cache.putIfAbsent(expression.expression, () => expression.setupWatch(this));
    return watchRecord.handler.addReactionFn(reactionFn);
  }

  detectChanges() {
    // Process the ChangeRecords from the change detector
    ChangeRecord<_Handler> changeRecord = _changeDetector.collectChanges();
    while (changeRecord != null) {
      changeRecord.handler.onChange(changeRecord);
      changeRecord = changeRecord.nextChange;
    }

    int count = 0;
    // Process our own function evalutations
    EvalWatchRecord evalRecord = _evalWatchHead;
    while (evalRecord != null) {
      if (evalRecord.check() != null) count++;
      evalRecord = evalRecord._nextEvalWatch;
    }

    // Because the handler can forward changes between each other synchronously
    // We need to call reaction functions asynchronously. This processes the asynchronous
    // reaction function queue.
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
    print('   Dirty: ${watch.expression} ${watch._dirty}');
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

  WatchRecord<_Handler> addFieldWatch(AST lhs, String name, String expression) {
    var fieldHandler = new _FieldHandler(this, expression);

    // Create a ChangeRecord for the current field and assign the change record to the handler.
    var watchRecord = _changeDetector.watch(null, name, fieldHandler);
    _fieldCost++;
    fieldHandler.watchRecord = watchRecord;

    WatchRecord<_Handler> lhsWR = _cache.putIfAbsent(lhs.expression, () => lhs.setupWatch(this));

    // We set a field forwarding handler on LHS. This will allow the change objects to propagate
    // to the current WatchRecord.
    lhsWR.handler.addForwardHandler(fieldHandler);

    // propagate the value from the LHS to here
    fieldHandler.forwardValue(lhsWR.currentValue);
    return watchRecord;
  }

  EvalWatchRecord addFunctionWatch(Function fn, List<AST> argsAST, String expression) {
    _InvokeHandler invokeHandler = new _InvokeHandler(this, expression);
    EvalWatchRecord evalWatchRecord = new EvalWatchRecord(this, fn, expression, invokeHandler, argsAST.length);
    _EvalWatchList._add(this, evalWatchRecord);
    _evalCost++;
    invokeHandler.watchRecord = evalWatchRecord;

    // Convert the args from AST to WatchRecords
    var i = 0;
    argsAST.
      map((ast) => _cache.putIfAbsent(ast.expression, () => ast.setupWatch(this))).
      forEach((WatchRecord<_Handler> record) {
        var argHandler = new _ArgHandler(this, evalWatchRecord, i++);
        _ArgHandlerList._add(invokeHandler, argHandler);
        record.handler.addForwardHandler(argHandler);
        argHandler.forwardValue(record.currentValue);
      });

    return evalWatchRecord;
  }
}

/**
 * [Watch] corresponds to an individual [watch] registration on the scope.
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
    print('  invoke: $expression');
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
 * This class processes changes from the change detector. The changes are forwarded
 * onto the next [_Handler] or queued up in case of reaction function.
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
 * Notice how the [_Handler]s coalesce their watching. Also notice that any changes detected
 * at one handler are propagated to the next handler.
 */
abstract class _Handler implements _LinkedList, _LinkedListItem, _WatchList {
  _Handler _head, _tail;
  _Handler _next, _previous;
  Watch _watchHead, _watchTail;

  final String expression;
  final WatchGroup scope;

  WatchRecord<_Handler> watchRecord;
  _Handler forwardingHandler;

  _Handler(this.scope, this.expression);

  Watch addReactionFn(ReactionFn reactionFn) {
    return scope._addDirtyWatch(_WatchList._add(this, new Watch(watchRecord, reactionFn)));
  }

  void addForwardHandler(_Handler forwardToHandler) {
    assert(forwardToHandler.forwardingHandler == null);
    _LinkedList._add(this, forwardToHandler);
    forwardToHandler.forwardingHandler = this;
  }

  void release() {
    if (_WatchList._isEmpty(this) && _LinkedList._isEmpty(this)) {
      // We can remove ourselves
      print(' removing: $expression');
      _releaseWatch();

      if (forwardingHandler != null) {
        // TODO(misko): why do we need this check?
        _LinkedList._remove(forwardingHandler, this);
        forwardingHandler.release();
      }
    }
  }

  _releaseWatch() {
    scope._changeDetector.remove(watchRecord);
    scope._fieldCost--;
  }
  forwardValue(dynamic object) => null;

  void onChange(ChangeRecord<_Handler> record) {
    // If we have reaction functions than queue them up for asynchronous processing.
    Watch watch = _watchHead;
    while(watch != null) {
      scope._addDirtyWatch(watch);
      watch = watch._nextWatch;
    }
    // If we have a delegateHandler then forward the new value to it.
    _Handler delegateHandler = _head;
    while (delegateHandler != null) {
      delegateHandler.forwardValue(record.currentValue);
      delegateHandler = delegateHandler._next;
    }
  }
}

class _NullHandler extends _Handler {
  _NullHandler(): super(null, null);
  release() => null;
}

class _FieldHandler extends _Handler {
  _FieldHandler(scope, expression): super(scope, expression);

  /**
   * This function forwards the watched object to the next [_Handler] synchronously.
   */
  forwardValue(dynamic object) {
    watchRecord.object = object;
    var changeRecord = watchRecord.check();
    if (changeRecord != null) onChange(changeRecord);
  }

}

class _ArgHandler extends _Handler {
  _ArgHandler _previousArgHandler, _nextArgHandler;

  // TODO(misko): Why do we override parent?
  final EvalWatchRecord watchRecord;
  final int index;

  _releaseWatch() => null;

  _ArgHandler(WatchGroup scope, this.watchRecord, int index):
      super(scope, 'arg[$index]'), index = index;

  forwardValue(dynamic object) => watchRecord.args[index] = object;
}

class _InvokeHandler extends _Handler implements _ArgHandlerList {
  _ArgHandler _argHandlerHead, _argHandlerTail;

  _InvokeHandler(scope, expression): super(scope, expression);

  release() {
    watchRecord.remove();
    _ArgHandler current = _argHandlerHead;
    while(current != null) {
      current.release();
      current = current._nextArgHandler;
    }
  }
}


/**
 * The name is a bit oxymoron, but it is essentially the NullObject pattern.
 *
 * This allows children to set a handler on this ChangeRecord and then let it write the initial
 * constant value to the forwarding ChangeRecord.
 */
class _ConstantWatchRecord extends WatchRecord<_Handler> {
  final currentValue;
  final _Handler handler = new _NullHandler();

  _ConstantWatchRecord(this.currentValue);

  ChangeRecord<_Handler> check() => null;
  void remove() => null;

  get field => null;
  get previousValue => null;
  get object => null;
  set object(_) => null;
  get nextChange => null;
}


class EvalWatchRecord implements WatchRecord<_Handler>, ChangeRecord<_Handler> {
  final Function fn;
  final String name;
  final _Handler handler;
  final List args;
  final WatchGroup scope;

  dynamic currentValue;
  dynamic previousValue;
  dynamic object;
  bool deleted = false;

  EvalWatchRecord _previousEvalWatch, _nextEvalWatch;

  EvalWatchRecord(this.scope, this.fn, this.name, this.handler, int arity): args = new List(arity);

  ChangeRecord<_Handler> check() {
    var value = Function.apply(fn, args);
    print('eval: $name(${args.join(', ')}) => $value');
    var currentValue = this.currentValue;
    if (!identical(currentValue, value)) {
      if (value is String && currentValue is String && value == currentValue) {
        // it is really the same, recover
        currentValue = value; // same so next time identity is same
      } else {
        previousValue = currentValue;
        this.currentValue = value;
        print(handler);
        handler.onChange(this);
        return this;
      }
    }
    return null;
  }

  get field => '()';
  get nextChange => null;

  remove() {
    assert(!deleted);
    deleted = true;
    scope._evalCost--;
    _EvalWatchList._remove(scope, this);
  }
}
