library scope2;

import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

typedef ReactionFn(dynamic value, dynamic previousValue, dynamic object);

/**
 * [Scope2] is a logical grouping of a set of watches.
 *
 * []
 */
class Scope2 {
  final context;

  int _watchCost = 0;
  int _evalCost = 0;
  int get watchCost => _watchCost;
  int get evalCost => _evalCost;

  ChangeDetector<_Handler> _digestDetector = new DirtyCheckingChangeDetector<_Handler>();
  Map<String, WatchRecord<_Handler>> _expressionCache = new Map<String, WatchRecord<_Handler>>();
  Watch _dirtyWatchHead;
  Watch _dirtyWatchTail;

  EvalWatchRecord _evalWatchHead;
  EvalWatchRecord _evalWatchTail;

  Scope2(this.context);

  Watch watch(AST expression, ReactionFn reactionFn) {
    WatchRecord<_Handler> watchRecord =
        _expressionCache.putIfAbsent(expression.expression, () => expression.setupWatch(this, _expressionCache));
    return watchRecord.handler.addReactionFn(reactionFn);
  }

  digest() {
    // Process the ChangeRecords from the change detector
    ChangeRecord<_Handler> changeRecord = _digestDetector.collectChanges();
    while (changeRecord != null) {
      changeRecord.handler.call(changeRecord);
      changeRecord = changeRecord.nextChange;
    }

    EvalWatchRecord evalRecord = _evalWatchHead;
    while (evalRecord != null) {
      evalRecord.check();
      evalRecord = evalRecord.next;
    }

    // Because the handler can forward changes between each other synchronously
    // We need to call reaction functions asynchronously. This processes the asynchronous
    // reaction function queue.
    int count = 0;
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

  EvalWatchRecord _addEvalWatch(Function fn, String name, _Handler handler, int arity) {
    _evalCost++;
    var watch = new EvalWatchRecord(this, fn, name, handler, arity);

    if (_evalWatchTail == null) {
      _evalWatchHead = _evalWatchHead = watch;
    } else {
      _evalWatchTail.next = watch;
      watch.previous = _evalWatchTail;
      _evalWatchTail = watch;
    }

    return watch;
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
    _Watches._remove(handler, this);
    handler.gc();
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
class _Handler {
  _Handler _handlerHead, _handlerTail;
  _Handler _nextHandler, _previousHandler;
  Watch _watchHead, _watchTail;

  final String expression;
  final Scope2 scope;

  WatchRecord<_Handler> watchRecord;
  _Handler forwardingHandler;

  _Handler(this.expression, this.scope);

  Watch addReactionFn(ReactionFn reactionFn) {
    return scope._addDirtyWatch(_Watches._add(this, new Watch(watchRecord, reactionFn)));
  }

  void addForwardToHandler(_Handler forwardToHandler) {
    assert(forwardToHandler.forwardingHandler == null);
    _Handlers._add(this, forwardToHandler);
    forwardToHandler.forwardingHandler = this;
  }

  void gc() {
    // scope is null in the case of Context handler
    if (scope != null && _Watches._isEmpty(this) && _Handlers._isEmpty(this)) {
      // We can remove ourselves
      print(' removing: $expression');
      if (watchRecord is EvalWatchRecord) {
        //(watchRecord as EvalWatchRecord).remove();
      } else {
        scope._digestDetector.remove(watchRecord); // TODO: LOD violation
        scope._watchCost--;
      }

      if (forwardingHandler != null) {
        // TODO(misko): why do we need this check?
        _Handlers._remove(forwardingHandler, this);
        forwardingHandler.gc();
      }
    }
  }

  void receive(dynamic object) { assert(false); }

  void call(ChangeRecord<_Handler> record) {
    // A change has been detected.

    // If we have reaction functions than queue them up for asynchronous processing.
    Watch watch = _watchHead;
    while(watch != null) {
      scope._addDirtyWatch(watch);
      watch = watch._nextWatch;
    }
    // If we have a delegateHandler then forward the new object to it.
    _Handler delegateHandler = _handlerHead;
    while (delegateHandler != null) {
      delegateHandler.receive(record.currentValue);
      delegateHandler = delegateHandler._nextHandler;
    }
  }
}

class _FieldHandler extends _Handler {
  _FieldHandler(expression, scope): super(expression, scope);

  /**
   * This function forwards the watched object to the next [_Handler] synchronously.
   */
  void receive(dynamic object) {
    watchRecord.object = object;
    var changeRecord = watchRecord.check();
    if (changeRecord != null) call(changeRecord);
  }

}

class _ArgHandler extends _Handler {
  _ArgHandler _previousArgHandler, _nextArgHandler;

  final EvalWatchRecord watchRecord;
  final int index;

  _ArgHandler(_InvokeHandler invokeHandler, this.watchRecord, int index, Scope2 scope):
      super('arg[$index]', scope),
      index = index
  {
    invokeHandler.addArgumentHandler(this);
  }

  void receive(dynamic object) { watchRecord.args[index] = object; }
}

class _InvokeHandler extends _Handler {
  _ArgHandler _argHandlerHead, _argHandlerTail;

  _InvokeHandler(expression, scope): super(expression, scope);

  addArgumentHandler(_ArgHandler handler) => _ArgHandlers._add(this, handler);

  // receive is never called by _ArgHandler
  void receive(dynamic object) { assert(false); }

  gc() {
    watchRecord.remove();
    _ArgHandler current = _argHandlerHead;
    while(current != null) {
      current.gc();
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
class ConstantWatchRecord extends WatchRecord<_Handler> {
  final currentValue;
  final _Handler handler = new _Handler(null, null);

  ConstantWatchRecord(this.currentValue);

  ChangeRecord<_Handler> check() => null;
  void remove() => null;

  get field => null;
  get previousValue => null;
  get object => null;
  set object(_) => null;
  get nextChange => null;
}

/**
 * RULES:
 *  - ASTs are reusable. Don't store scope/instance refs there
 *  - Parent knows about children, not the other way around.
 */
abstract class AST {
  String get expression;
  WatchRecord<_Handler> setupWatch(Scope2 scope, Map<String, WatchRecord<_Handler>> cache);
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  WatchRecord<_Handler> setupWatch(Scope2 scope, Map<String, WatchRecord<_Handler>> cache) =>
      new ConstantWatchRecord(scope.context);
  String get expression => null;
}

/**
 * SYNTAX: lhs.name.
 *
 * This is the '.' dot operator.
 */
class FieldReadAST extends AST {
  AST lhs;
  final String name;
  final String expression;

  FieldReadAST(lhs, name):
      lhs = lhs,
      name = name,
      expression = lhs.expression == null ? name : '${lhs.expression}.$name';

  WatchRecord<_Handler> setupWatch(Scope2 scope, Map<String, WatchRecord<_Handler>> cache) {
    // recursively process left-hand-side.
    WatchRecord<_Handler> lhsWR = cache.putIfAbsent(lhs.expression, () => lhs.setupWatch(scope, cache));

    var handler = new _FieldHandler(expression, scope);

    // Create a ChangeRecord for the current field and assign the change record to the handler.
    scope._watchCost++;
    var watchRecord = scope._digestDetector.watch(null, name, handler); // TODO: LOD violation
    handler.watchRecord = watchRecord;

    // We set a field forwarding handler on LHS. This will allow the change objects to propagate
    // to the current WatchRecord.
    lhsWR.handler.addForwardToHandler(handler);

    // propagate the value from the LHS to here
    handler.receive(lhsWR.currentValue);
    return watchRecord;
  }
}

class EvalWatchRecord implements WatchRecord<_Handler>, ChangeRecord<_Handler> {
  final Function fn;
  final String name;
  final _Handler handler;
  final List args;
  final Scope2 scope;

  dynamic currentValue;
  dynamic previousValue;
  dynamic object;
  bool deleted = false;

  EvalWatchRecord next;
  EvalWatchRecord previous;

  EvalWatchRecord(this.scope, this.fn, this.name, this.handler, int arity): args = new List(arity);

  check() {
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
        handler.call(this);
      }
    }
  }

  get field => '()';
  get nextChange => null;

  remove() {
    // TODO: should forward to _remove()
    assert(!deleted);
    deleted = true;
    scope._evalCost--;
    var previous = this.previous;
    var next = this.next;

    if (previous != null) previous.next = next;
    if (next != null) next.previous = previous;

    if (previous == null) scope._evalWatchHead = next;
    if (next == null) scope._evalWatchTail = previous;
  }
}

class FunctionAST extends AST {
  final String name;
  final Function fn;
  final List<AST> argsAST;
  final String expression;

  FunctionAST(name, this.fn, argsAST):
      argsAST = argsAST,
      name = name,
      expression = '$name(${argsAST.map((a) => a.expression).join(', ')})';

  WatchRecord<_Handler> setupWatch(Scope2 scope, Map<String, WatchRecord<_Handler>> cache) {
    // Convert the args from AST to WatchRecords
    Iterable<WatchRecord<_Handler>> argsWR = argsAST.map(
        (AST ast) => cache.putIfAbsent(ast.expression, () => ast.setupWatch(scope, cache))
    ).toList();

    _InvokeHandler invokeHandler = new _InvokeHandler(expression, scope); // TODO: move to _addEvalWatch
    EvalWatchRecord evalWatchRecord = scope._addEvalWatch(fn, name, invokeHandler, argsAST.length);
    invokeHandler.watchRecord = evalWatchRecord; // TODO: move to _addEvalWatch

    var i = 0;
    argsWR.forEach((WatchRecord<_Handler> record) {
      var argHandler = new _ArgHandler(invokeHandler, evalWatchRecord, i++, scope);
      record.handler.addForwardToHandler(argHandler);
      argHandler.receive(record.currentValue);
    });

    return evalWatchRecord;
  }
}

class _Handlers {
  static _Handler _add(_Handler list, _Handler item) {
    assert(item._nextHandler     == null);
    assert(item._previousHandler == null);
    if (list._handlerTail == null) {
      list._handlerHead = list._handlerTail = item;
    } else {
      item._previousHandler = list._handlerTail;
      list._handlerTail._nextHandler = item;
      list._handlerTail = item;
    }
    return item;
  }

  static _isEmpty(_Handler list) => list._handlerHead == null;

  static _remove(_Handler list, _Handler item) {
    var previous = item._previousHandler;
    var next = item._nextHandler;

    if (previous == null) list._handlerHead = next;     else previous._nextHandler = next;
    if (next == null)     list._handlerTail = previous; else next._previousHandler = previous;
  }
}

class _ArgHandlers {
  static _Handler _add(_InvokeHandler list, _ArgHandler item) {
    assert(item._nextArgHandler     == null);
    assert(item._previousArgHandler == null);
    if (list._argHandlerTail == null) {
      list._argHandlerHead = list._argHandlerTail = item;
    } else {
      item._previousArgHandler = list._argHandlerTail;
      list._argHandlerTail._nextArgHandler = item;
      list._argHandlerTail = item;
    }
    return item;
  }

  static _isEmpty(_InvokeHandler list) => list._argHandlerHead == null;

  static _remove(_InvokeHandler list, _ArgHandler item) {
    var previous = item._previousArgHandler;
    var next = item._nextArgHandler;

    if (previous == null) list._argHandlerHead = next;     else previous._nextArgHandler = next;
    if (next == null)     list._argHandlerTail = previous; else next._previousArgHandler = previous;
  }
}

class _Watches {
  static Watch _add(_Handler list, Watch item) {
    assert(item._nextWatch     == null);
    assert(item._previousWatch == null);
    if (list._watchTail == null) {
      list._watchHead = list._watchTail = item;
    } else {
      item._previousWatch = list._watchTail;
      list._watchTail._nextWatch = item;
      list._watchTail = item;
    }
    return item;
  }

  static _isEmpty(_Handler list) => list._watchHead == null;

  static _remove(_Handler list, Watch item) {
    var previous = item._previousWatch;
    var next = item._nextWatch;

    if (previous == null) list._watchHead = next;     else previous._nextWatch = next;
    if (next == null)     list._watchTail = previous; else next._previousWatch = previous;
  }
}
