part of angular.core;

typedef void ZoneOnTurn();
typedef void ZoneOnError(dynamic error, dynamic stacktrace,
                         LongStackTrace longStacktrace);

/**
 * Contains the locations of runAsync calls across VM turns.
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
 * A better zone API which implements onTurnDone.
 */
class NgZone {
  NgZone() {
    _zone = async.Zone.current.fork(specification: new async.ZoneSpecification(
        run: _onRun,
        runUnary: _onRunUnary,
        scheduleMicrotask: _onScheduleMicrotask,
        handleUncaughtError: _uncaughtError
    ));
  }

  async.Zone _zone;

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
      // the outer runs onTurnDone (e.g. scope.$digest) and then
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
   * A function called with any errors from the zone.
   */
  var onError = (e, s, ls) => null;

  /**
   * A function that is called at the end of each VM turn in which the
   * in-zone code or any runAsync callbacks were run.
   */
  var onTurnDone = () => null;  // Type was ZoneOnTurn: dartbug 13519

  /**
   * A function that is called when uncaught errors are thrown inside the zone.
   */
  // var onError = (dynamic e, dynamic s, LongStackTrace ls) => print('EXCEPTION: $e\n$s\n$ls');
  // Type was ZoneOnError: dartbug 13519

  LongStackTrace _longStacktrace = null;

  LongStackTrace _getLongStacktrace(name) {
    var shortStacktrace = 'Long-stacktraces supressed in production.';
    assert((shortStacktrace = _getStacktrace()) != null);
    return new LongStackTrace(name, shortStacktrace, _longStacktrace);
  }

  _getStacktrace() {
    try {
      throw [];
    } catch (e, s) {
      return s;
    }
  }

  /**
   * Runs the provided function in the zone.  Any runAsync calls (e.g. futures)
   * will also be run in this zone.
   *
   * Returns the return value of body.
   */
  run(body()) => _zone.run(body);

  assertInTurn() {
    assert(_runningInTurn > 0 || _inFinishTurn);
  }

  assertInZone() {
    assertInTurn();
  }
}
