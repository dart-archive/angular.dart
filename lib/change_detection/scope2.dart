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
class Watch extends _LinkedListItem<Watch> {
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
    _record.handler
      .._remove(this)
      ..gc();
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
class _Handler extends _LinkedList<Watch> implements _LinkedListItem {
  _Handler _next, _previous; // _LinkedList<_Handler>

  final String expression;
  final Scope2 scope;

  WatchRecord<_Handler> watchRecord;
  _Handler forwardingHandler;
  _LinkedList<_Handler> forwardToHandlers = new _LinkedList<_Handler>();

  _Handler(this.expression, this.scope);

  Watch addReactionFn(ReactionFn reactionFn) {
    return scope._addDirtyWatch(_add(new Watch(watchRecord, reactionFn)));
  }

  void addForwardToHandler(_Handler forwardToHandler) {
    assert(forwardToHandler.forwardingHandler == null);
    forwardToHandlers._add(forwardToHandler);
    forwardToHandler.forwardingHandler = this;
  }

  void gc() {
    // scope is null in the case of Context handler
    if (scope != null && _isEmpty && forwardToHandlers._isEmpty) {
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
        forwardingHandler.forwardToHandlers._remove(this);
        forwardingHandler.gc();
      }
    }
  }

  void receive(dynamic object) => asert(false);

  void call(ChangeRecord<_Handler> record) {
    // A change has been detected.

    // If we have reaction functions than queue them up for asynchronous processing.
    Watch watch = _head;
    while(watch != null) {
      scope._addDirtyWatch(watch);
      watch = watch._next;
    }
    // If we have a delegateHandler then forward the new object to it.
    _LinkedListItem<_Handler> delegateHandler = forwardToHandlers._head;
    while (delegateHandler != null) {
      delegateHandler.receive(record.currentValue);
      delegateHandler = delegateHandler._next;
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

class _ArgHandler extends _Handler implements _LinkedListItem0 {
  final EvalWatchRecord watchRecord;
  final int index;

  _ArgHandler _previous0, _next0;

  _ArgHandler(_InvokeHandler invokeHandler, this.watchRecord, int index, Scope2 scope):
      super('arg[$index]', scope),
      index = index
  {
    invokeHandler.addArgumentHandler(this);
  }

  receive(dynamic object) => watchRecord.args[index] = object;
}

class _InvokeHandler extends _Handler {
  final _LinkedList0<_ArgHandler> argHandlers = new _LinkedList0<_ArgHandler>();

  _InvokeHandler(expression, scope): super(expression, scope);

  addArgumentHandler(_ArgHandler handler) => argHandlers._add0(handler);

  gc() {
    watchRecord.remove();
    _ArgHandler current = argHandlers._head0;
    while(current != null) {
      current.gc();
      current = current._next0;
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

class _LinkedList<I extends _LinkedListItem> {
  I _head;
  I _tail;

  I _add(I item) {
    if (_tail == null) {
      _head = _tail = item;
    } else {
      item._previous = _tail;
      _tail._next = item;
      _tail = item;
    }
    return item;
  }

  get _isEmpty => _head == null;

  _remove(I item) {
    var previous = item._previous;
    var next = item._next;

    if (previous == null) _head = next;     else previous._next = next;
    if (next == null)     _tail = previous; else next._previous = previous;
  }
}

class _LinkedListItem<I extends _LinkedListItem> {
  I _previous;
  I _next;
}

class _LinkedList0<I extends _LinkedListItem0> {
  I _head0;
  I _tail0;

  I _add0(I item) {
    assert(item._next0     == null);
    assert(item._previous0 == null);
    if (_tail0 == null) {
      _head0 = _tail0 = item;
    } else {
      item._previous0 = _tail0;
      _tail0._next0 = item;
      _tail0 = item;
    }
    return item;
  }

  get _isEmpty0 => _head0 == null;

  _remove0(I item) {
    var previous = item._previous0;
    var next = item._next0;

    if (previous == null) _head0 = next;     else previous._next0 = next;
    if (next == null)     _tail0 = previous; else next._previous0 = previous;
  }
}

class _LinkedListItem0<I extends _LinkedListItem0>{
  I _previous0;
  I _next0;
}

