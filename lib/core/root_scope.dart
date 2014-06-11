part of angular.core_internal;

/**
 *
 * Every Angular application has exactly one RootScope. RootScope extends Scope, adding
 * services related to change detection, async unit-of-work processing, and DOM read/write queues.
 * The RootScope can not be destroyed.
 *
 * ## Lifecycle
 *
 * All work in Angular must be done within a context of a VmTurnZone. VmTurnZone detects the end
 * of the VM turn, and calls the Apply method to process the changes at the end of VM turn.
 *
 */
@Injectable()
class RootScope extends Scope {
  final ExceptionHandler _exceptionHandler;
  final ASTParser _astParser;
  final Parser _parser;
  final ScopeDigestTTL _ttl;
  final VmTurnZone _zone;

  _FunctionChain _runAsyncHead, _runAsyncTail;
  _FunctionChain _domWriteHead, _domWriteTail;
  _FunctionChain _domReadHead, _domReadTail;

  String _state;

  final ScopeStats _scopeStats;
  Scheduler _scheduler;
  LifeCycle _lifeCycle;

  /**
   *
   * While processing data bindings, Angular passes through multiple states. When testing or
   * debugging, it can be useful to access the current `state`, which is one of the following:
   *
   * * null
   * * apply
   * * digest
   * * flush
   * * assert
   *
   * ##null
   *
   *  Angular is not currently processing changes
   *
   * ##apply
   *
   * The apply state begins by executing the optional expression within the context of
   * angular change detection mechanism. Any exceptions are delegated to [ExceptionHandler]. At the
   * end of apply state RootScope enters the digest followed by flush phase (optionally if asserts
   * enabled run assert phase.)
   *
   * ##digest
   *
   * The apply state begins by processing the async queue,
   * followed by change detection
   * on non-DOM listeners. Any changes detected are process using the reaction function. The digest
   * phase is repeated as long as at least one change has been detected. By default, after 5
   * iterations the model is considered unstable and angular exists with an exception. (See
   * ScopeDigestTTL)
   *
   * ##flush
   *
   * The flush phase consists of these steps:
   *
   * 1. processing the DOM write queue
   * 2. change detection on DOM only updates (these are reaction functions which must
   *    not change the model state and hence don't need stabilization as in digest phase).
   * 3. processing the DOM read queue
   * 4. repeat steps 1 and 3 (not 2) until queues are empty
   *
   * ##assert
   *
   * Optionally if Dart assert is on, verify that flush reaction functions did not make any changes
   * to model and throw error if changes detected.
   *
   */
  String get state => _lifeCycle.state;

  RootScope(Object context, Parser parser, ASTParser astParser, FieldGetterFactory fieldGetterFactory,
            FormatterMap formatters, this._exceptionHandler, this._ttl, this._zone, this._scheduler,
            ScopeStats _scopeStats)
    : _scopeStats = _scopeStats,
    _parser = parser,
    _astParser = astParser,
    super(context, null, null,
    new RootWatchGroup(fieldGetterFactory,
    new DirtyCheckingChangeDetector(fieldGetterFactory), context),
    new RootWatchGroup(fieldGetterFactory,
    new DirtyCheckingChangeDetector(fieldGetterFactory), context),
    '',
    _scopeStats)
  {
    _lifeCycle = new LifeCycle(_flushGroup, _digestGroup, _ttl, _scopeStats, _scheduler,
        _exceptionHandler);
    _zone.onTurnDone = apply;
    _zone.onError = (e, s, ls) => _exceptionHandler(e, s);
  }

  RootScope get rootScope => this;

  /**
   * Propagates changes between different parts of the application model. Normally called by
   * [VMTurnZone] right before DOM rendering to initiate data binding. May also be called directly
   * for unit testing.
   */
  void digest() => _lifeCycle.digest();

  void flush() => _lifeCycle.flush();

  void destroy() {}

  void domRead(fn) => _scheduler.domRead(fn);

  void domWrite(fn) => _scheduler.domWrite(fn);

  void runAsync(fn) => _scheduler.runAsync(fn);

  void ensureStartCycle() => _lifeCycle._transitionState(null, LifeCycle.STATE_APPLY);

  void ensureEndCycle() => _lifeCycle._transitionState(LifeCycle.STATE_APPLY, null);
}
