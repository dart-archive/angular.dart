part of angular;

var initWatchVal = new Object();

class Watch {
  Function fn;
  dynamic last;
  Function get;
  String exp;

  Watch(fn, this.last, get, this.exp) {
    this.fn = _relaxFnArgs(fn);
    this.get = _relaxFnArgs(get);
  }
}

class ScopeEvent {
  String name;
  Scope targetScope;
  Scope currentScope;
  bool propagationStopped = false;
  bool defaultPrevented = false;

  ScopeEvent(this.name, this.targetScope);

  stopPropagation () => propagationStopped = true;
  preventDefault() => defaultPrevented = true;
}

class ScopeModule extends Module {
  ScopeModule(Scope scope) {
    this.value(Scope, scope);
  }
}

class ScopeDigestTTL {
  num ttl;
  ScopeDigestTTL(num this.ttl);
}

class Scope implements Map {
  String $id;
  Scope $parent;
  Scope get $root => _$root != null ? _$root : $parent.$root;
  Scope _$root;

  ExceptionHandler _exceptionHandler;
  Parser _parser;
  Zone _zone;
  num _ttl;
  String _phase;
  Map<String, Object> _properties = {};
  List<Function> _asyncQueue = [];
  List<Watch> _watchers = [];
  Map<String, Function> _listeners = {};
  Scope _nextSibling, _prevSibling, _childHead, _childTail;
  bool _isolate = false;
  Profiler _perf;


  Scope(ExceptionHandler this._exceptionHandler, Parser this._parser,
      ScopeDigestTTL ttl, Zone this._zone, Profiler this._perf) {
    _properties[r'this']= this;
    _ttl = ttl.ttl;
    _$root = this;
    $id = nextUid();

    // Set up the zone to auto digest this scope.
    _zone.onTurnDone = $digest;

    _zone.interceptCall = (body) {
      _beginPhase('auto-digesting zoned call');
      try {
        return body();
      } finally {
        _clearPhase();
      }
    };
  }

  Scope._child(Scope this.$parent, bool this._isolate, Profiler this._perf) {
    _exceptionHandler = $parent._exceptionHandler;
    _parser = $parent._parser;
    _ttl = $parent._ttl;
    _properties[r'this'] = this;
    _zone = $parent._zone;
    $id = nextUid();
    if (_isolate) {
      _$root = $parent.$root;
    } else {
      _asyncQueue = $parent._asyncQueue;
    }

    _prevSibling = $parent._childTail;
    if ($parent._childHead != null) {
      $parent._childTail._nextSibling = this;
      $parent._childTail = this;
    } else {
      $parent._childHead = $parent._childTail = this;
    }
  }

  containsKey(String name) => this[name] != null;

  operator []=(String name, value) => _properties[name] = value;
  operator [](String name) {
    if (_properties.containsKey(name)) {
      return _properties[name];
    } else if (!_isolate) {
      //var $parent = _properties[r'$parent'];
      //var $root = _properties[r'$root'];
      if ($parent != null /*&& $parent != $root*/) {
        return $parent[name];
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



  $new([bool isolate = false]) {
    return new Scope._child(this, isolate, _perf);
  }


  $watch(watchExp, [Function listener]) {
    var watcher = new Watch(_compileToFn(listener), initWatchVal,
        _compileToFn(watchExp), watchExp.toString());

    // we use unshift since we use a while loop in $digest for speed.
    // the while loop reads in reverse order.
    _watchers.insert(0, watcher);

    return () => _watchers.remove(watcher);
  }

  $watchCollection(obj, listener) {
    List oldValue = [];
    var newValue;
    num changeDetected = 0;
    Function objGetter = _compileToFn(obj);
    List internalArray = [];
    num oldLength = 0;

    var $watchCollectionWatch = () {
      newValue = objGetter(this);
      if (!(newValue is List)) newValue = [];

      var newLength = newValue.length;

      if (oldLength != newLength) {
        // if lengths do not match we need to trigger change notification
        changeDetected++;
        oldValue.length = oldLength = newLength;
      }
      // copy the items to oldValue and look for changes.
      for (var i = 0; i < newLength; i++) {
        if (oldValue[i] != newValue[i]) {
          changeDetected++;
          oldValue[i] = newValue[i];
        }
      }
      return changeDetected;
    };

    var $watchCollectionAction = () {
      relaxFnApply(listener, [newValue, oldValue, self]);
    };

    return this.$watch($watchCollectionWatch, $watchCollectionAction);
  }


  /**
   * Add this function to your code if you want to add a $digest
   * and want to assert that the digest will be called on this turn.
   * This method will be deleted when we are comfortable with
   * auto-digesting scope.
   */
  $$verifyDigestWillRun() {
    _zone.assertInTurn();
  }

  $digest() => _perf.time('angular.scope.digest', () {
    var value, last,
        asyncQueue = _asyncQueue,
        length,
        dirty, _ttlLeft = _ttl,
        logIdx, logMsg;
    List<List<String>> watchLog = [];
    List<Watch> watchers;
    Watch watch;
    Scope next, current, target = this;

    _beginPhase('\$digest');
    try {
      do { // "while dirty" loop
        dirty = false;
        current = target;
        //asyncQueue = current._asyncQueue;
        //dump('aQ: ${asyncQueue.length}');

        while(asyncQueue.length > 0) {
          try {
            current.$eval(asyncQueue.removeAt(0));
          } catch (e, s) {
            _exceptionHandler(e, s);
          }
        }

        do { // "traverse the scopes" loop
          if ((watchers = current._watchers) != null) {
            // process our watches
            length = watchers.length;
            while (length-- > 0) {
              try {
                watch = watchers[length];
                if ((value = watch.get(current)) != (last = watch.last) &&
                    !(value is num && last is num && value.isNaN && last.isNaN)) {
                  dirty = true;
                  watch.last = value;
                  watch.fn(value, ((last == initWatchVal) ? value : last), current);
                  if (_ttlLeft < 5) {
                    logIdx = 4 - _ttlLeft;
                    while (watchLog.length <= logIdx) {
                      watchLog.add([]);
                    }
                    logMsg = (watch.exp is Function)
                        ? 'fn: ' + (watch.exp.name || watch.exp.toString())
                        : watch.exp;
                    logMsg += '; newVal: ' + toJson(value) + '; oldVal: ' + toJson(last);
                    watchLog[logIdx].add(logMsg);
                  }
                }
              } catch (e, s) {
                _exceptionHandler(e, s);
              }
            }
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

        if(dirty && (_ttlLeft--) == 0) {
          throw '$_ttl \$digest() iterations reached. Aborting!\n' +
              'Watchers fired in the last 5 iterations: ${toJson(watchLog)}';
        }
      } while (dirty || asyncQueue.length > 0);
    } finally {
      _clearPhase();
    }
  });


  $destroy() {
    if ($root == this) return; // we can't remove the root node;

    $broadcast(r'$destroy');

    if ($parent._childHead == this) $parent._childHead = _nextSibling;
    if ($parent._childTail == this) $parent._childTail = _prevSibling;
    if (_prevSibling != null) _prevSibling._nextSibling = _nextSibling;
    if (_nextSibling != null) _nextSibling._prevSibling = _prevSibling;
  }


  $eval(expr, [locals]) {
    return _relaxFnArgs(_compileToFn(expr))(this, locals);
  }


  $evalAsync(expr) {
    _asyncQueue.add(expr);
  }


  $apply([expr]) {
    return _zone.run(() {
      try {
        return $eval(expr);
      } catch (e, s) {
        _exceptionHandler(e, s);
      }
    });
  }


  $on(name, listener) {
    if (!_listeners.containsKey(name)) {
      _listeners[name] = namedListeners = [];
    }
    var namedListeners = _listeners[name];
    namedListeners.add(listener);

    return () {
      namedListeners.remove(listener);
    };
  }


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

    $root._phase = phase;
  }

  _clearPhase() {
    $root._phase = null;
  }

  Function _compileToFn(exp) {
    if (exp == null) {
      return () => null;
    } else if (exp is String) {
      return _parser(exp);
    } else if (exp is Function) {
      return exp;
    } else {
      throw 'Expecting String or Function';
    }
  }

}
