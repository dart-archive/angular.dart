library zone_spec;

import '../_specs.dart';

import 'dart:async';

void main() {
  describe('zone', () {
    var zone;
    var exceptionHandler;
    beforeEachModule((Module module) {
      exceptionHandler = new LoggingExceptionHandler();
      module.bind(ExceptionHandler, toValue: exceptionHandler);
    });

    beforeEach((Logger log, ExceptionHandler eh) {
      zone = new VmTurnZone();
      zone.onTurnDone = () {
        log('onTurnDone');
      };
      zone.onTurnStart = () {
        log('onTurnStart');
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
      expect(log.result()).toEqual('onTurnStart; run; onTurnDone');
    });


    it('should return the body return value from run', () {
      expect(zone.run(() { return 6; })).toEqual(6);
    });


    it('should call onTurnStart before executing a microtask scheduled in onTurnDone as well as '
        'onTurnDone after executing the task', async((Logger log) {
      var ran = false;
      zone.onTurnDone = () {
        log('onTurnDone(begin)');
        if (!ran) {
          scheduleMicrotask(() { ran = true; log('executedMicrotask'); });
        }
        log('onTurnDone(end)');
      };
      zone.run(() {
        log('run');
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart; run; onTurnDone(begin); onTurnDone(end); onTurnStart; executedMicrotask; onTurnDone(begin); onTurnDone(end)');
    }));


    it('should call onTurnStart and onTurnDone for a scheduleMicrotask in onTurnDone triggered by a scheduleMicrotask in run', async((Logger log) {
      var ran = false;
      zone.onTurnDone = () {
        log('onTurnDone(begin)');
        if (!ran) {
          log('onTurnDone(scheduleMicrotask)');
          scheduleMicrotask(() {
            ran = true;
            log('onTurnDone(executeMicrotask)');
          });
        }
        log('onTurnDone(end)');
      };
      zone.run(() {
        log('scheduleMicrotask');
        scheduleMicrotask(() {
          log('run(executeMicrotask)');
        });
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart; scheduleMicrotask; run(executeMicrotask); onTurnDone(begin); onTurnDone(scheduleMicrotask); onTurnDone(end); onTurnStart; onTurnDone(executeMicrotask); onTurnDone(begin); onTurnDone(end)');
    }));



    it('should call onTurnStart once before a turn and onTurnDone once after the turn', async((Logger log) {
      zone.run(() {
        log('run start');
        scheduleMicrotask(() {
          log('async');
        });
        log('run end');
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart; run start; run end; async; onTurnDone');
    }));


    it('should work for Future.value as well', async((Logger log) {
      var futureRan = false;
      zone.onTurnDone = () {
        log('onTurnDone(begin)');
        if (!futureRan) {
          log('onTurnDone(scheduleFuture)');
          new Future.value(null).then((_) { log('onTurnDone(executeFuture)'); });
          futureRan = true;
        }
        log('onTurnDone(end)');
      };

      zone.run(() {
        log('run start');
        new Future.value(null)
        .then((_) {
          log('future then');
          new Future.value(null)
          .then((_) { log('future foo'); });
          return new Future.value(null);
        })
        .then((_) {
          log('future bar');
        });
        log('run end');
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart; run start; run end; future then; future foo; future bar; onTurnDone(begin); onTurnDone(scheduleFuture); onTurnDone(end); onTurnStart; onTurnDone(executeFuture); onTurnDone(begin); onTurnDone(end)');
    }));

    it('should execute futures scheduled in onTurnStart before Futures scheduled in run', async((Logger log) {
      var doneFutureRan = false;
      var startFutureRan = false;
      zone.onTurnStart = () {
        log('onTurnStart(begin)');
        if (!startFutureRan) {
          log('onTurnStart(scheduleFuture)');
          new Future.value(null).then((_) { log('onTurnStart(executeFuture)'); });
          startFutureRan = true;
        }
        log('onTurnStart(end)');
      };
      zone.onTurnDone = () {
        log('onTurnDone(begin)');
        if (!doneFutureRan) {
          log('onTurnDone(scheduleFuture)');
          new Future.value(null).then((_) { log('onTurnDone(executeFuture)'); });
          doneFutureRan = true;
        }
        log('onTurnDone(end)');
      };

      zone.run(() {
        log('run start');
        new Future.value(null)
        .then((_) {
          log('future then');
          new Future.value(null)
          .then((_) { log('future foo'); });
          return new Future.value(null);
        })
        .then((_) {
          log('future bar');
        });
        log('run end');
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart(begin); onTurnStart(scheduleFuture); onTurnStart(end); run start; run end; onTurnStart(executeFuture); future then; future foo; future bar; onTurnDone(begin); onTurnDone(scheduleFuture); onTurnDone(end); onTurnStart(begin); onTurnStart(end); onTurnDone(executeFuture); onTurnDone(begin); onTurnDone(end)');
    }));


    it('should call onTurnStart and onTurnDone  before and after each turn, respectively', async((Logger log) {
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

      expect(log.result()).toEqual('onTurnStart; run start; onTurnDone; onTurnStart; a then; onTurnDone; onTurnStart; b then; onTurnDone');
    }));


    it('should call onTurnStart and onTurnDone before and after (respectively) all turns in a chain', async((Logger log) {
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

      expect(log.result()).toEqual('onTurnStart; run start; run end; async1; async2; onTurnDone');
    }));

    it('should call onTurnStart and onTurnDone for futures created outside of run body', async((Logger log) {
      var future = new Future.value(4).then((x) => new Future.value(x));
      zone.run(() {
        future.then((_) => log('future then'));
        log('zone run');
      });
      microLeap();

      expect(log.result()).toEqual('onTurnStart; zone run; onTurnDone; onTurnStart; future then; onTurnDone');
    }));


    it('should call onTurnDone even if there was an exception in body', async((Logger log) {
      zone.onError = (e, s, l) => log('onError');
      expect(() => zone.run(() {
        log('zone run');
        throw 'zoneError';
      })).toThrow('zoneError');
      expect(() => zone.assertInTurn()).toThrow();
      expect(log.result()).toEqual('onTurnStart; zone run; onError; onTurnDone');
    }));

    it('should call onTurnDone even if there was an exception in onTurnStart', async((Logger log) {
      zone.onError = (e, s, l) => log('onError');
      zone.onTurnStart = (){
        log('onTurnStart');
        throw 'zoneError';
      };
      expect(() => zone.run(() {
        log('zone run');
      })).toThrow('zoneError');
      expect(() => zone.assertInTurn()).toThrow();
      expect(log.result()).toEqual('onTurnStart; onError; onTurnDone');
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
      expect(log.result()).toEqual('onTurnStart; zone run; scheduleMicrotask; onError; onTurnDone');
    }));

    it('should support assertInZone', async(() {
      var calls = '';
      zone.onTurnStart = () {
        zone.assertInZone();
        calls += 'start;';
      };
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
      expect(calls).toEqual('start;sync;async;done;');
    }));

    it('should throw outside of the zone', () {
      expect(async(() {
        zone.assertInZone();
        microLeap();
      })).toThrow();
    });


    it('should support assertInTurn', async(() {
      var calls = '';
      zone.onTurnStart = () {
        zone.assertInTurn();
        calls += 'start;';
      };
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
      expect(calls).toEqual('start;sync;async;done;');
    }));


    it('should assertInTurn outside of the zone', () {
      expect(async(() {
        zone.assertInTurn();
        microLeap();
      })).toThrow('ssertion');  // Support both dart2js and the VM with half a word.
    });

    group('microtask scheduler', () {

      it('should execute microtask scheduled in onTurnDone before onTurnDone is complete',
          async((Logger log) {
        var microtaskResult = false;
        zone.onTurnStart = () {
          log('onTurnStart');
        };
        zone.onTurnDone = () {
          log('onTurnDone(begin)');
          scheduleMicrotask(() {
            log('executeMicrotask');
            return true;
          });
          log('onTurnDone(end)');
        };
        zone.onScheduleMicrotask = (microTaskFn) {
          log('onScheduleMicrotask(begin)');
          microtaskResult = microTaskFn();
          log('onScheduleMicrotask(end)');
        };
        zone.run(() {
          log('run');
        });

        expect(log.result()).toEqual('onTurnStart; run; onTurnDone(begin); '
          'onScheduleMicrotask(begin); executeMicrotask; onScheduleMicrotask(end); onTurnDone(end)'
        );
        expect(microtaskResult).toBeTruthy();
      }));

      it('should work with future scheduled in onTurnDone', async((Logger log) {
        zone.onTurnStart = () {
          log('onTurnStart');
        };
        zone.onTurnDone = () {
          log('onTurnDone(begin)');
          new Future.value('async').then((v) {
            log('executed ${v}');
          });
          log('onTurnDone(end)');
        };
        zone.onScheduleMicrotask = (microTaskFn) {
          log('onScheduleMicrotask(begin)');
          microTaskFn();
          log('onScheduleMicrotask(end)');
        };
        zone.run(() {
          log('run');
        });

        expect(log.result()).toEqual('onTurnStart; run; onTurnDone(begin); '
          'onScheduleMicrotask(begin); onScheduleMicrotask(end); onScheduleMicrotask(begin);'
          ' executed async; onScheduleMicrotask(end); onTurnDone(end)');
      }));

      it('should execute microtask scheduled in run before onTurnDone starts',
        async((Logger log) {
        zone.onTurnStart = () {
          log('onTurnStart');
        };
        zone.onTurnDone = () {
          log('onTurnDone');
        };
        zone.onScheduleMicrotask = (microTaskFn) {
          log('onScheduleMicrotask(begin)');
          microTaskFn();
          log('onScheduleMicrotask(end)');
        };
        zone.run(() {
          log('run');
          scheduleMicrotask(() {
            log('executeMicrotask');
            return true;
          });
        });

        expect(log.result()).toEqual('onTurnStart; run; onScheduleMicrotask(begin);'
          ' executeMicrotask; onScheduleMicrotask(end); onTurnDone');
      }));

      it('should execute microtask scheduled in onTurnStart before run',
        async((Logger log) {
        zone.onTurnStart = () {
          log('onTurnStart');
          scheduleMicrotask(() {
            log('executeMicrotask');
          });
        };
        zone.onTurnDone = () {
          log('onTurnDone');
        };
        zone.onScheduleMicrotask = (microTaskFn) {
          log('onScheduleMicrotask(begin)');
          microTaskFn();
          log('onScheduleMicrotask(end)');
        };
        zone.run(() {
          log('run');
        });

        expect(log.result()).toEqual('onTurnStart; onScheduleMicrotask(begin); executeMicrotask;'
          ' onScheduleMicrotask(end); run; onTurnDone');
      }));

      it('should execute microtask scheduled outside the turn', (Logger log) {
        zone = new VmTurnZone();

        var taskToRun = null;

        zone.onTurnDone = () {
          if (taskToRun != null) taskToRun();
          taskToRun = null;
          log('onTurnDone');
        };

        zone.onScheduleMicrotask = (microTaskFn) {
          log('onScheduleMicrotask');
          taskToRun = microTaskFn;
        };

        var completer;
        zone.run(() {
          completer = new Completer();
          completer.future.then((x) => log('future'));
          log('first');
        });
        completer.complete();

        expect(log).toEqual([
            'first', 'onTurnDone',
            'onScheduleMicrotask', 'future', 'onTurnDone'
        ]);
      });

    });
  });
}
