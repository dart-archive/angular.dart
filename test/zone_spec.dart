import "_specs.dart";
import "_log.dart";

import "dart:async";

main() => describe('zone', () {
  var zone;
  beforeEach(inject((Log log) {
    zone = new Zone();
    zone.onTurnDone = () {
      log('onTurnDone');
    };
  }));


  describe('exceptions', () {
    it('should throw exceptions from the body', () {
      expect(() {
        zone.run(() {
          throw ['hello'];
        });
      }).toThrow('hello');
    });


    it('should handle exceptions in onRunAsync', () {
      // TODO(deboer): Define how exceptions should behave in zones.
    });


    it('should handle exceptioned in onTurnDone', () {
      // TODO(deboer): Define how exceptions should behave in zones.
    });
  });


  it('should call onTurnDone after a synchronous block', inject((Log log) {
    zone.run(() {
      log('run');
    });
    expect(log.result()).toEqual('run; onTurnDone');
  }));


  it('should return the body return value from run', () {
    expect(zone.run(() { return 6; })).toEqual(6);
  });


  it('should call onTurnDone for a runAsync in onTurnDone', async(inject((Log log) {
    var ran = false;
    zone.onTurnDone = () {
      dump('onTurn $ran');
      if (!ran) {
        runAsync(() { ran = true; log('onTurnAsync'); });
      }
      log('onTurnDone');
    };
    zone.run(() {
      log('run');
    });
    nextTurn(true);

    expect(log.result()).toEqual('run; onTurnDone; onTurnAsync; onTurnDone');
  })));


  it('should call onTurnDone for a runAsync in onTurnDone triggered by a runAsync in run', async(inject((Log log) {
    var ran = false;
    zone.onTurnDone = () {
      if (!ran) {
        dump('...');
        runAsync(() { ran = true; log('onTurnAsync'); });
      }
      log('onTurnDone');
    };
    zone.run(() {
      runAsync(() { log('runAsync'); });
      log('run');
    });
    nextTurn(true);

    expect(log.result()).toEqual('run; runAsync; onTurnDone; onTurnAsync; onTurnDone');
  })));



  it('should call onTurnDone once after a turn', async(inject((Log log) {
    zone.run(() {
      log('run start');
      runAsync(() {
        log('async');
      });
      log('run end');
    });
    nextTurn(true);

    expect(log.result()).toEqual('run start; run end; async; onTurnDone');
  })));


  it('should work for Future.value as well', async(inject((Log log) {
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
      new Future.value(null).then((_) {
        log('future then');
        new Future.value(null).then((_) {
          log('future 3'); });
          return new Future.value(null);
      }).then((_) {
        log('future 2');
      });
      log('run end');
    });
    nextTurn(true);

    expect(log.result()).toEqual('run start; run end; future then; future 2; future 3; onTurnDone; onTurn future; onTurnDone');
  })));


  it('should call onTurnDone after each turn', async(inject((Log log) {
    Completer a, b;
    zone.run(() {
      a = new Completer();
      b = new Completer();
      a.future.then((_) => log('a then'));
      b.future.then((_) => log('b then'));
      log('run start');
    });
    nextTurn(true);
    zone.run(() {
      a.complete(null);
    });
    nextTurn(true);
    zone.run(() {
      b.complete(null);
    });
    nextTurn(true);

    expect(log.result()).toEqual('run start; onTurnDone; a then; onTurnDone; b then; onTurnDone');
  })));


  it('should call onTurnDone after each turn in a chain', async(inject((Log log) {
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
    nextTurn(true);

    expect(log.result()).toEqual('run start; run end; async1; async2; onTurnDone');
  })));


  it('should call onTurnDone once even if run is called multiple times', async(inject((Log log) {
    zone.run(() {
      log('runA start');
      runAsync(() {
        log('asyncA');

      });
      log('runA end');
    });
    zone.run(() {
      log('runB start');
      runAsync(() {
        log('asyncB');
      });
      log('runB end');
    });
    nextTurn(true);

    expect(log.result()).toEqual('runA start; runA end; runB start; runB end; asyncA; asyncB; onTurnDone');
  })));


  it('should not call onTurnDone for futures created outside of run body', async(inject((Log log) {
    // Odd? Yes. Since Future.value resolves immediately, it (and its thens)
    // are already on the runAsync queue when we schedule onTurnDone.
    // Since we want to test explicitly that onTurnDone is not waiting for
    // the future, we use a second Future.value in a then to reschedule
    // the future on the runAsync queue.
    var future = new Future.value(4).then((x) => new Future.value(x));
    zone.run(() {
      future.then((_) => log('future then'));
      log('zone run');
    });
    nextTurn(true);

    expect(log.result()).toEqual('zone run; onTurnDone; future then');
  })));


  it('should support assertInZone', () {
      zone.onTurnDone = () {
        zone.assertInZone();
      };
      zone.run(() {
        zone.assertInZone();
        runAsync(() {
          zone.assertInZone();
          runAsync(() {
            zone.assertInZone();
          });
        });
      });
    });


    it('should throw outside of the zone', () {
      expect(async(() {
        zone.assertInZone();
        nextTurn(true);
      })).toThrow('Function must be called in a zone');
    });
});
