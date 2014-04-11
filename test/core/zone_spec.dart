library zone_spec;

import '../_specs.dart';

import 'dart:async';

void main() {
  describe('zone', () {
    var zone;
    var exceptionHandler;
    beforeEachModule((Module module) {
      exceptionHandler = new LoggingExceptionHandler();
      module.value(ExceptionHandler, exceptionHandler);
    });

    beforeEach((Logger log, ExceptionHandler eh) {
      zone = new VmTurnZone();
      zone.onTurnDone = () {
        log('onTurnDone');
      };
      zone.onError = (e, s, ls) => eh(e, s);
    });


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


      it('should call onError for errors from scheduleMicrotask', async(() {
        zone.run(() {
          scheduleMicrotask(() {
            throw ["async exception"];
          });
        });

        expect(exceptionHandler.errors.length).toEqual(1);
        expect(exceptionHandler.errors[0].error).toEqual(["async exception"]);
      }));


      it('should allow executing code outside the zone', () {
        var zone = new VmTurnZone();
        var outerZone = Zone.current;
        var ngZone;
        var outsideZone;
        zone.run(() {
          ngZone = Zone.current;
          zone.runOutsideAngular(() {
            outsideZone = Zone.current;
          });
        });

        expect(outsideZone).toEqual(outerZone);
        expect(ngZone.parent).toEqual((outerZone));
      });


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
            scheduleMicrotask(() {
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
      it('should have nice error when crossing scheduleMicrotask boundries', async(() {
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
        var middle = () => scheduleMicrotask(inner);
        var outer = () => scheduleMicrotask(middle);
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
      }));
    });

    it('should call onTurnDone after a synchronous view', (Logger log) {
      zone.run(() {
        log('run');
      });
      expect(log.result()).toEqual('run; onTurnDone');
    });


    it('should return the body return value from run', () {
      expect(zone.run(() { return 6; })).toEqual(6);
    });


    it('should call onTurnDone for a scheduleMicrotask in onTurnDone', async((Logger log) {
      var ran = false;
      zone.onTurnDone = () {
        if (!ran) {
          scheduleMicrotask(() { ran = true; log('onTurnAsync'); });
        }
        log('onTurnDone');
      };
      zone.run(() {
        log('run');
      });
      microLeap();

      expect(log.result()).toEqual('run; onTurnDone; onTurnAsync; onTurnDone');
    }));


    it('should call onTurnDone for a scheduleMicrotask in onTurnDone triggered by a scheduleMicrotask in run', async((Logger log) {
      var ran = false;
      zone.onTurnDone = () {
        if (!ran) {
          scheduleMicrotask(() { ran = true; log('onTurnAsync'); });
        }
        log('onTurnDone');
      };
      zone.run(() {
        scheduleMicrotask(() { log('scheduleMicrotask'); });
        log('run');
      });
      microLeap();

      expect(log.result()).toEqual('run; scheduleMicrotask; onTurnDone; onTurnAsync; onTurnDone');
    }));



    it('should call onTurnDone once after a turn', async((Logger log) {
      zone.run(() {
        log('run start');
        scheduleMicrotask(() {
          log('async');
        });
        log('run end');
      });
      microLeap();

      expect(log.result()).toEqual('run start; run end; async; onTurnDone');
    }));


    it('should work for Future.value as well', async((Logger log) {
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
    }));


    it('should call onTurnDone after each turn', async((Logger log) {
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
    }));


    it('should call onTurnDone after each turn in a chain', async((Logger log) {
      zone.run(() {
        log('run start');
        scheduleMicrotask(() {
          log('async1');
          scheduleMicrotask(() {
            log('async2');
          });
        });
        log('run end');
      });
      microLeap();

      expect(log.result()).toEqual('run start; run end; async1; async2; onTurnDone');
    }));

    it('should call onTurnDone for futures created outside of run body', async((Logger log) {
      var future = new Future.value(4).then((x) => new Future.value(x));
      zone.run(() {
        future.then((_) => log('future then'));
        log('zone run');
      });
      microLeap();

      expect(log.result()).toEqual('zone run; onTurnDone; future then; onTurnDone');
    }));


    it('should call onTurnDone even if there was an exception in body', async((Logger log) {
      zone.onError = (e, s, l) => log('onError');
      expect(() => zone.run(() {
        log('zone run');
        throw 'zoneError';
      })).toThrow('zoneError');
      expect(() => zone.assertInTurn()).toThrow();
      expect(log.result()).toEqual('zone run; onError; onTurnDone');
    }));


    it('should call onTurnDone even if there was an exception in scheduleMicrotask', async((Logger log) {
      zone.onError = (e, s, l) => log('onError');
      zone.run(() {
        log('zone run');
        scheduleMicrotask(() {
          log('scheduleMicrotask');
          throw new Error();
        });
      });

      microLeap();

      expect(() => zone.assertInTurn()).toThrow();
      expect(log.result()).toEqual('zone run; scheduleMicrotask; onError; onTurnDone');
    }));

    it('should support assertInZone', async(() {
      var calls = '';
      zone.onTurnDone = () {
        zone.assertInZone();
        calls += 'done;';
      };
      zone.run(() {
        zone.assertInZone();
        calls += 'sync;';
        scheduleMicrotask(() {
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
        scheduleMicrotask(() {
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
}
