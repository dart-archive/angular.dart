part of angular;

/**
 * A better zone API which implements onTurnDone.
 */
class Zone {
  bool _runningInZone = false;

  /**
   * A function that is called at the end of each VM turn in which the
   * in-zone code or any runAsync callbacks were run.
   */
  Function onTurnDone = () => null;

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
      _runningInZone = true;
      try {
        returnValueFromZone = interceptCall(body);
        _tryDone();
      } finally {
        _runningInZone = false;
      }
    },
    onRunAsync: (delegate()) {
      _asyncCount++;
      async.runAsync(() {
        _runningInZone = true;
        try {
          interceptCall(delegate);
          // This runAsync body is run in the parent zone.  If
          // we are going to run onTurnDone, we need to zone it.
          _tryDone(true);
        } finally {
          _runningInZone = false;
        }
      });
    }, onError:(e) {
      // Save the exception so we can throw it in the parent zone.
      // This only works if we caught the exception in the synchronous
      // run() call.
      exceptionFromZone = e;
      // Print the exception as well because we aren't sure where it
      // will show up.
      print('EXCEPTION: $e\n${async.getAttachedStackTrace(e)}}');
    });

    if (exceptionFromZone != null) {
      throw exceptionFromZone;
    }
    return returnValueFromZone;
  }

  assertInZone() {
    if (!_runningInZone) {
      throw new Exception("Function must be called in a zone");
    }
  }
}
