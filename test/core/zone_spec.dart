library zone_spec;

import '../_specs.dart';

import 'dart:async';

main() => describe('zone', () {
  var zone;
  var exceptionHandler;
  beforeEach(module((Module module) {
    exceptionHandler = new LoggingExceptionHandler();
    module.value(ExceptionHandler, exceptionHandler);
  }));

  beforeEach(inject((Logger log, ExceptionHandler eh) {
    zone = new Zone();
    zone.onTurnDone = () {
      log('onTurnDone');
    };
    zone.onError = (e, s, ls) => eh(e, s);
  }));


  describe('exceptions', () {
    it('should rethrow exceptions from the body and call onError', () {
      var error;
      zone.onError = (e, s, l) => error = e;
      expect(() {
        zone.run(() {
          throw ['hello'];
        });
      }).toThrow('hello');
      expect(error).toEqual(['hello']);
    });


    it('should call onError for errors from runAsync', async(inject(() {
      zone.run(() {
        runAsync(() {
          throw ["async exception"];
        });
      });

      expect(exceptionHandler.errors.length).toEqual(1);
      expect(exceptionHandler.errors[0].error).toEqual(["async exception"]);
    })));


    it('should rethrow exceptions from the onTurnDone and call onError when the zone is sync', () {
      zone.onTurnDone = () {
        throw ["fromOnTurnDone"];
      };

      expect(() {
        zone.run(() { });
      }).toThrow('fromOnTurnDone');

      expect(exceptionHandler.errors.length).toEqual(1);
      expect(exceptionHandler.errors[0].error).toEqual(["fromOnTurnDone"]);
    });


    it('should rethrow exceptions from the onTurnDone and call onError when the zone is async', () {
      var asyncRan = false;

      zone.onTurnDone = () {
        throw ["fromOnTurnDone"];
      };

      expect(() {
        zone.run(() {
          runAsync(() {
            asyncRan = true;
          });
        });
      }).toThrow('fromOnTurnDone');

      expect(asyncRan).toBeTruthy();
      expect(exceptionHandler.errors.length).toEqual(1);
      expect(exceptionHandler.errors[0].error).toEqual(["fromOnTurnDone"]);
    });
  });

  xdescribe('long stack traces', () {
    it('should have nice error when crossing runAsync boundries', async(inject(() {
      var error;
      var stack;
      var longStacktrace;

      zone.onError = (e, s, f) {
        error = e;
        stack = s;
        longStacktrace = f;
      };
      var FRAME = new RegExp(r'.*\(.*\:(\d+):\d+\)');

      var line = ((){ try {throw [];} catch(e, s) { return int.parse(FRAME.firstMatch('$s')[1]);}})();
      var throwFn = () { throw ['double zonned']; };
      var inner = () => zone.run(throwFn);
      var middle = () => runAsync(inner);
      var outer = () => runAsync(middle);
      zone.run(outer);

      microLeap();
      expect(error).toEqual(['double zonned']);

      // Not in dart2js..
      if ('$stack'.contains('.dart.js')) {
        return;
      }

      expect('$stack').toContain('zone_spec.dart:${line+1}');
      expect('$stack').toContain('zone_spec.dart:${line+2}');
      expect('$longStacktrace').toContain('zone_spec.dart:${line+3}');
      expect('$longStacktrace').toContain('zone_spec.dart:${line+4}');
      expect('$longStacktrace').toContain('zone_spec.dart:${line+5}');
    })));
  });

  it('should call onTurnDone after a synchronous block', inject((Logger log) {
    zone.run(() {
      log('run');
    });
    expect(log.result()).toEqual('run; onTurnDone');
  }));


  it('should return the body return value from run', () {
    expect(zone.run(() { return 6; })).toEqual(6);
  });


  it('should call onTurnDone for a runAsync in onTurnDone', async(inject((Logger log) {
    var ran = false;
    zone.onTurnDone = () {
      if (!ran) {
        runAsync(() { ran = true; log('onTurnAsync'); });
      }
      log('onTurnDone');
    };
    zone.run(() {
      log('run');
    });
    microLeap();

    expect(log.result()).toEqual('run; onTurnDone; onTurnAsync; onTurnDone');
  })));


  it('should call onTurnDone for a runAsync in onTurnDone triggered by a runAsync in run', async(inject((Logger log) {
    var ran = false;
    zone.onTurnDone = () {
      if (!ran) {
        runAsync(() { ran = true; log('onTurnAsync'); });
      }
      log('onTurnDone');
    };
    zone.run(() {
      runAsync(() { log('runAsync'); });
      log('run');
    });
    microLeap();

    expect(log.result()).toEqual('run; runAsync; onTurnDone; onTurnAsync; onTurnDone');
  })));



  it('should call onTurnDone once after a turn', async(inject((Logger log) {
    zone.run(() {
      log('run start');
      runAsync(() {
        log('async');
      });
      log('run end');
    });
    microLeap();

    expect(log.result()).toEqual('run start; run end; async; onTurnDone');
  })));


  it('should work for Future.value as well', async(inject((Logger log) {
    var futureRan = false;
    zone.onTurnDone = () {
      if (!futureRan) {
        new Future.value(null).then((_) { log('onTurn future'); });
        futureRan = true;
      }
      log('onTurnDone');
    };

    zone.run(() {
      log('run start');
      new Future.value(null)
        .then((_) {
          log('future then');
          new Future.value(null)
            .then((_) { log('future ?'); });
          return new Future.value(null);
        })
        .then((_) {
          log('future ?');
        });
      log('run end');
    });
    microLeap();

    expect(log.result()).toEqual('run start; run end; future then; future ?; future ?; onTurnDone; onTurn future; onTurnDone');
  })));


  it('should call onTurnDone after each turn', async(inject((Logger log) {
    Completer a, b;
    zone.run(() {
      a = new Completer();
      b = new Completer();
      a.future.then((_) => log('a then'));
      b.future.then((_) => log('b then'));
      log('run start');
    });
    microLeap();
    zone.run(() {
      a.complete(null);
    });
    microLeap();
    zone.run(() {
      b.complete(null);
    });
    microLeap();

    expect(log.result()).toEqual('run start; onTurnDone; a then; onTurnDone; b then; onTurnDone');
  })));


  it('should call onTurnDone after each turn in a chain', async(inject((Logger log) {
    zone.run(() {
      log('run start');
      runAsync(() {
        log('async1');
        runAsync(() {
          log('async2');
        });
      });
      log('run end');
    });
    microLeap();

    expect(log.result()).toEqual('run start; run end; async1; async2; onTurnDone');
  })));

  it('should call onTurnDone for futures created outside of run body', async(inject((Logger log) {
    var future = new Future.value(4).then((x) => new Future.value(x));
    zone.run(() {
      future.then((_) => log('future then'));
      log('zone run');
    });
    microLeap();

    expect(log.result()).toEqual('zone run; onTurnDone; future then; onTurnDone');
  })));


  it('should call onTurnDone even if there was an exception in body', async(inject((Logger log) {
    zone.onError = (e, s, l) => log('onError');
    expect(() => zone.run(() {
      log('zone run');
      throw 'zoneError';
    })).toThrow('zoneError');
    expect(() => zone.assertInTurn()).toThrow();
    expect(log.result()).toEqual('zone run; onError; onTurnDone');
  })));


  it('should call onTurnDone even if there was an exception in runAsync', async(inject((Logger log) {
    zone.onError = (e, s, l) => log('onError');
    zone.run(() {
      log('zone run');
      runAsync(() {
        log('runAsync');
        throw new Error();
      });
    });

    microLeap();

    expect(() => zone.assertInTurn()).toThrow();
    expect(log.result()).toEqual('zone run; runAsync; onError; onTurnDone');
  })));

  it('should support assertInZone', async(() {
    var calls = '';
    zone.onTurnDone = () {
      zone.assertInZone();
      calls += 'done;';
    };
    zone.run(() {
      zone.assertInZone();
      calls += 'sync;';
      runAsync(() {
        zone.assertInZone();
        calls += 'async;';
      });
    });

    microLeap();
    expect(calls).toEqual('sync;async;done;');
  }));

  it('should throw outside of the zone', () {
    expect(async(() {
      zone.assertInZone();
      microLeap();
    })).toThrow();
  });


  it('should support assertInTurn', async(() {
    var calls = '';
    zone.onTurnDone = () {
      calls += 'done;';
      zone.assertInTurn();
    };
    zone.run(() {
      calls += 'sync;';
      zone.assertInTurn();
      runAsync(() {
        calls += 'async;';
        zone.assertInTurn();
      });
    });

    microLeap();
    expect(calls).toEqual('sync;async;done;');
  }));


  it('should assertInTurn outside of the zone', () {
    expect(async(() {
      zone.assertInTurn();
      microLeap();
    })).toThrow('ssertion');  // Support both dart2js and the VM with half a word.
  });
});
