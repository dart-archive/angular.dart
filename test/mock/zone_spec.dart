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
        nextTurn();
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
        nextTurn();
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
        nextTurn();
        expect(log.join(' ')).toEqual('firstThen');
        nextTurn();
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
        nextTurn(true);
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
        nextTurn(true);
      })).toThrow("blah then");
    });
  });
});
