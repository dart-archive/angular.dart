part of angular;

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
  Function onTurnDone = () => null;

  /**
   * A function that is called when uncaught errors are thrown inside the zone.
   */
  Function onError = (e) => print('EXCEPTION: $e\n${async.getAttachedStackTrace(e)}');

  /**
   * Called with each zone.run or runAsync method.  This allows the program
   * to modify state during a call.
  */
  Function interceptCall = (body) => body();

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
            interceptCall(delegate);
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
      onError(e);
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
