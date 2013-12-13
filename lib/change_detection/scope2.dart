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
  int get watchCost => _watchCost;

  ChangeDetector<_Handler> _digestDetector = new DirtyCheckingChangeDetector<_Handler>();
  Watch _dirtyWatchHead;
  Watch _dirtyWatchTail;

  Scope2(this.context);

  Watch watch(AST expression, ReactionFn reactionFn) {
    WatchRecord<_Handler> watchRecord = expression.setupWatch(this);
    return watchRecord.handler.addReactionFn(reactionFn);
  }

  digest() {
    // Process the ChangeRecords from the change detector
    ChangeRecord<_Handler> changeRecord = _digestDetector.collectChanges();
    while (changeRecord != null) {
      changeRecord.handler.call(changeRecord);
      changeRecord = changeRecord.nextChange;
    }

    // Because the handler can forward changes between each other synchronously
    // We need to call reaction functions asynchronously. This processes the asynchronous
    // reaction function queue.
    Watch reaction = _dirtyWatchHead;
    while(reaction != null) {
      reaction.invoke();
      reaction = reaction._nextReaction;
    }
    _dirtyWatchHead = _dirtyWatchTail = null;
  }

  /**
   * Add Watch into the asynchronous queue for later processing.
   */
  Watch _addDirtyReaction(Watch watch) {
    if (watch._dirty) return watch;
    watch._dirty = false;
    if (_dirtyWatchTail == null) {
      _dirtyWatchHead = _dirtyWatchTail = watch;
    } else {
      _dirtyWatchTail = (_dirtyWatchTail._nextDirtyReaction = watch);
    }
    return watch;
  }
}

/**
 * [Watch] corresponds to an individual [watch] registration on the scope.
 */
class Watch {
  final Record<_Handler> _record;
  final ReactionFn reactionFn;

  bool _dirty = false;
  Watch _previousReaction;
  Watch _nextReaction;
  Watch _nextDirtyReaction;

  Watch(this._record, this.reactionFn, this._nextReaction);

  get expression => _record.handler.expression;

  invoke() {
    _dirty = false;
    reactionFn(_record.currentValue, _record.previousValue, _record.object);
  }


  remove() {
    var previous = _previousReaction;
    var next = _nextReaction;
    if (previous != null) previous._nextReaction = next;
    if (next != null) next._previousReaction = previous;

    // if we are the head of the Handler then update the handler
    _Handler handler = _record.handler;
    if (handler.reactionHead == this) handler.reactionHead = next;
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
 *   - forwardHandler --+      - forwardHandler --+      - forwardHandler = null
 *   - expression: 'a'         - expression: 'a.b'       - expression: 'a.b.c'
 *   - watchObject: context    - watchObject: context.a  - watchObject: context.a.b
 *   - watchRecord: 'a'        - watchRecord 'b'         - watchRecord 'c'
 *   - reactionFn: null        - reactionFn: rfn1        - reactionFn: rfn2
 *
 * Notice how the [_Handler]s coalesce their watching. Also notice that any changes detected
 * at one handler are propagated to the next handler.
 */
class _Handler {
  final Scope2 scope;
  final String expression;

  WatchRecord<_Handler> watchRecord;
  _Handler forwardHandler;
  _Handler forwardingHandler;
  Watch reactionHead;

  _Handler(this.expression, this.scope) {
    if (scope != null) scope._watchCost++;
  }

  link(_Handler forwardHandler) {
    this.forwardHandler = forwardHandler;
    forwardHandler.forwardingHandler = this;
  }

  /**
   * This function forwards the watched object to the next [_Handler] synchronously.
   */
  void forward(dynamic object) {
    watchRecord.object = object;
    var changeRecord = watchRecord.check();
    if (changeRecord != null) {
      //TODO(misko):test this
      this.call(changeRecord);
    }
  }

  Watch addReactionFn(ReactionFn reactionFn) {
    return scope._addDirtyReaction(
        reactionHead = new Watch(watchRecord, reactionFn, reactionHead)
    );
  }

  void gc() {
    // scope is null in the case of Context handler
    if (scope != null && reactionHead == null && forwardHandler == null) {
      // We can remove ourselves
      scope._digestDetector.remove(watchRecord);
      scope._watchCost--;
      forwardingHandler.forwardHandler = null;
      forwardingHandler.gc();
    }
  }

  // TODO(misko): when there are no more reactionFns or forwarders, this needs to be removed.

  void call(ChangeRecord<_Handler> record) {
    // A change has been detected.
    var currentValue = record.currentValue;

    // If we have a forwardHandler then forward the new object to it.
    if (forwardHandler != null) {
      //TODO(misko):test this
      forwardHandler.forward(currentValue);
    }

    // If we have reaction functions than queue them up for asynchronous processing.
    var reaction = reactionHead;
    while(reaction != null) {
      scope._addDirtyReaction(reaction);
      reaction = reaction._nextReaction;
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
  WatchRecord<_Handler> setupWatch(Scope2 scope);
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  WatchRecord<_Handler> setupWatch(Scope2 scope) => new ConstantWatchRecord(scope.context);
  String get expression => null;
}

/**
 * SYNTAX: lhs.name
 *
 * This is the '.' dot operator.
 */
class FieldReadAST extends AST {
  AST lhs;
  final name;
  final expression;

  FieldReadAST(lhs, name):
      lhs = lhs,
      name = name,
      expression = lhs.expression == null ? name : '${lhs.expression}.$name';

  WatchRecord<_Handler> setupWatch(Scope2 scope) {
    // recursively process left-hand-side.
    WatchRecord<_Handler> lhsWR = lhs.setupWatch(scope);

    var handler = new _Handler(expression, scope);

    // Create a ChangeRecord for the current field and assign the change record to the handler.
    var watchRecord = scope._digestDetector.watch(null, name, handler);
    handler.watchRecord = watchRecord;

    // We set a field forwarding handler on LHS. This will allow the change objects to propagate
    // to the current WatchRecord.
    lhsWR.handler.link(handler);

    // propagate the value from the LHS to here
    handler.forward(lhsWR.currentValue);
    return watchRecord;
  }
}


