part of angular.core;

NOT_IMPLEMENTED() {
  throw new StateError('Not Implemented');
}

typedef EvalFunction0();
typedef EvalFunction1(context);

/**
 * Injected into the listener function within [Scope.on] to provide
 * event-specific details to the scope listener.
 */
class ScopeEvent {
  static final String DESTROY = 'ng-destroy';

  /**
   * Data attached to the event. This would be the optional parameter
   * from [Scope.emit] and [Scope.broadcast].
   */
  final data;

  /**
   * The name of the intercepted scope event.
   */
  final String name;

  /**
   * The origin scope that triggered the event (via $broadcast or $emit).
   */
  final Scope targetScope;

  /**
   * The destination scope that intercepted the event. As
   * the event traverses the scope hierarchy the the event instance
   * stays the same, but the [currentScope] reflects the scope
   * of the current listener which is firing.
   */
  Scope get currentScope => _currentScope;
  Scope _currentScope;

  /**
   * true or false depending on if stopPropagation() was executed.
   */
  bool get propagationStopped => _propagationStopped;
  bool _propagationStopped = false;

  /**
   * true or false depending on if preventDefault() was executed.
   */
  bool get defaultPrevented => _defaultPrevented;
  bool _defaultPrevented = false;

  /**
   ** [name] - The name of the scope event.
   ** [targetScope] - The destination scope that is listening on the event.
   */
  ScopeEvent(this.name, this.targetScope, this.data);

  /**
   * Prevents the intercepted event from propagating further to successive
   * scopes.
   */
  void stopPropagation () {
    _propagationStopped = true;
  }

  /**
   * Sets the defaultPrevented flag to true.
   */
  void preventDefault() {
    _defaultPrevented = true;
  }
}

/**
 * Allows the configuration of [Scope.digest] iteration maximum time-to-live
 * value. Digest keeps checking the state of the watcher getters until it
 * can execute one full iteration with no watchers triggering. TTL is used
 * to prevent an infinite loop where watch A triggers watch B which in turn
 * triggers watch A. If the system does not stabilize in TTL iterations then
 * the digest is stopped and an exception is thrown.
 */
@NgInjectableService()
class ScopeDigestTTL {
  final int ttl;
  ScopeDigestTTL(): ttl = 5;
  ScopeDigestTTL.value(this.ttl);
}

//TODO(misko): I don't think this should be in scope.
class ScopeLocals implements Map {
  static wrapper(scope, Map<String, Object> locals) =>
      new ScopeLocals(scope, locals);

  Map _scope;
  Map<String, Object> _locals;

  ScopeLocals(this._scope, this._locals);

  void operator []=(String name, value) {
    _scope[name] = value;
  }
  dynamic operator [](String name) =>
      (_locals.containsKey(name) ? _locals : _scope)[name];

  bool get isEmpty => _scope.isEmpty && _locals.isEmpty;
  bool get isNotEmpty => _scope.isNotEmpty || _locals.isNotEmpty;
  List<String> get keys => _scope.keys;
  List get values => _scope.values;
  int get length => _scope.length;

  void forEach(fn) {
    _scope.forEach(fn);
  }
  dynamic remove(key) => _scope.remove(key);
  void clear() {
    _scope.clear;
  }
  bool containsKey(key) => _scope.containsKey(key);
  bool containsValue(key) => _scope.containsValue(key);
  void addAll(map) {
    _scope.addAll(map);
  }
  dynamic putIfAbsent(key, fn) => _scope.putIfAbsent(key, fn);
}

/**
 * [Scope] is represents a collection of [watch]es [observe]ers, and [context]
 * for the watchers, observers and [eval]uations. Scopes structure loosely
 * mimics the DOM structure. Scopes and [Block]s are bound to each other.
 * As scopes are created and destroyed by [BlockFactory] they are responsible
 * for change detection, change processing and memory management.
 */
class Scope {

  /**
   * The default execution context for [watch]es [observe]ers, and [eval]uation.
   */
  final context;

  /**
   * The [RootScope] of the application.
   */
  final RootScope rootScope;

  Scope _parentScope;

  /**
   * The parent [Scope].
   */
  Scope get parentScope => _parentScope;

  // TODO(misko): WatchGroup should be private.
  // Instead we should expose performance stats about the watches
  // such as # of watches, checks/1ms, field checks, function checks, etc
  final WatchGroup watchGroup;
  final WatchGroup observeGroup;
  final int _depth;
  final int _index;

  Scope _childHead, _childTail, _next, _prev;
  _Streams _streams;
  int _nextChildIndex = 0;

  Scope(Object this.context, this.rootScope, this._parentScope, this._depth,
        this._index, this.watchGroup, this.observeGroup);

  /**
   * A [watch] sets up a watch in the [digest] phase of the [apply] cycle.
   *
   * Use [watch] if the reaction function can cause updates to model. In your
   * controller code you will most likely use [watch].
   */
  Watch watch(expression, ReactionFn reactionFn, {context, FilterMap filters}) {
    return _watch(watchGroup, expression, reactionFn, context, filters);
  }

  Watch observe(expression, ReactionFn reactionFn, {context, FilterMap filters}) {
    return _watch(observeGroup, expression, reactionFn, context, filters);
  }

  Watch _watch(WatchGroup group, expression, ReactionFn reactionFn,
               context, FilterMap filters) {
    assert(expression != null);
    AST ast;
    Watch watch;
    ReactionFn fn = reactionFn;
    if (expression is AST) {
      ast = expression;
    } else if (expression is String) {
      if (expression.startsWith('::')) {
        expression = expression.substring(2);
        fn = (value, last) {
          if (value != null) {
            watch.remove();
            return reactionFn(value, last);
          }
        };
      } else if (expression.startsWith(':')) {
        expression = expression.substring(1);
        fn = (value, last) {
          if (value != null) {
            return reactionFn(value, last);
          }
        };
      }
      ast = rootScope._astParser(expression, context: context, filters: filters);
    } else {
      throw 'expressions must be String or AST got $expression.';
    }
    return watch = group.watch(ast, fn);
  }

  dynamic eval(expression, [Map locals]) {
    assert(expression == null ||
           expression is String ||
           expression is Function);
    if (expression is String && expression.isNotEmpty) {
      var obj = locals == null ? context : new ScopeLocals(context, locals);
      return rootScope._parser(expression).eval(obj);
    } else {
      assert(locals == null);
      if (expression is EvalFunction1) return expression(context);
      if (expression is EvalFunction0) return expression();
    }
  }

  dynamic applyInZone([expression, Map locals]) =>
      rootScope._zone.run(() => apply(expression, locals));

  dynamic apply([expression, Map locals]) {
    rootScope._transitionState(null, RootScope.STATE_APPLY);
    try {
      return eval(expression, locals);
    } catch (e, s) {
      rootScope._exceptionHandler(e, s);
    } finally {
      rootScope
          .._transitionState(RootScope.STATE_APPLY, null)
          ..digest()
          ..flush();
    }
  }

  ScopeEvent emit(String name, [data]) => _Streams.emit(this, name, data);
  ScopeEvent broadcast(String name, [data]) =>
      _Streams.broadcast(this, name, data);
  ScopeStream on(String name) =>
      _Streams.on(this, rootScope._exceptionHandler, name);

  Scope createChild(Object childContext) {
    var child = new Scope(childContext, rootScope, this,
                          _depth + 1, _nextChildIndex++,
                          watchGroup.newGroup(childContext),
                          observeGroup.newGroup(childContext));
    var next = null;
    var prev = _childTail;
    child._next = next;
    child._prev = prev;
    if (prev == null) _childHead = child; else prev._next = child;
    if (next == null) _childTail = child; else next._prev = child;
    return child;
  }

  void destroy() {
    var prev = _prev;
    var next = _next;
    if (prev == null) {
      _parentScope._childHead = next;
    } else {
      prev._next = next;
    }
    if (next == null) {
      _parentScope._childTail = prev;
    } else {
      next._prev = prev;
    }

    this._next = this._prev = null;

    watchGroup.remove();
    observeGroup.remove();
    _Streams.destroy(this);

    _parentScope = null;
    broadcast(ScopeEvent.DESTROY);
  }
}


class RootScope extends Scope {
  static final STATE_APPLY = 'apply';
  static final STATE_DIGEST = 'digest';
  static final STATE_FLUSH = 'digest';

  final ExceptionHandler _exceptionHandler;
  final AstParser _astParser;
  final Parser _parser;
  final ScopeDigestTTL _ttl;
  final ExpressionVisitor visitor = new ExpressionVisitor(); // TODO(misko): delete me
  final NgZone _zone;

  _FunctionChain _runAsyncHead, _runAsyncTail;
  _FunctionChain _domWriteHead, _domWriteTail;
  _FunctionChain _domReadHead, _domReadTail;

  String _state;

  RootScope(Object context, this._astParser, this._parser,
            GetterCache cacheGetter, FilterMap filterMap,
            this._exceptionHandler, this._ttl, this._zone)
      : super(context, null, null, 0, 0,
            new RootWatchGroup(new DirtyCheckingChangeDetector(cacheGetter), context),
            new RootWatchGroup(new DirtyCheckingChangeDetector(cacheGetter), context))
  {
    _zone.onTurnDone = () {
      digest();
      flush();
    };
  }

  RootScope get rootScope => this;

  void digest() {
    _transitionState(null, STATE_DIGEST);
    try {
      var rootWatchGroup = (watchGroup as RootWatchGroup);

      int digestTTL = _ttl.ttl;
      const int LOG_COUNT = 3;
      List log;
      List digestLog;
      var count;
      ChangeLog changeLog;
      do {
        while(_runAsyncHead != null) {
          try {
            _runAsyncHead.fn();
          } catch (e, s) {
            _exceptionHandler(e, s);
          }
          _runAsyncHead = _runAsyncHead._next;
        }

        digestTTL--;
        count = rootWatchGroup.detectChanges(
            exceptionHandler: _exceptionHandler, changeLog: changeLog);

        if (digestTTL <= LOG_COUNT) {
          if (changeLog == null) {
            log = [];
            digestLog = [];
            changeLog = (e, c, p) => digestLog.add('$e: $c <= $p');
          } else {
            log.add(digestLog.join(', '));
            digestLog.clear();
          }
        }
        if (digestTTL == 0) {
          throw 'Model did not stabilize in ${_ttl.ttl} digests. '
                'Last $LOG_COUNT iterations:\n${log.join('\n')}';
        }
      } while (count > 0);
    } finally {
      _transitionState(STATE_DIGEST, null);
    }
  }

  void flush() {
    _transitionState(null, STATE_FLUSH);
    var observeGroup = this.observeGroup as RootWatchGroup;
    bool runObservers = true;
    try {
      do {
        while(_domWriteHead != null) {
          try {
            _domWriteHead.fn();
          } catch (e, s) {
            _exceptionHandler(e, s);
          }
          _domWriteHead = _domWriteHead._next;
        }
        if (runObservers) {
          runObservers = false;
          observeGroup.detectChanges(exceptionHandler:_exceptionHandler);
        }
        while(_domReadHead != null) {
          try {
            _domReadHead.fn();
          } catch (e, s) {
            _exceptionHandler(e, s);
          }
          _domReadHead = _domReadHead._next;
        }
      } while (_domWriteHead != null || _domReadHead != null);
      assert((() {
        var watchLog = [];
        var observeLog = [];
        (watchGroup as RootWatchGroup).detectChanges(
            changeLog: (s, c, p) => watchLog.add('$s: $c <= $p'));
        (observeGroup as RootWatchGroup).detectChanges(
            changeLog: (s, c, p) => watchLog.add('$s: $c <= $p'));
        if (watchLog.isNotEmpty || observeLog.isNotEmpty) {
          throw 'Observer reaction functions should not change model. \n'
                'These watch changes were detected: ${watchLog.join('; ')}\n'
                'These observe changes were detected: ${observeLog.join('; ')}';
        }
        return true;
      })());
    } finally {
      _transitionState(STATE_FLUSH, null);
    }

  }

  // QUEUES
  void runAsync(Function fn) {
    var chain = new _FunctionChain(fn);
    if (_runAsyncHead == null) {
      _runAsyncHead = _runAsyncTail = chain;
    } else {
      _runAsyncTail = _runAsyncTail._next = chain;
    }
  }

  void domWrite(Function fn) {
    var chain = new _FunctionChain(fn);
    if (_domWriteHead == null) {
      _domWriteHead = _domWriteTail = chain;
    } else {
      _domWriteTail = _domWriteTail._next = chain;
    }
  }

  void domRead(Function fn) {
    var chain = new _FunctionChain(fn);
    if (_domReadHead == null) {
      _domReadHead = _domReadTail = chain;
    } else {
      _domReadTail = _domReadTail._next = chain;
    }
  }

  void destroy() {}

  void _transitionState(String from, String to) {
    if (_state != from) throw "$_state already in progress can not enter $to.";
    _state = to;
  }
}

/**
 * Keeps track of Streams for each Scope. When emitting events
 * we would need to walk the whole tree. Its faster if we can prune
 * the Scopes we have to visit.
 *
 * Scope with no [_ScopeStreams] has no events registered on itself or children
 *
 * We keep track of [Stream]s, and also child scope [Stream]s. To save
 * memory we use the same stream object on all of our parents if they don't
 * have one. But that means that we have to keep track if the stream belongs
 * to the node.
 *
 * Scope with [_ScopeStreams] but who's [_scope] does not match the scope
 * is only inherited
 *
 * Only [Scope] with [_ScopeStreams] who's [_scope] matches the [Scope]
 * instance is the actual scope.
 *
 * Once the [Stream] is created it can not be removed even if all listeners
 * are canceled. That is because we don't know if someone still has reference
 * to it.
 */
class _Streams {
  final ExceptionHandler _exceptionHandler;
  /// Scope we belong to.
  final Scope _scope;
  /// [Stream]s for [_scope] only
  final _streams = new Map<String, ScopeStream>();
  /// Child [Scope] event counts.
  final Map<String, int> _typeCounts;

  _Streams(this._scope, this._exceptionHandler, _Streams inheritStreams)
      : _typeCounts = inheritStreams == null
          ? <String, int>{}
          : new Map.from(inheritStreams._typeCounts);

  static ScopeEvent emit(Scope scope, String name, data) {
    var event = new ScopeEvent(name, scope, data);
    var scopeCursor = scope;
    while(scopeCursor != null) {
      if (scopeCursor._streams != null &&
          scopeCursor._streams._scope == scopeCursor) {
        ScopeStream stream = scopeCursor._streams._streams[name];
        if (stream != null) {
          event._currentScope = scopeCursor;
          stream._fire(event);
          if (event.propagationStopped) return event;
        }
      }
      scopeCursor = scopeCursor._parentScope;
    }
    return event;
  }

  static ScopeEvent broadcast(Scope scope, String name, data) {
    _Streams scopeStreams = scope._streams;
    var event = new ScopeEvent(name, scope, data);
    if (scopeStreams != null && scopeStreams._typeCounts.containsKey(name)) {
      var queue = new Queue()..addFirst(scopeStreams._scope);
      while (queue.isNotEmpty) {
        scope = queue.removeFirst();
        scopeStreams = scope._streams;
        assert(scopeStreams._scope == scope);
        assert(scopeStreams._streams.containsKey(name));
        var stream = scopeStreams._streams[name];
        event._currentScope = scope;
        stream._fire(event);
        // Reverse traversal so that when the queue is read it is correct order.
        var childScope = scope._childTail;
        while(childScope != null) {
          scopeStreams = childScope._streams;
          if (scopeStreams != null) queue.addFirst(scopeStreams._scope);
          childScope = childScope._prev;
        }
      }
    }
    return event;
  }

  static ScopeStream on(Scope scope,
                        ExceptionHandler _exceptionHandler,
                        String name) {
    var scopeStream = scope._streams;
    if (scopeStream == null || scopeStream._scope != scope) {
      // We either don't have [_ScopeStreams] or it is inherited.
      var newStreams = new _Streams(scope, _exceptionHandler, scopeStream);
      var scopeCursor = scope;
      while (scopeCursor != null && scopeCursor._streams == scopeStream) {
        scopeCursor._streams = newStreams;
        scopeCursor = scopeCursor._parentScope;
      }
      scopeStream = newStreams;
    }
    return scopeStream._get(scope, name);
  }

  static void destroy(Scope scope) {
    var toBeDeletedStreams = scope._streams;
    if (toBeDeletedStreams == null) return;
    scope = scope._parentScope; // skip current state as not to delete listeners
    while (scope != null && scope._streams == toBeDeletedStreams) {
      scope._streams = null;
      scope = scope._parentScope;
    }
    if (scope == null) return;
    var parentStreams = scope._streams;
    assert(parentStreams != toBeDeletedStreams);
    toBeDeletedStreams._typeCounts.forEach(
        (name, count) => parentStreams._addCount(name, -count));
  }

  async.Stream _get(Scope scope, String name) {
    assert(scope._streams == this);
    assert(scope._streams._scope == scope);
    assert(_exceptionHandler != null);
    return _streams.putIfAbsent(name, () =>
        new ScopeStream(this, _exceptionHandler, name));
  }

  void _addCount(String name, int amount) {
    // decrement the counters on all parent scopes
    _Streams lastStreams = null;
    var scope = _scope;
    while (scope != null) {
      if (lastStreams != scope._streams) {
        // we have a transition, need to decrement it
        lastStreams = scope._streams;
        int count = lastStreams._typeCounts[name];
        count = count == null ? amount : count + amount;
        assert(count >= 0);
        if (count == 0) {
          lastStreams._typeCounts.remove(name);
        } else {
          lastStreams._typeCounts[name] = count;
        }
      }
      scope = scope._parentScope;
    }
  }
}

class ScopeStream extends async.Stream<ScopeEvent> {
  final ExceptionHandler _exceptionHandler;
  final _Streams _streams;
  final String _name;
  final subscriptions = <ScopeStreamSubscription>[];

  ScopeStream(this._streams, this._exceptionHandler, this._name);

  ScopeStreamSubscription listen(void onData(ScopeEvent event),
                                 { Function onError,
                                   void onDone(),
                                   bool cancelOnError }) {
    if (subscriptions.isEmpty) _streams._addCount(_name, 1);
    var subscription = new ScopeStreamSubscription(this, onData);
    subscriptions.add(subscription);
    return subscription;
  }

  void _fire(ScopeEvent event) {
    for(ScopeStreamSubscription subscription in subscriptions) {
      try {
        subscription._onData(event);
      } catch (e, s) {
        _exceptionHandler(e, s);
      }
    }
  }

  void _remove(ScopeStreamSubscription subscription) {
    assert(subscription._scopeStream == this);
    if (subscriptions.remove(subscription)) {
      if (subscriptions.isEmpty) _streams._addCount(_name, -1);
    } else {
      throw new StateError('AlreadyCanceled');
    }
  }
}

class ScopeStreamSubscription implements async.StreamSubscription<ScopeEvent> {
  final ScopeStream _scopeStream;
  final Function _onData;
  ScopeStreamSubscription(this._scopeStream, this._onData);

  // TODO(vbe) should return a Future
  cancel() => _scopeStream._remove(this);

  void onData(void handleData(ScopeEvent data)) => NOT_IMPLEMENTED();
  void onError(Function handleError) => NOT_IMPLEMENTED();
  void onDone(void handleDone()) => NOT_IMPLEMENTED();
  void pause([async.Future resumeSignal]) => NOT_IMPLEMENTED();
  void resume() => NOT_IMPLEMENTED();
  bool get isPaused => NOT_IMPLEMENTED();
  async.Future asFuture([var futureValue]) => NOT_IMPLEMENTED();
}

class _FunctionChain {
  final Function fn;
  _FunctionChain _next;

  _FunctionChain(this.fn);
}

class AstParser {
  final Parser _parser;
  int _id = 0;
  ExpressionVisitor _visitor = new ExpressionVisitor();

  AstParser(this._parser);

  AST call(String exp, { FilterMap filters,
                         bool collection:false,
                         Object context:null }) {
    _visitor.filters = filters;
    AST contextRef = _visitor.contextRef;
    try {
      if (context != null) {
        _visitor.contextRef = new ConstantAST(context, '#${_id++}');
      }
      var ast = _parser(exp);
      return collection ? _visitor.visitCollection(ast) : _visitor.visit(ast);
    } finally {
      _visitor.contextRef = contextRef;
      _visitor.filters = null;
    }
  }
}

class ExpressionVisitor implements Visitor {
  static final ContextReferenceAST scopeContextRef = new ContextReferenceAST();
  AST contextRef = scopeContextRef;

  AST ast;
  FilterMap filters;

  AST visit(Expression exp) {
    exp.accept(this);
    assert(this.ast != null);
    try {
      return ast;
    } finally {
      ast = null;
    }
  }

  AST visitCollection(Expression exp) => new CollectionAST(visit(exp));
  AST _mapToAst(Expression expression) => visit(expression);

  List<AST> _toAst(List<Expression> expressions) =>
      expressions.map(_mapToAst).toList();

  void visitCallScope(CallScope exp) {
    ast = new MethodAST(contextRef, exp.name, _toAst(exp.arguments));
  }
  void visitCallMember(CallMember exp) {
    ast = new MethodAST(visit(exp.object), exp.name, _toAst(exp.arguments));
  }
  visitAccessScope(AccessScope exp) {
    ast = new FieldReadAST(contextRef, exp.name);
  }
  visitAccessMember(AccessMember exp) {
    ast = new FieldReadAST(visit(exp.object), exp.name);
  }
  visitBinary(Binary exp) {
    ast = new PureFunctionAST(exp.operation,
                              _operationToFunction(exp.operation),
                              [visit(exp.left), visit(exp.right)]);
  }
  void visitPrefix(Prefix exp) {
    ast = new PureFunctionAST(exp.operation,
                              _operationToFunction(exp.operation),
                              [visit(exp.expression)]);
  }
  void visitConditional(Conditional exp) {
    ast = new PureFunctionAST('?:', _operation_ternary,
                              [visit(exp.condition), visit(exp.yes),
                              visit(exp.no)]);
  }
  void visitAccessKeyed(AccessKeyed exp) {
    ast = new PureFunctionAST('[]', _operation_bracket,
                             [visit(exp.object), visit(exp.key)]);
  }
  void visitLiteralPrimitive(LiteralPrimitive exp) {
    ast = new ConstantAST(exp.value);
  }
  void visitLiteralString(LiteralString exp) {
    ast = new ConstantAST(exp.value);
  }
  void visitLiteralArray(LiteralArray exp) {
    List<AST> items = _toAst(exp.elements);
    ast = new PureFunctionAST('[${items.join(', ')}]', new ArrayFn(), items);
  }

  void visitLiteralObject(LiteralObject exp) {
    List<String> keys = exp.keys;
    List<AST> values = _toAst(exp.values);
    assert(keys.length == values.length);
    var kv = <String>[];
    for(var i = 0; i < keys.length; i++) {
      kv.add('${keys[i]}: ${values[i]}');
    }
    ast = new PureFunctionAST('{${kv.join(', ')}}', new MapFn(keys), values);
  }

  void visitFilter(Filter exp) {
    Function filterFunction = filters(exp.name);
    List<AST> args = [visitCollection(exp.expression)];
    args.addAll(_toAst(exp.arguments).map((ast) => new CollectionAST(ast)));
    ast = new PureFunctionAST('|${exp.name}',
        new _FilterWrapper(filterFunction, args.length), args);
  }

  // TODO(misko): this is a corner case. Choosing not to implement for now.
  void visitCallFunction(CallFunction exp) {
    _notSupported("function's returing functions");
  }
  void visitAssign(Assign exp) {
    _notSupported('assignement');
  }
  void visitLiteral(Literal exp) {
    _notSupported('literal');
  }
  void visitExpression(Expression exp) {
    _notSupported('?');
  }
  void visitChain(Chain exp) {
    _notSupported(';');
  }

  void  _notSupported(String name) {
    throw new StateError("Can not watch expression containing '$name'.");
  }
}

Function _operationToFunction(String operation) {
  switch(operation) {
    case '!'  : return _operation_negate;
    case '+'  : return _operation_add;
    case '-'  : return _operation_subtract;
    case '*'  : return _operation_multiply;
    case '/'  : return _operation_divide;
    case '~/' : return _operation_divide_int;
    case '%'  : return _operation_remainder;
    case '==' : return _operation_equals;
    case '!=' : return _operation_not_equals;
    case '<'  : return _operation_less_then;
    case '>'  : return _operation_greater_then;
    case '<=' : return _operation_less_or_equals_then;
    case '>=' : return _operation_greater_or_equals_then;
    case '^'  : return _operation_power;
    case '&'  : return _operation_bitwise_and;
    case '&&' : return _operation_logical_and;
    case '||' : return _operation_logical_or;
    default: throw new StateError(operation);
  }
}

_operation_negate(value)                       => !toBool(value);
_operation_add(left, right)                    => autoConvertAdd(left, right);
_operation_subtract(left, right)               => left - right;
_operation_multiply(left, right)               => left * right;
_operation_divide(left, right)                 => left / right;
_operation_divide_int(left, right)             => left ~/ right;
_operation_remainder(left, right)              => left % right;
_operation_equals(left, right)                 => left == right;
_operation_not_equals(left, right)             => left != right;
_operation_less_then(left, right)              => left < right;
_operation_greater_then(left, right)           => left > right;
_operation_less_or_equals_then(left, right)    => left <= right;
_operation_greater_or_equals_then(left, right) => left >= right;
_operation_power(left, right)                  => left ^ right;
_operation_bitwise_and(left, right)            => left & right;
// TODO(misko): these should short circuit the evaluation.
_operation_logical_and(left, right)            => toBool(left) && toBool(right);
_operation_logical_or(left, right)             => toBool(left) || toBool(right);

_operation_ternary(condition, yes, no) => toBool(condition) ? yes : no;
_operation_bracket(obj, key) => obj == null ? null : obj[key];

class ArrayFn extends FunctionApply {
  // TODO(misko): figure out why do we need to make a copy?
  apply(List args) => new List.from(args);
}

class MapFn extends FunctionApply {
  final List<String> keys;

  MapFn(this.keys);

  apply(List values) {
    // TODO(misko): figure out why do we need to make a copy instead of reusing instance?
    assert(values.length == keys.length);
    return new Map.fromIterables(keys, values);
  }
}

class _FilterWrapper extends FunctionApply {
  final Function filterFn;
  final List args;
  final List<Watch> argsWatches;
  _FilterWrapper(this.filterFn, length):
      args = new List(length),
      argsWatches = new List(length);

  apply(List values) {
    for(var i=0; i < values.length; i++) {
      var value = values[i];
      var lastValue = args[i];
      if (!identical(value, lastValue)) {
       if (value is CollectionChangeRecord) {
         args[i] = (value as CollectionChangeRecord).iterable;
       } else {
         args[i] = value;
       }
      }
    }
    var value = Function.apply(filterFn, args);
    if (value is Iterable) {
      // Since filters are pure we can guarantee that this well never change.
      // By wrapping in UnmodifiableListView we can hint to the dirty checker
      // and short circuit the iterator.
      value = new UnmodifiableListView(value);
    }
    return value;
  }
}
