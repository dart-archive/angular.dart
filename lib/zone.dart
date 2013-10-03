library angular.core.service.zone;

import 'dart:async' as async;
import 'dart:mirrors' as mirrors;

typedef void ZoneOnTurn();
typedef void ZoneOnError(dynamic error, dynamic stacktrace, LongStackTrace longStacktrace);

/**
 * Contains the locations of runAsync calls across VM turns.
 */
class LongStackTrace {
  final String reason;
  final dynamic stacktrace;
  final LongStackTrace parent;

  LongStackTrace(this.reason, this.stacktrace, this.parent);

  toString() {
    List<String> frames = '${this.stacktrace}'.split('\n');
    frames = frames.where((frame) {
      return frame.indexOf('(dart:') == -1 && // skip dart runtime libs
             frame.indexOf('(package:angular/zone.dart') == -1; // skip angular zone
    }).toList();
    frames.insert(0, reason);
    var parent = this.parent == null ? '' : this.parent;
    return '${frames.join("\n    ")}\n$parent';
  }
}

/**
 * A better zone API which implements onTurnDone.
 */
class Zone {
  static var _ZONE_CHECK = "Function must be called in a zone.";
  bool _runningInTurn = false;

  /**
   * A function that is called at the end of each VM turn in which the
   * in-zone code or any runAsync callbacks were run.
   */
  var onTurnDone = () => null;  // Type was ZoneOnTurn: dartbug 13519

  /**
   * A function that is called when uncaught errors are thrown inside the zone.
   */
  var onError = (dynamic e, dynamic s, LongStackTrace ls) => print('EXCEPTION: $e\n$s\n$ls');
  // Type was ZoneOnError: dartbug 13519

  /**
   * Called with each zone.run or runAsync method.  This allows the program
   * to modify state during a call.
  */
  Function interceptCall = (body) => body();

  LongStackTrace _longStacktrace = null;

  var _asyncCount = 0;
  // If tryDone is called from the parent zone, it will have runInNewZone = true
  // This function will create a new zone if it calls onTurnDone.
  _tryDone([runInNewZone = false]) {
    if ((--_asyncCount) == 0) {
      if (runInNewZone) {
        // This run call will trigger a synchronous onTurnDone.
        run((){});
      } else {
        onTurnDone();
      }
    } else if (_asyncCount < 0) {
      // TODO(deboer): Remove []s when dartbug.com/11999 is fixed.
      throw ["bad asyncCount $_asyncCount"];
    }
  }

  LongStackTrace _getLongStacktrace(name) {
    var shortStacktrace = 'Long-stacktraces supressed in production.';
    assert((shortStacktrace = _getStacktrace()) != null);
    return new LongStackTrace(name, shortStacktrace, _longStacktrace);
  }

  _getStacktrace() {
    try { throw []; } catch (e, s) {
      return s;
    }
  }

  /**
   * Runs the provided function in the zone.  Any runAsync calls (e.g. futures)
   * will also be run in this zone.
   *
   * Returns the return value of body.
   */
  run(body()) {
    var exceptionFromZone;
    var returnValueFromZone;
    _asyncCount++;
    async.runZonedExperimental(() {
      _runningInTurn = true;
      try {
        try {
          returnValueFromZone = interceptCall(body);
        } finally {
          _tryDone();
        }
      } finally {
        _runningInTurn = false;
      }
    },
    onRunAsync: (delegate()) {
      var longStacktrace = _getLongStacktrace('Location of: runAsync();');
      // assertInZone() should not trigger a onTurnDone call.  To prevent
      // this, we use the _inAssertInZone guard.
      var calledFromAssertInZone = _inAssertInZone;
      if (!_inAssertInZone) {
        _asyncCount++;
      }
      async.runAsync(() {
        _runningInTurn = true;
        try {
          try {
            interceptCall(() {
              var oldStacktrace = _longStacktrace;
              _longStacktrace = longStacktrace;
              try {
                return delegate();
              } finally {
                _longStacktrace = oldStacktrace;
              }
            });
            // This runAsync body is run in the parent zone.  If
            // we are going to run onTurnDone, we need to zone it.
          } finally {
            if (!calledFromAssertInZone) {
              _tryDone(true);
            }
          }
        } finally {
          _runningInTurn = false;
        }
      });
    }, onError:(e) {
      if (e is List && e[0] == _ZONE_CHECK) return;

      // Save the exception so we can throw it in the parent zone.
      // This only works if we caught the exception in the synchronous
      // run() call.
      exceptionFromZone = e;

      // Call the error handler.
      onError(e, async.getAttachedStackTrace(e), _longStacktrace);
    });

    if (exceptionFromZone != null) {
      throw exceptionFromZone;
    }
    return returnValueFromZone;
  }

  assertInTurn() {
    assert(_runningInTurn);
  }

  var _assertInZoneStack =
      'Stack traces are disabled for performance.  ' +
      'See angular:lib/zone.dart to re-enable them.';
  var _inAssertInZone = false;
  assertInZone() {
    assert((() {
      // Uncomment the next line to have stack traces attached to
      // assertInZone() errors.
      // try { throw ""; } catch (e,s) { _assertInZoneStack = s; }
      _inAssertInZone = true;
      async.runAsync(() { throw [_ZONE_CHECK, _assertInZoneStack]; });
      _inAssertInZone = false;
      return true;
    })());
  }
}
