part of angular.core_internal;

/**
 * Handles an [NgZone] onTurnDone event.
 */
typedef void ZoneOnTurn();

/**
 * Handles an [NgZone] onError event.
 */
typedef void ZoneOnError(dynamic error, dynamic stacktrace,
                         LongStackTrace longStacktrace);

/**
 * Contains the locations of async calls across VM turns.
 */
class LongStackTrace {
  final String reason;
  final dynamic stacktrace;
  final LongStackTrace parent;

  LongStackTrace(this.reason, this.stacktrace, this.parent);

  toString() {
    List<String> frames = '${this.stacktrace}'.split('\n')
        .where((frame) =>
            frame.indexOf('(dart:') == -1 && // skip dart runtime libs
            frame.indexOf('(package:angular/zone.dart') == -1 // skip angular zone
        ).toList()..insert(0, reason);
    var parent = this.parent == null ? '' : this.parent;
    return '${frames.join("\n    ")}\n$parent';
  }
}

/**
 * A [Zone] wrapper that lets you schedule tasks after its private microtask
 * queue is exhausted but before the next "turn", i.e. event loop iteration.
 * This lets you freely schedule microtasks that prepare data, and set an
 * [onTurnDone] handler that will consume that data after it's ready but before
 * the browser has a chance to re-render.
 * The wrapper maintains an "inner" and "outer" [Zone] and a private queue of
 * all the microtasks scheduled on the inner [Zone].
 *
 * In a typical app, [ngDynamicApp] or [ngStaticApp] will create a singleton
 * [NgZone] whose outer [Zone] is the root [Zone] and whose default [onTurnDone]
 * runs the Angular digest.  A component may want to inject this singleton if it
 * needs to run code _outside_ the Angular digest.
 */
class NgZone {
  /// an "outer" [Zone], which is the one that created this.
  async.Zone _outerZone;

  /// an "inner" [Zone], which is a child of the outer [Zone].
  async.Zone _innerZone;

  /**
   * Associates with this
   *
   * Defaults [onError] to forward errors to the outer [Zone].
   * Defaults [onTurnDone] to a no-op.
   */
  NgZone() {
    _outerZone = async.Zone.current;
    _innerZone = _outerZone.fork(specification: new async.ZoneSpecification(
        run: _onRun,
        runUnary: _onRunUnary,
        scheduleMicrotask: _onScheduleMicrotask,
        handleUncaughtError: _uncaughtError
    ));
    onError = _defaultOnError;
    onTurnDone = _defaultOnTurnDone;
  }

  List _asyncQueue = [];
  bool _errorThrownFromOnRun = false;

  _onRunBase(async.Zone self, async.ZoneDelegate delegate, async.Zone zone, fn()) {
    _runningInTurn++;
    try {
      return fn();
    } catch (e, s) {
      onError(e, s, _longStacktrace);
      _errorThrownFromOnRun = true;
      rethrow;
    } finally {
      _runningInTurn--;
      if (_runningInTurn == 0) _finishTurn(zone, delegate);
    }
  }
  // Called from the parent zone.
  _onRun(async.Zone self, async.ZoneDelegate delegate, async.Zone zone, fn()) =>
      _onRunBase(self, delegate, zone, () => delegate.run(zone, fn));

  _onRunUnary(async.Zone self, async.ZoneDelegate delegate, async.Zone zone,
              fn(args), args) =>
      _onRunBase(self, delegate, zone, () => delegate.runUnary(zone, fn, args));

  _onScheduleMicrotask(async.Zone self, async.ZoneDelegate delegate,
                       async.Zone zone, fn()) {
    _asyncQueue.add(() => delegate.run(zone, fn));
    if (_runningInTurn == 0 && !_inFinishTurn)  _finishTurn(zone, delegate);
  }

  _uncaughtError(async.Zone self, async.ZoneDelegate delegate, async.Zone zone,
                 e, StackTrace s) {
    if (!_errorThrownFromOnRun) onError(e, s, _longStacktrace);
    _errorThrownFromOnRun = false;
  }

  var _inFinishTurn = false;
  _finishTurn(zone, delegate) {
    if (_inFinishTurn) return;
    _inFinishTurn = true;
    try {
      // Two loops here: the inner one runs all queued microtasks,
      // the outer runs onTurnDone (e.g. scope.digest) and then
      // any microtasks which may have been queued from onTurnDone.
      do {
        while (!_asyncQueue.isEmpty) {
          delegate.run(zone, _asyncQueue.removeAt(0));
        }
        delegate.run(zone, onTurnDone);
      } while (!_asyncQueue.isEmpty);
    } catch (e, s) {
      onError(e, s, _longStacktrace);
      _errorThrownFromOnRun = true;
      rethrow;
    } finally {
      _inFinishTurn = false;
    }
  }

  int _runningInTurn = 0;

  /**
   * Called with any errors from the inner zone.
   */
  ZoneOnError onError;

  /// Prevent silently ignoring uncaught exceptions by forwarding such exceptions to the outer zone.
  void _defaultOnError(dynamic e, dynamic s, LongStackTrace ls) =>
      _outerZone.handleUncaughtError(e, s);

  /**
   * Called at the end of each VM turn in which inner zone code runs.
   * "At the end" means after the private microtask queue of the inner zone is
   * exhausted but before the next VM turn.  Notes
   * - This won't wait for microtasks scheduled in zones other than the inner
   *   zone, e.g. those scheduled with [runOutsideAngular].
   * - [onTurnDone] runs repeatedly until it fails to schedule any more
   *   microtasks, so you usually don't want it to schedule any.  For example,
   *   if its first line of code is `new Future.value()`, the turn will _never_
   *   end.
   */
  ZoneOnTurn onTurnDone;
  void _defaultOnTurnDone() => null;

  LongStackTrace _longStacktrace = null;

  LongStackTrace _getLongStacktrace(name) {
    var shortStacktrace = 'Long-stacktraces supressed in production.';
    assert((shortStacktrace = _getStacktrace()) != null);
    return new LongStackTrace(name, shortStacktrace, _longStacktrace);
  }

  StackTrace _getStacktrace() {
    try {
      throw [];
    } catch (e, s) {
      return s;
    }
  }

  /**
   * Runs [body] in the inner zone and returns whatever it returns.
   */
  dynamic run(body()) => _innerZone.run(body);

  /**
   * Runs [body] in the outer zone and returns whatever it returns.
   * In a typical app where the inner zone is the Angular zone, this allows
   * one to escape Angular's auto-digest mechanism.
   *
   *     myFunction(NgZone zone, Element element) {
   *       element.onClick.listen(() {
   *         // auto-digest will run after element click.
   *       });
   *       zone.runOutsideAngular(() {
   *         element.onMouseMove.listen(() {
   *           // auto-digest will NOT run after mouse move
   *         });
   *       });
   *     }
   */
  dynamic runOutsideAngular(body()) => _outerZone.run(body);

  /**
   * Throws an [AssertionError] if no task is currently running in the inner
   * zone.  In a typical app where the inner zone is the Angular zone, this can
   * be used to assert that the digest will indeed run at the end of the current
   * turn.
   */
  void assertInTurn() {
    assert(_runningInTurn > 0 || _inFinishTurn);
  }

  /**
   * Same as [assertInTurn].
   */
  void assertInZone() {
    assertInTurn();
  }
}
