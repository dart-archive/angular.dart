library angular.mock.zone_spec;

import '../_specs.dart';
import 'dart:async';

main() => describe('mock zones', () {
  describe('sync', () {
    it('should throw an error on runAsync', () {
      expect(sync(() {
        runAsync(() => dump("i never run"));
      })).toThrow('runAsync called from sync function');
    });


    it('should throw an error on timer', () {
      expect(sync(() {
        Timer.run(() => dump("i never run"));
      })).toThrow('Timer created from sync function');
    });


    it('should throw an error on periodic timer', () {
      expect(sync(() {
        new Timer.periodic(new Duration(milliseconds: 10),
            (_) => dump("i never run"));
      })).toThrow('periodic Timer created from sync function');
    });
  });

  describe('async', () {
    it('should run synchronous code', () {
      var ran = false;
      async(() { ran = true; })();
      expect(ran).toBe(true);
    });


    it('should run async code', () {
      var ran = false;
      var thenRan = false;
      async(() {
        new Future.value('s').then((_) { thenRan = true; });
        expect(thenRan).toBe(false);
        microLeap();
        expect(thenRan).toBe(true);
        ran = true;
      })();
      expect(ran).toBe(true);
    });


    it('should run chained thens', () {
      var log = [];
      async(() {
        new Future.value('s')
        .then((_) { log.add('firstThen'); })
        .then((_) { log.add('2ndThen'); });
        expect(log.join(' ')).toEqual('');
        microLeap();
        expect(log.join(' ')).toEqual('firstThen 2ndThen');
      })();
    });


    it('shold run futures created in futures', () {
      var log = [];
      async(() {
        new Future.value('s')
        .then((_) {
          log.add('firstThen');
          new Future.value('t').then((_) {
            log.add('2ndThen');
          });
        });
        expect(log.join(' ')).toEqual('');
        microLeap();
        expect(log.join(' ')).toEqual('firstThen 2ndThen');
      })();
    });

    it('should run all the async calls if asked', () {
      var log = [];
      async(() {
        new Future.value('s')
        .then((_) {
          log.add('firstThen');
          new Future.value('t').then((_) {
            log.add('2ndThen');
          });
        });
        expect(log.join(' ')).toEqual('');
        microLeap();
        expect(log.join(' ')).toEqual('firstThen 2ndThen');
      })();
    });


    it('should not complain if you dangle callbacks', () {
      async(() {
        new Future.value("s").then((_) {});
      })();
    });


    it('should complain if you dangle exceptions', () {
      expect(() {
        async(() {
          new Future.value("s").then((_) {
            throw ["dangling"];
          });
        })();
      }).toThrow("dangling");
    });


    it('should complain if the test throws an exception', () {
      expect(() {
        async(() {
          throw "blah";
        })();
      }).toThrow("blah");
    });


    it('should complain if the test throws an exception during async calls', () {
      var ran = false;
      expect(async(() {
        new Future.value('s').then((_) { throw "blah then"; });
        microLeap();
      })).toThrow("blah then");
    });

    describe('timers', () {
      it('should not run queued timer on insufficient clock tick', async(() {
        bool timerRan = false;
        new Timer(new Duration(milliseconds: 10), () => timerRan = true);

        clockTick(milliseconds: 9);
        expect(timerRan).toBeFalsy();
      }));


      it('should run queued zero duration timer on zero tick', async(() {
        bool timerRan = false;
        Timer.run(() => timerRan = true);

        clockTick();
        expect(timerRan).toBeTruthy();
      }));


      it('should run queued timer after sufficient clock ticks', async(() {
        bool timerRan = false;
        new Timer(new Duration(milliseconds: 10), () => timerRan = true);

        clockTick(milliseconds: 9);
        expect(timerRan).toBeFalsy();
        clockTick(milliseconds: 1);
        expect(timerRan).toBeTruthy();
      }));


      it('should run queued timer only once', async(() {
        int timerRan = 0;
        new Timer(new Duration(milliseconds: 10), () => timerRan++);

        clockTick(milliseconds: 10);
        expect(timerRan).toBe(1);
        clockTick(milliseconds: 10);
        expect(timerRan).toBe(1);
        clockTick(minutes: 10);
        expect(timerRan).toBe(1);
      }));


      it('should run periodic timer', async(() {
        int timerRan = 0;
        new Timer.periodic(new Duration(milliseconds: 10), (_) => timerRan++);

        clockTick(milliseconds: 9);
        expect(timerRan).toBe(0);
        clockTick(milliseconds: 1);
        expect(timerRan).toBe(1);
        clockTick(milliseconds: 30);
        expect(timerRan).toBe(4);
      }));


      it('should not run cancelled timer', async(() {
        bool timerRan = false;
        var timer = new Timer(new Duration(milliseconds: 10),
            () => timerRan = true);

        timer.cancel();

        clockTick(milliseconds: 10);
        expect(timerRan).toBeFalsy();
      }));


      it('should not run cancelled periodic timer', async(() {
        bool timerRan = false;
        var timer = new Timer.periodic(new Duration(milliseconds: 10),
            (_) => timerRan = true);

        timer.cancel();

        clockTick(milliseconds: 10);
        expect(timerRan).toBeFalsy();
      }));


      it('should be able to cancel periodic timer from callback', async(() {
        int timerRan = 0;
        new Timer.periodic(new Duration(milliseconds: 10),
            (timer) {
              timerRan++;
              timer.cancel();
            });

        clockTick(milliseconds: 10);
        expect(timerRan).toBe(1);

        clockTick(milliseconds: 10);
        expect(timerRan).toBe(1);
      }));


      it('should process micro-tasks before timers', async(() {
        var log = [];

        runAsync(() => log.add('runAsync'));
        new Timer(new Duration(milliseconds: 10),
            () => log.add('timer'));
        new Timer.periodic(new Duration(milliseconds: 10),
            (_) => log.add('periodic_timer'));

        expect(log.join(' ')).toEqual('');

        clockTick(milliseconds: 10);

        expect(log.join(' ')).toEqual('runAsync timer periodic_timer');
      }));


      it('should process micro-tasks created in timers before next timers', async(() {
        var log = [];

        runAsync(() => log.add('runAsync'));
        new Timer(new Duration(milliseconds: 10),
            () {
              log.add('timer');
              runAsync(() => log.add('timer_runAsync'));
            });
        new Timer.periodic(new Duration(milliseconds: 10),
            (_) {
              log.add('periodic_timer');
              runAsync(() => log.add('periodic_timer_runAsync'));
            });

        expect(log.join(' ')).toEqual('');

        clockTick(milliseconds: 10);
        expect(log.join(' ')).toEqual('runAsync timer timer_runAsync periodic_timer');

        clockTick();
        expect(log.join(' ')).toEqual('runAsync timer timer_runAsync periodic_timer');

        clockTick(milliseconds: 10);
        expect(log.join(' ')).toEqual('runAsync timer timer_runAsync periodic_timer periodic_timer_runAsync periodic_timer');
      }));


      it('should not leak timers between asyncs', () {
        var log = [];

        async(() {
          new Timer.periodic(new Duration(milliseconds: 10),
              (_) => log.add('periodic_timer'));
          new Timer(new Duration(milliseconds: 10),
              () => log.add('timer'));
          clockTick(milliseconds: 10);
        })();
        expect(log.join(' ')).toEqual('periodic_timer timer');

        async(() {
          clockTick(milliseconds: 10);
        })();
        expect(log.join(' ')).toEqual('periodic_timer timer');
      });
    });
  });
});
