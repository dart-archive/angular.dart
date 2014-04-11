part of angular.core_internal;

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
class VmTurnZone {
  final async.Zone _outerZone = async.Zone.current;
  async.Zone _zone;

  VmTurnZone() {
    _zone = _outerZone.fork(specification: new async.ZoneSpecification(
        run: _onRun,
        runUnary: _onRunUnary,
        scheduleMicrotask: _onScheduleMicrotask,
        handleUncaughtError: _uncaughtError
    ));
    // Prevent silently ignoring uncaught exceptions by forwarding such
    // exceptions to the outer zone by default.
    onError = (e, s, ls) => _outerZone.handleUncaughtError(e, s);
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
   * A function called with any errors from the zone.
   */
  var onError = (e, s, ls) => print('$e\n$s\n$ls');

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

  StackTrace _getStacktrace() {
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
  dynamic run(body()) => _zone.run(body);

  /**
   * Allows one to escape the auto-digest mechanism of Angular.
   *
   *     myFunction(VmTurnZone zone, Element element) {
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

  void assertInTurn() {
    assert(_runningInTurn > 0 || _inFinishTurn);
  }

  void assertInZone() {
    assertInTurn();
  }
}
