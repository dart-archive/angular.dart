part of angular.core;


/**
 * Injected into the listener function within [Scope.$on] to provide event-specific
 * details to the scope listener.
 */
class ScopeEvent {

  /**
   * The name of the intercepted scope event.
   */
  String name;

  /**
   * The origin scope that triggered the event (via $broadcast or $emit).
   */
  Scope targetScope;

  /**
   * The destination scope that intercepted the event.
   */
  Scope currentScope;

  /**
   * true or false depending on if stopPropagation() was executed.
   */
  bool propagationStopped = false;

  /**
   * true or false depending on if preventDefault() was executed.
   */
  bool defaultPrevented = false;

  /**
   ** [name] - The name of the scope event.
   ** [targetScope] - The destination scope that is listening on the event.
   */
  ScopeEvent(this.name, this.targetScope);

  /**
   * Prevents the intercepted event from propagating further to successive scopes.
   */
  stopPropagation () => propagationStopped = true;

  /**
   * Sets the defaultPrevented flag to true.
   */
  preventDefault() => defaultPrevented = true;
}

/**
 * Allows the configuration of [Scope.$digest] iteration maximum time-to-live
 * value. Digest keeps checking the state of the watcher getters until it
 * can execute one full iteration with no watchers triggering. TTL is used
 * to prevent an infinite loop where watch A triggers watch B which in turn
 * triggers watch A. If the system does not stabilize in TTL iteration then
 * an digest is stop an an exception is thrown.
 */
@NgInjectableService()
class ScopeDigestTTL {
  final num ttl;
  ScopeDigestTTL(): ttl = 5;
  ScopeDigestTTL.value(num this.ttl);
}

/**
 * Scope has two responsibilities. 1) to keep track af watches and 2)
 * to keep references to the model so that they are available for
 * data-binding.
 */
@proxy
@NgInjectableService()
class Scope implements Map {
  final ExceptionHandler _exceptionHandler;
  final Parser _parser;
  final NgZone _zone;
  final num _ttl;
  final Map<String, Object> _properties = {};
  final _WatchList _watchers = new _WatchList();
  final Map<String, List<Function>> _listeners = {};
  final bool _isolate;
  final bool _lazy;
  final Profiler _perf;

  /**
   * The direct parent scope that created this scope (this can also be the $rootScope)
   */
  final Scope $parent;

  /**
   * The auto-incremented ID of the scope
   */
  String $id;

  /**
   * The topmost scope of the application (same as $rootScope).
   */
  Scope $root;
  num _nextId = 0;
  String _phase;
  List _innerAsyncQueue;
  List _outerAsyncQueue;
  Scope _nextSibling, _prevSibling, _childHead, _childTail;
  bool _skipAutoDigest = false;
  bool _disabled = false;

  _set$Properties() {
    _properties[r'this'] = this;
    _properties[r'$id'] = this.$id;
    _properties[r'$parent'] = this.$parent;
    _properties[r'$root'] = this.$root;
  }

  Scope(this._exceptionHandler, this._parser, ScopeDigestTTL ttl,
      this._zone, this._perf):
        $parent = null, _isolate = false, _lazy = false, _ttl = ttl.ttl {
    $root = this;
    $id = '_${$root._nextId++}';
    _innerAsyncQueue = [];
    _outerAsyncQueue = [];

    // Set up the zone to auto digest this scope.
    _zone.onTurnDone = _autoDigestOnTurnDone;
    _zone.onError = (e, s, ls) => _exceptionHandler(e, s);
    _set$Properties();
  }

  Scope._child(Scope parent, bool this._isolate, bool this._lazy, Profiler this._perf):
      $parent = parent, _ttl = parent._ttl, _parser = parent._parser,
      _exceptionHandler = parent._exceptionHandler, _zone = parent._zone {
    $root = $parent.$root;
    $id = '_${$root._nextId++}';
    _innerAsyncQueue = $parent._innerAsyncQueue;
    _outerAsyncQueue = $parent._outerAsyncQueue;

    _prevSibling = $parent._childTail;
    if ($parent._childHead != null) {
      $parent._childTail._nextSibling = this;
      $parent._childTail = this;
    } else {
      $parent._childHead = $parent._childTail = this;
    }
    _set$Properties();
  }

  _autoDigestOnTurnDone() {
    if ($root._skipAutoDigest) {
      $root._skipAutoDigest = false;
    } else {
      $digest();
    }
  }

  _identical(a, b) =>
    identical(a, b) ||
    (a is String && b is String && a == b) ||
    (a is num && b is num && a.isNaN && b.isNaN);

  containsKey(String name) {
    for (var scope = this; scope != null; scope = scope.$parent) {
      if (scope._properties.containsKey(name)) {
        return true;
      } else if(scope._isolate) {
        break;
      }
    }
    return false;
  }

  remove(String name) => this._properties.remove(name);
  operator []=(String name, value) => _properties[name] = value;
  operator [](String name) {
    for (var scope = this; scope != null; scope = scope.$parent) {
      if (scope._properties.containsKey(name)) {
        return scope._properties[name];
      } else if(scope._isolate) {
        break;
      }
    }
    return null;
  }

  noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[name];
    } else if (invocation.isSetter) {
      var value = invocation.positionalArguments[0];
      name = name.substring(0, name.length - 1);
      this[name] = value;
      return value;
    } else {
      if (this[name] is Function) {
        return this[name]();
      } else {
        super.noSuchMethod(invocation);
      }
    }
  }


  /**
   * Create a new child [Scope].
   *
   * * [isolate] - If set to true the child scope does not inherit properties from the parent scope.
   *   This in essence creates an independent (isolated) view for the users of the scope.
   * * [lazy] - If set to true the scope digest will only run if the scope is marked as [$dirty].
   *   This is usefull if we expect that the bindings in the scope are constant and there is no need
   *   to check them on each digest. The digest can be forced by marking it [$dirty].
   */
  $new({bool isolate: false, bool lazy: false}) =>
    new Scope._child(this, isolate, lazy, _perf);

  /**
   * *EXPERIMENTAL:* This feature is experimental. We reserve the right to change or delete it.
   *
   * A dissabled scope will not be part of the [$digest] cycle until it is re-enabled.
   */
  set $disabled(value) => this._disabled = value;
  get $disabled => this._disabled;

  /**
   * Registers a listener callback to be executed whenever the [watchExpression] changes.
   *
   * The watchExpression is called on every call to [$digest] and should return the value that
   * will be watched. (Since [$digest] reruns when it detects changes the watchExpression can
   * execute multiple times per [$digest] and should be idempotent.)
   *
   * The listener is called only when the value from the current [watchExpression] and the
   * previous call to [watchExpression] are not identical (with the exception of the initial run,
   * see below).
   *
   * The watch listener may change the model, which may trigger other listeners to fire. This is
   * achieved by rerunning the watchers until no changes are detected. The rerun iteration limit
   * is 10 to prevent an infinite loop deadlock.
   * If you want to be notified whenever [$digest] is called, you can register a [watchExpression]
   * function with no listener. (Since [watchExpression] can execute multiple times per [$digest]
   * cycle when a change is detected, be prepared for multiple calls to your listener.)
   *
   * After a watcher is registered with the scope, the listener fn is called asynchronously
   * (via [$evalAsync]) to initialize the watcher. In rare cases, this is undesirable because the
   * listener is called when the result of [watchExpression] didn't change. To detect this
   * scenario within the listener fn, you can compare the newVal and oldVal. If these two values
   * are identical then the listener was called due to initialization.
   *
   * * [watchExpression] - can be any one of these: a [Function] - `(Scope scope) => ...;` or a
   *   [String]  - `expression` which is compiled with [Parser] service into a function
   * * [listener] - A [Function] `(currentValue, previousValue, Scope scope) => ...;`
   * * [watchStr] - Used as a debbuging hint to easier identify which expression is associated with
   *   this watcher.
   */
  $watch(watchExpression, [Function listener, String watchStr]) {
    if (watchStr == null) {
      watchStr = watchExpression.toString();

      // Keep prod fast
      assert((() {
        watchStr = _source(watchExpression);
        return true;
      })());
    }
    var watcher = new _Watch(_compileToFn(listener), _initWatchVal,
        _compileToFn(watchExpression), watchStr);
    _watchers.addLast(watcher);
    return () => _watchers.remove(watcher);
  }

  /**
   * A variant of [$watch] where it watches a collection of [watchExpressios]. If any
   * one expression in the collection changes the [listener] is executed.
   *
   * * [watcherExpressions] - `List<String|(Scope scope){}>`
   * * [Listener] - `(List newValues, List previousValues, Scope scope)`
   */
  $watchSet(List watchExpressions, [Function listener, String watchStr]) {
    if (watchExpressions.length == 0) return () => null;

    var lastValues = new List(watchExpressions.length);
    var currentValues = new List(watchExpressions.length);

    if (watchExpressions.length == 1) {
    // Special case size of one.
      return $watch(watchExpressions[0], (value, oldValue, scope) {
        currentValues[0] = value;
        lastValues[0] = oldValue;
        listener(currentValues, lastValues, scope);
      });
    }
    var deregesterFns = [];
    var changeCount = 0;
    for(var i = 0, ii = watchExpressions.length; i < ii; i++) {
      deregesterFns.add($watch(watchExpressions[i], (value, oldValue, __) {
        currentValues[i] = value;
        lastValues[i] = oldValue;
        changeCount++;
      }));
    }
    deregesterFns.add($watch((s) => changeCount, (c, o, scope) {
      listener(currentValues, lastValues, scope);
    }));
    return () {
      for(var i = 0, ii = deregesterFns.length; i < ii; i++) {
        deregesterFns[i]();
      }
    };
  }

  /**
   * Shallow watches the properties of an object and fires whenever any of the properties change
   * (for arrays, this implies watching the array items; for object maps, this implies watching
   * the properties). If a change is detected, the listener callback is fired.
   *
   *  The obj collection is observed via standard [$watch] operation and is examined on every call
   *  to [$digest] to see if any items have been added, removed, or moved.
   *
   *  The listener is called whenever anything within the obj has changed. Examples include
   *  adding, removing, and moving items belonging to an object or array.
   */
  $watchCollection(obj, listener, [String expression, bool shallow=false]) {
    var oldValue;
    var newValue;
    int changeDetected = 0;
    Function objGetter = _compileToFn(obj);
    List internalArray = [];
    Map internalMap = {};
    int oldLength = 0;
    int newLength;
    var key;
    List keysToRemove = [];
    Function detectNewKeys = (key, value) {
      newLength++;
      if (oldValue.containsKey(key)) {
        if (!_identical(oldValue[key], value)) {
          changeDetected++;
          oldValue[key] = value;
        }
      } else {
        oldLength++;
        oldValue[key] = value;
        changeDetected++;
      }
    };
    Function findMissingKeys = (key, _) {
      if (!newValue.containsKey(key)) {
        oldLength--;
        keysToRemove.add(key);
      }
    };

    Function removeMissingKeys = (k) => oldValue.remove(k);

    var $watchCollectionWatch;

    if (shallow) {
      $watchCollectionWatch = (_) {
        newValue = objGetter(this);
        newLength = newValue == null ? 0 : newValue.length;
        if (newLength != oldLength) {
          oldLength = newLength;
          changeDetected++;
        }
        if (!identical(oldValue, newValue)) {
          oldValue = newValue;
          changeDetected++;
        }
        return changeDetected;
      };
    } else {
      $watchCollectionWatch = (_) {
        newValue = objGetter(this);

        if (newValue is! Map && newValue is! List) {
          if (!_identical(oldValue, newValue)) {
            oldValue = newValue;
            changeDetected++;
          }
        } else if (newValue is Iterable) {
          if (!_identical(oldValue, internalArray)) {
            // we are transitioning from something which was not an array into array.
            oldValue = internalArray;
            oldLength = oldValue.length = 0;
            changeDetected++;
          }

          newLength = newValue.length;

          if (oldLength != newLength) {
            // if lengths do not match we need to trigger change notification
            changeDetected++;
            oldValue.length = oldLength = newLength;
          }
          // copy the items to oldValue and look for changes.
          for (var i = 0; i < newLength; i++) {
            if (!_identical(oldValue[i], newValue.elementAt(i))) {
              changeDetected++;
              oldValue[i] = newValue.elementAt(i);
            }
          }
        } else { // Map
          if (!_identical(oldValue, internalMap)) {
            // we are transitioning from something which was not an object into object.
            oldValue = internalMap = {};
            oldLength = 0;
            changeDetected++;
          }
          // copy the items to oldValue and look for changes.
          newLength = 0;
          newValue.forEach(detectNewKeys);
          if (oldLength > newLength) {
            // we used to have more keys, need to find them and destroy them.
            changeDetected++;
            oldValue.forEach(findMissingKeys);
            keysToRemove.forEach(removeMissingKeys);
            keysToRemove.clear();
          }
        }
        return changeDetected;
      };
    }

    var $watchCollectionAction = (_, __, ___) {
      relaxFnApply(listener, [newValue, oldValue, this]);
    };

    return this.$watch($watchCollectionWatch,
                       $watchCollectionAction,
                       expression == null ? obj : expression);
  }


  /**
   * Add this function to your code if you want to add a $digest
   * and want to assert that the digest will be called on this turn.
   * This method will be deleted when we are comfortable with
   * auto-digesting scope.
   */
  $$verifyDigestWillRun() {
    assert(!$root._skipAutoDigest);
    _zone.assertInTurn();
  }

  /**
   * *EXPERIMENTAL:* This feature is experimental. We reserve the right to change or delete it.
   *
   * Marks a scope as dirty. If the scope is lazy (see [$new]) then the scope will be included
   * in the next [$digest].
   *
   * NOTE: This has no effect for non-lazy scopes.
   */
  $dirty() {
    this._disabled = false;
  }

  /**
   * Processes all of the watchers of the current scope and its children.
   * Because a watcher's listener can change the model, the `$digest()` operation keeps calling
   * the watchers no further response data has changed. This means that it is possible to get
   * into an infinite loop. This function will throw `'Maximum iteration limit exceeded.'`
   * if the number of iterations exceeds 10.
   *
   * There should really be no need to call $digest() in production code since everything is
   * handled behind the scenes with zones and object mutation events. However, in testing
   * both $digest and [$apply] are useful to control state and simulate the scope life cycle in
   * a step-by-step manner.
   *
   * Refer to [$watch], [$watchSet] or [$watchCollection] to see how to register watchers that
   * are executed during the digest cycle.
   */
  $digest() {
    try {
      _beginPhase('\$digest');
      _digestWhileDirtyLoop();
    } catch (e, s) {
      _exceptionHandler(e, s);
    } finally {
      _clearPhase();
    }
  }


  _digestWhileDirtyLoop() {
    _digestHandleQueue('ng.innerAsync', _innerAsyncQueue);

    int timerId;
    assert((timerId = _perf.startTimer('ng.dirty_check', 0)) != false);
    _Watch lastDirtyWatch = _digestComputeLastDirty();
    assert(_perf.stopTimer(timerId) != false);

    if (lastDirtyWatch == null) {
      _digestHandleQueue('ng.outerAsync', _outerAsyncQueue);
      return;
    }

    List<List<String>> watchLog = [];
    for (int iteration = 1, ttl = _ttl; iteration < ttl; iteration++) {
      _Watch stopWatch = _digestHandleQueue('ng.innerAsync', _innerAsyncQueue)
          ? null  // Evaluating async work requires re-evaluating all watchers.
          : lastDirtyWatch;
      lastDirtyWatch = null;

      List<String> expressionLog;
      if (ttl - iteration <= 3) {
        expressionLog = <String>[];
        watchLog.add(expressionLog);
      }

      int timerId;
      assert((timerId = _perf.startTimer('ng.dirty_check', iteration)) != false);
      lastDirtyWatch = _digestComputeLastDirtyUntil(stopWatch, expressionLog);
      assert(_perf.stopTimer(timerId) != false);

      if (lastDirtyWatch == null) {
        _digestComputePerfCounters();
        _digestHandleQueue('ng.outerAsync', _outerAsyncQueue);
        return;
      }
    }

    // I've seen things you people wouldn't believe. Attack ships on fire
    // off the shoulder of Orion. I've watched C-beams glitter in the dark
    // near the Tannhauser Gate. All those moments will be lost in time,
    // like tears in rain. Time to die.
    throw '$_ttl \$digest() iterations reached. Aborting!\n'
          'Watchers fired in the last ${watchLog.length} iterations: '
          '${_toJson(watchLog)}';
  }


  bool _digestHandleQueue(String timerName, List queue) {
    if (queue.isEmpty) {
      return false;
    }
    do {
      var timerId;
      try {
        var workFn = queue.removeAt(0);
        assert((timerId = _perf.startTimer(timerName, _source(workFn))) != false);
        $root.$eval(workFn);
      } catch (e, s) {
        _exceptionHandler(e, s);
      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }
    } while (queue.isNotEmpty);
    return true;
  }


  _Watch _digestComputeLastDirty() {
    int watcherCount = 0;
    int scopeCount = 0;
    Scope scope = this;
    do {
      _WatchList watchers = scope._watchers;
      watcherCount += watchers.length;
      scopeCount++;
      for (_Watch watch = watchers.head; watch != null; watch = watch.next) {
        var last = watch.last;
        var value = watch.get(scope);
        if (!_identical(value, last)) {
          return _digestHandleDirty(scope, watch, last, value, null);
        }
      }
    } while ((scope = _digestComputeNextScope(scope)) != null);
    _digestUpdatePerfCounters(watcherCount, scopeCount);
    return null;
  }


  _Watch _digestComputeLastDirtyUntil(_Watch stopWatch, List<String> log) {
    int watcherCount = 0;
    int scopeCount = 0;
    Scope scope = this;
    do {
      _WatchList watchers = scope._watchers;
      watcherCount += watchers.length;
      scopeCount++;
      for (_Watch watch = watchers.head; watch != null; watch = watch.next) {
        if (identical(stopWatch, watch)) return null;
        var last = watch.last;
        var value = watch.get(scope);
        if (!_identical(value, last)) {
          return _digestHandleDirty(scope, watch, last, value, log);
        }
      }
    } while ((scope = _digestComputeNextScope(scope)) != null);
    return null;
  }


  _Watch _digestHandleDirty(Scope scope, _Watch watch, last, value, List<String> log) {
    _Watch lastDirtyWatch;
    while (true) {
      if (!_identical(value, last)) {
        lastDirtyWatch = watch;
        if (log != null) log.add(watch.exp == null ? '[unknown]' : watch.exp);
        watch.last = value;
        var fireTimer;
        assert((fireTimer = _perf.startTimer('ng.fire', watch.exp)) != false);
        watch.fn(value, identical(_initWatchVal, last) ? value : last, scope);
        assert(_perf.stopTimer(fireTimer) != false);
      }
      watch = watch.next;
      while (watch == null) {
        scope = _digestComputeNextScope(scope);
        if (scope == null) return lastDirtyWatch;
        watch = scope._watchers.head;
      }
      last = watch.last;
      value = watch.get(scope);
    }
  }


  Scope _digestComputeNextScope(Scope scope) {
    // Insanity Warning: scope depth-first traversal
    // yes, this code is a bit crazy, but it works and we have tests to prove it!
    // this piece should be kept in sync with the traversal in $broadcast
    Scope target = this;
    Scope childHead = scope._childHead;
    while (childHead != null && childHead._disabled) {
      childHead = childHead._nextSibling;
    }
    if (childHead == null) {
      if (scope == target) {
        return null;
      } else {
        Scope next = scope._nextSibling;
        if (next == null) {
          while (scope != target && (next = scope._nextSibling) == null) {
            scope = scope.$parent;
          }
        }
        return next;
      }
    } else {
      if (childHead._lazy) childHead._disabled = true;
      return childHead;
    }
  }


  void _digestComputePerfCounters() {
    int watcherCount = 0, scopeCount = 0;
    Scope scope = this;
    do {
      scopeCount++;
      watcherCount += scope._watchers.length;
    } while ((scope = _digestComputeNextScope(scope)) != null);
    _digestUpdatePerfCounters(watcherCount, scopeCount);
  }


  void _digestUpdatePerfCounters(int watcherCount, int scopeCount) {
    _perf.counters['ng.scope.watchers'] = watcherCount;
    _perf.counters['ng.scopes'] = scopeCount;
  }


  /**
   * Removes the current scope (and all of its children) from the parent scope. Removal implies
   * that calls to $digest() will no longer propagate to the current scope and its children.
   * Removal also implies that the current scope is eligible for garbage collection.
   *
   * The `$destroy()` operation is usually used within directives that perform transclusion on
   * multiple child elements (like ngRepeat) which create multiple child scopes.
   *
   * Just before a scope is destroyed, a `$destroy` event is broadcasted on this scope. This is
   * a great way for child scopes (such as shared directives or controllers) to detect to and
   * perform any necessary cleanup before the scope is removed from the application.
   *
   * Note that, in AngularDart, there is also a `$destroy` jQuery DOM event, which can be used to
   * clean up DOM bindings before an element is removed from the DOM.
   */
  $destroy() {
    if ($root == this) return; // we can't remove the root node;

    $broadcast(r'$destroy');

    if ($parent._childHead == this) $parent._childHead = _nextSibling;
    if ($parent._childTail == this) $parent._childTail = _prevSibling;
    if (_prevSibling != null) _prevSibling._nextSibling = _nextSibling;
    if (_nextSibling != null) _nextSibling._prevSibling = _prevSibling;
  }


  /**
   * Evaluates the expression against the current scope and returns the result. Note that, the
   * expression data is relative to the data within the scope. Therefore an expression such as
   * `a + b` will deference variables `a` and `b` and return a result so long as `a` and `b`
   * exist on the scope.
   *
   * * [expr] - The expression that will be evaluated. This can be both a Function or a String.
   * * [locals] - An optional Map of key/value data that will override any matching scope members
   *   for the purposes of the evaluation.
   */
  $eval(expr, [locals]) {
    return relaxFnArgs(_compileToFn(expr))(locals == null ? this : new ScopeLocals(this, locals));
  }


  /**
   * Evaluates the expression against the current scope at a later point in time. The $evalAsync
   * operation may not get run right away (depending if an existing digest cycle is going on) and
   * may therefore be issued later on (by a follow-up digest cycle). Note that at least one digest
   * cycle will be performed after the expression is evaluated. However, If triggering an additional
   * digest cycle is not desired then this can be avoided by placing `{outsideDigest: true}` as
   * the 2nd parameter to the function.
   *
   * * [expr] - The expression that will be evaluated. This can be both a Function or a String.
   * * [outsideDigest] - Whether or not to trigger a follow-up digest after evaluation.
   */
  $evalAsync(expr, {outsideDigest: false}) {
    if (outsideDigest) {
      _outerAsyncQueue.add(expr);
    } else {
      _innerAsyncQueue.add(expr);
    }
  }


  /**
   * Skip running a $digest at the end of this turn.
   * The primary use case is to skip the digest in the current VM turn because
   * you just scheduled or are otherwise certain of an impending VM turn and the
   * digest at the end of that turn is sufficient.  You should be able to answer
   * "No" to the question "Is there any other code that is aware that this VM
   * turn occurred and therefore expected a digest?".  If your answer is "Yes",
   * then you run the risk that the very next VM turn is not for your event and
   * now that other code runs in that turn and sees stale values.
   *
   * You might call this function, for instance, from an event listener where,
   * though the event occurred, you need to wait for another event before you can
   * perform something meaningful.  You might schedule that other event,
   * set a flag for the handler of the other event to recognize, etc. and then
   * call this method to skip the digest this cycle.  Note that you should call
   * this function *after* you have successfully confirmed that the expected VM
   * turn will occur (perhaps by scheduling it) to ensure that the digest
   * actually does take place on that turn.
   */
  $skipAutoDigest() {
    _zone.assertInTurn();
    $root._skipAutoDigest = true;
  }


  /**
   * Triggers a digest operation much like [$digest] does, however, also accepts an
   * optional expression to evaluate alongside the digest operation. The result of that
   * expression will be returned afterwards. Much like with $digest, $apply should only be
   * used within unit tests to simulate the life cycle of a scope. See [$digest] to learn
   * more.
   *
   * * [expr] - optional expression which will be evaluated after the digest is performed. See [$eval]
   *   to learn more about expressions.
   */
  $apply([expr]) {
    return _zone.run(() {
      var timerId;
      try {
        assert((timerId = _perf.startTimer('ng.\$apply', _source(expr))) != false);
        return $eval(expr);
      } catch (e, s) {
        _exceptionHandler(e, s);
      } finally {
        assert(_perf.stopTimer(timerId) != false);
      }
    });
  }


  /**
   * Registers a scope-based event listener to intercept events triggered by
   * [$broadcast] (from any parent scopes) or [$emit] (from child scopes) that
   * match the given event name. $on accepts two arguments:
   *
   * * [name] - Refers to the event name that the scope will listen on.
   * * [listener] - Refers to the callback function which is executed when the event
   *   is intercepted.
   *
   *
   * When the listener function is executed, an instance of [ScopeEvent] will be passed
   * as the first parameter to the function.
   *
   * Any additional parameters available within the listener callback function are those that
   * are set by the $broadcast or $emit scope methods (which are set by the origin scope which
   * is the scope that first triggered the scope event).
   */
  $on(name, listener) {
    var namedListeners = _listeners[name];
    if (!_listeners.containsKey(name)) {
      _listeners[name] = namedListeners = [];
    }
    namedListeners.add(listener);

    return () {
      namedListeners.remove(listener);
    };
  }


  /**
   * Triggers a scope event referenced by the [name] parameters upwards towards the root of the
   * scope tree. If intercepted, by a parent scope containing a matching scope event listener
   * (which is registered via the [$on] scope method), then the event listener callback function
   * will be executed.
   *
   * * [name] - The scope event name that will be triggered.
   * * [args] - An optional list of arguments that will be fed into the listener callback function
   *   for any event listeners that are registered via [$on].
   */
  $emit(name, [List args]) {
    var empty = [],
        namedListeners,
        scope = this,
        event = new ScopeEvent(name, this),
        listenerArgs = [event],
        i;

    if (args != null) {
      listenerArgs.addAll(args);
    }

    do {
      namedListeners = scope._listeners[name];
      if (namedListeners != null) {
        event.currentScope = scope;
        i = 0;
        for (var length = namedListeners.length; i<length; i++) {
          try {
            relaxFnApply(namedListeners[i], listenerArgs);
            if (event.propagationStopped) return event;
          } catch (e, s) {
            _exceptionHandler(e, s);
          }
        }
      }
      //traverse upwards
      scope = scope.$parent;
    } while (scope != null);

    return event;
  }


  /**
   * Triggers a scope event referenced by the [name] parameters dowards towards the leaf nodes of the
   * scope tree. If intercepted, by a child scope containing a matching scope event listener
   * (which is registered via the [$on] scope method), then the event listener callback function
   * will be executed.
   *
   * * [name] - The scope event name that will be triggered.
   * * [listenerArgs] - An optional list of arguments that will be fed into the listener callback function
   *   for any event listeners that are registered via [$on].
   */
  $broadcast(String name, [List listenerArgs]) {
    var target = this,
        current = target,
        next = target,
        event = new ScopeEvent(name, this);

    //down while you can, then up and next sibling or up and next sibling until back at root
    if (listenerArgs == null) {
      listenerArgs = [];
    }
    listenerArgs.insert(0, event);
    do {
      current = next;
      event.currentScope = current;
      if (current._listeners.containsKey(name)) {
        current._listeners[name].forEach((listener) {
          try {
            relaxFnApply(listener, listenerArgs);
          } catch(e, s) {
            _exceptionHandler(e, s);
          }
        });
      }

      // Insanity Warning: scope depth-first traversal
      // yes, this code is a bit crazy, but it works and we have tests to prove it!
      // this piece should be kept in sync with the traversal in $broadcast
      if (current._childHead == null) {
        if (current == target) {
          next = null;
        } else {
          next = current._nextSibling;
          if (next == null) {
            while(current != target && (next = current._nextSibling) == null) {
              current = current.$parent;
            }
          }
        }
      } else {
        next = current._childHead;
      }
    } while ((current = next) != null);

    return event;
  }

  _beginPhase(phase) {
    if ($root._phase != null) {
      // TODO(deboer): Remove the []s when dartbug.com/11999 is fixed.
      throw ['${$root._phase} already in progress'];
    }
    assert(_perf.startTimer('ng.phase.${phase}') != false);

    $root._phase = phase;
  }

  _clearPhase() {
    assert(_perf.stopTimer('ng.phase.${$root._phase}') != false);
    $root._phase = null;
  }

  Function _compileToFn(exp) {
    if (exp == null) {
      return () => null;
    } else if (exp is String) {
      Expression expression = _parser(exp);
      return expression.eval;
    } else if (exp is Function) {
      return exp;
    } else {
      throw 'Expecting String or Function';
    }
  }
}

@proxy
class ScopeLocals implements Scope, Map {
  static wrapper(dynamic scope, Map<String, Object> locals) => new ScopeLocals(scope, locals);

  dynamic _scope;
  Map<String, Object> _locals;

  ScopeLocals(this._scope, this._locals);

  operator []=(String name, value) => _scope[name] = value;
  operator [](String name) => (_locals.containsKey(name) ? _locals : _scope)[name];

  noSuchMethod(Invocation invocation) => mirror.reflect(_scope).delegate(invocation);
}

class _InitWatchVal { const _InitWatchVal(); }
const _initWatchVal = const _InitWatchVal();

class _Watch {
  final Function fn;
  final Function get;
  final String exp;
  var last;

  _Watch previous;
  _Watch next;

  _Watch(fn, this.last, getFn, this.exp)
      : this.fn  = relaxFnArgs3(fn)
      , this.get = relaxFnArgs1(getFn);
}

class _WatchList {
  int length = 0;
  _Watch head;
  _Watch tail;

  void addLast(_Watch watch) {
    assert(watch.previous == null);
    assert(watch.next == null);
    if (tail == null) {
      tail = head = watch;
    } else {
      watch.previous = tail;
      tail.next = watch;
      tail = watch;
    }
    length++;
  }

  void remove(_Watch watch) {
    if (watch == head) {
      _Watch next = watch.next;
      if (next == null) tail = null;
      else next.previous = null;
      head = next;
    } else if (watch == tail) {
      _Watch previous = watch.previous;
      previous.next = null;
      tail = previous;
    } else {
      _Watch next = watch.next;
      _Watch previous = watch.previous;
      previous.next = next;
      next.previous = previous;
    }
    length--;
  }
}

_toJson(obj) {
  try {
    return JSON.encode(obj);
  } catch(e) {
    var ret = "NOT-JSONABLE";
    // Keep prod fast.
    assert(() {
      var mirror = reflect(obj);
      if (mirror is ClosureMirror) {
        // work-around dartbug.com/14130
        try {
          ret = mirror.function.source;
        } on NoSuchMethodError catch (e) {
        } on UnimplementedError catch (e) {
        }
      }
      return true;
    });
    return ret;
  }
}

String _source(obj) {
  if (obj is Function) {
    var m = reflect(obj);
    if (m is ClosureMirror) {
      // work-around dartbug.com/14130
      try {
        return "FN: ${m.function.source}";
      } on NoSuchMethodError catch (e) {
      } on UnimplementedError catch (e) {
      }
    }
  }
  return '$obj';
}
