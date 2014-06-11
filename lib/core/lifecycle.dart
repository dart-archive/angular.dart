part of angular.core_internal;

class LifeCycle {
  static final STATE_APPLY = 'apply';
  static final STATE_DIGEST = 'digest';
  static final STATE_FLUSH = 'flush';
  static final STATE_FLUSH_ASSERT = 'assert';

  final ExceptionHandler _exceptionHandler;
  final ScopeStats _scopeStats;
  final ScopeDigestTTL _ttl;
  final WatchGroup _flushGroup;
  final WatchGroup _digestGroup;
  final Scheduler _scheduler;
  String _state;

  LifeCycle(this._flushGroup, this._digestGroup, this._ttl, this._scopeStats, this._scheduler,
      this._exceptionHandler);

  /**
   * Before each iteration of change detection, [digest] first processes the async queue. Any
   * work scheduled on the queue is executed before change detection. Since work scheduled on
   * the queue may generate more async calls, [digest] must process the queue multiple times before
   * it completes. The async queue must be empty before the model is considered stable.
   *
   * Next, [digest] collects the changes that have occurred in the model. For each change,
   * [digest] calls the associated [ReactionFn]. Since a [ReactionFn] may further change the model,
   * [digest] processes changes multiple times until no more changes are detected.
   *
   * If the model does not stabilize within 5 iterations, an exception is thrown. See
   * [ScopeDigestTTL].
   */
  void digest() {
    _transitionState(null, STATE_DIGEST);
    try {
      var rootWatchGroup = _digestGroup as RootWatchGroup;

      int digestTTL = _ttl.ttl;
      const int LOG_COUNT = 3;
      List log;
      List digestLog;
      var count;
      ChangeLog changeLog;
      _scopeStats.digestStart();
      do {
        _scheduler.runAllInAsyncQueue();

        digestTTL--;
        count = rootWatchGroup.detectChanges(
            exceptionHandler: _exceptionHandler,
            changeLog: changeLog,
            fieldStopwatch: _scopeStats.fieldStopwatch,
            evalStopwatch: _scopeStats.evalStopwatch,
            processStopwatch: _scopeStats.processStopwatch);

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
        _scopeStats.digestLoop(count);
      } while (count > 0);
    } finally {
      _scopeStats.digestEnd();
      _transitionState(STATE_DIGEST, null);
    }
  }


  void flush() {
    _scopeStats.flushStart();
    _transitionState(null, STATE_FLUSH);
    RootWatchGroup readOnlyGroup = this._flushGroup as RootWatchGroup;
    bool runObservers = true;
    try {
      do {
        _scheduler.execAllDomWrites();
        if (runObservers) {
          runObservers = false;
          readOnlyGroup.detectChanges(exceptionHandler:_exceptionHandler,
          fieldStopwatch: _scopeStats.fieldStopwatch,
          evalStopwatch: _scopeStats.evalStopwatch,
          processStopwatch: _scopeStats.processStopwatch);
        }
        _scheduler.execAllDomReads();
      } while (_scheduler.readsAndWritesExecuted);
      _scopeStats.flushEnd();
      assert((() {
        _scopeStats.flushAssertStart();
        var digestLog = [];
        var flushLog = [];
        (_digestGroup as RootWatchGroup).detectChanges(
            changeLog: (s, c, p) => digestLog.add('$s: $c <= $p'),
            fieldStopwatch: _scopeStats.fieldStopwatch,
            evalStopwatch: _scopeStats.evalStopwatch,
            processStopwatch: _scopeStats.processStopwatch);
        (_flushGroup as RootWatchGroup).detectChanges(
            changeLog: (s, c, p) => flushLog.add('$s: $c <= $p'),
            fieldStopwatch: _scopeStats.fieldStopwatch,
            evalStopwatch: _scopeStats.evalStopwatch,
            processStopwatch: _scopeStats.processStopwatch);
        if (digestLog.isNotEmpty || flushLog.isNotEmpty) {
          throw 'Observer reaction functions should not change model. \n'
          'These watch changes were detected: ${digestLog.join('; ')}\n'
          'These observe changes were detected: ${flushLog.join('; ')}';
        }
        _scopeStats.flushAssertEnd();
        return true;
      })());
    } finally {
      _scopeStats.cycleEnd();
      _transitionState(STATE_FLUSH, null);
    }
  }

  String get state => _state;

  void _transitionState(String from, String to) {
    if (_state != from) throw "$_state already in progress can not enter $to.";
    _state = to;
  }

}