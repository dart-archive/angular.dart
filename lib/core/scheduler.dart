part of angular.core_internal;

class Scheduler {

  _FunctionChain _runAsyncHead, _runAsyncTail;
  _FunctionChain _domWriteHead, _domWriteTail;
  _FunctionChain _domReadHead, _domReadTail;

  final ExceptionHandler _exceptionHandler;
  final ScopeStats _stats;

  Scheduler(this._exceptionHandler, this._stats);

  void execAllDomReads() {
    if (_domReadHead != null) _stats.domReadStart();
    while (_domReadHead != null) {
      try {
        _domReadHead.fn();
      } catch (e, s) {
        _exceptionHandler(e, s);
      }
      _domReadHead = _domReadHead._next;
      if (_domReadHead == null) _stats.domReadEnd();
    }
    _domReadTail = null;
  }

  void execAllDomWrites() {
    if (_domWriteHead != null) _stats.domWriteStart();
    while (_domWriteHead != null) {
      try {
        _domWriteHead.fn();
      } catch (e, s) {
        _exceptionHandler(e, s);
      }
      _domWriteHead = _domWriteHead._next;
      if (_domWriteHead == null) _stats.domWriteEnd();
    }
    _domWriteTail = null;
  }

  bool get readsAndWritesExecuted => _domWriteHead != null || _domReadHead != null;

  void runAllInAsyncQueue() {
    while (_runAsyncHead != null) {
      try {
        _runAsyncHead.fn();
      } catch (e, s) {
        _exceptionHandler(e, s);
      }
      _runAsyncHead = _runAsyncHead._next;
    }
    _runAsyncTail = null;
  }

  void runAsync(fn()) {
    var chain = new _FunctionChain(fn);
    if (_runAsyncHead == null) {
      _runAsyncHead = _runAsyncTail = chain;
    } else {
      _runAsyncTail = _runAsyncTail._next = chain;
    }
  }

  void domWrite(fn()) {
    var chain = new _FunctionChain(fn);
    if (_domWriteHead == null) {
      _domWriteHead = _domWriteTail = chain;
    } else {
      _domWriteTail = _domWriteTail._next = chain;
    }
  }

  void domRead(fn()) {
    var chain = new _FunctionChain(fn);
    if (_domReadHead == null) {
      _domReadHead = _domReadTail = chain;
    } else {
      _domReadTail = _domReadTail._next = chain;
    }
  }
}