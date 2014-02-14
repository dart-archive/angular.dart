library scope2_spec;

import '../_specs.dart';
import 'package:angular/change_detection/change_detection.dart' hide ExceptionHandler;
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() => describe('scope', () {
  beforeEach(module((Module module) {
    Map context = {};
    module.value(GetterCache, new GetterCache({}));
    module.type(ChangeDetector, implementedBy: DirtyCheckingChangeDetector);
    module.value(Object, context);
    module.value(Map, context);
    module.type(RootScope);
    module.type(_MultiplyFilter);
    module.type(_ListHeadFilter);
    module.type(_ListTailFilter);
    module.type(_SortFilter);
  }));

  describe('AST Bridge', () {
    it('should watch field', inject((Logger logger, Map context, RootScope rootScope) {
      context['field'] = 'Worked!';
      rootScope.watch('field', (value, previous) => logger([value, previous]));
      expect(logger).toEqual([]);
      rootScope.digest();
      expect(logger).toEqual([['Worked!', null]]);
      rootScope.digest();
      expect(logger).toEqual([['Worked!', null]]);
    }));

    it('should watch field path', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = {'b': 'AB'};
      rootScope.watch('a.b', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual(['AB']);
      context['a']['b'] = '123';
      rootScope.digest();
      expect(logger).toEqual(['AB', '123']);
      context['a'] = {'b': 'XYZ'};
      rootScope.digest();
      expect(logger).toEqual(['AB', '123', 'XYZ']);
    }));

    it('should watch math operations', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = 1;
      context['b'] = 2;
      rootScope.watch('a + b + 1', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([4]);
      context['a'] = 3;
      rootScope.digest();
      expect(logger).toEqual([4, 6]);
      context['b'] = 5;
      rootScope.digest();
      expect(logger).toEqual([4, 6, 9]);
    }));


    it('should watch literals', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = 1;
      rootScope.watch('1', (value, previous) => logger(value));
      rootScope.watch('"str"', (value, previous) => logger(value));
      rootScope.watch('[a, 2, 3]', (value, previous) => logger(value));
      rootScope.watch('{a:a, b:2}', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([1, 'str', [1, 2, 3], {'a': 1, 'b': 2}]);
      logger.clear();
      context['a'] = 3;
      rootScope.digest();
      expect(logger).toEqual([[3, 2, 3], {'a': 3, 'b': 2}]);
    }));

    it('should invoke closures', inject((Logger logger, Map context, RootScope rootScope) {
      context['fn'] = () {
        logger('fn');
        return 1;
      };
      context['a'] = {'fn': () {
        logger('a.fn');
        return 2;
      }};
      rootScope.watch('fn()', (value, previous) => logger('=> $value'));
      rootScope.watch('a.fn()', (value, previous) => logger('-> $value'));
      rootScope.digest();
      expect(logger).toEqual(['fn', 'a.fn', '=> 1', '-> 2',
                              /* second loop*/ 'fn', 'a.fn']);
      logger.clear();
      rootScope.digest();
      expect(logger).toEqual(['fn', 'a.fn']);
    }));

    it('should perform conditionals', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = 1;
      context['b'] = 2;
      context['c'] = 3;
      rootScope.watch('a?b:c', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([2]);
      logger.clear();
      context['a'] = 0;
      rootScope.digest();
      expect(logger).toEqual([3]);
    }));


    xit('should call function', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = () {
        return () { return 123; };
      };
      rootScope.watch('a()()', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([123]);
      logger.clear();
      rootScope.digest();
      expect(logger).toEqual([]);
    }));

    it('should access bracket', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = {'b': 123};
      rootScope.watch('a["b"]', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([123]);
      logger.clear();
      rootScope.digest();
      expect(logger).toEqual([]);
    }));


    it('should prefix', inject((Logger logger, Map context, RootScope rootScope) {
      context['a'] = true;
      rootScope.watch('!a', (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([false]);
      logger.clear();
      context['a'] = false;
      rootScope.digest();
      expect(logger).toEqual([true]);
    }));

    it('should support filters', inject((Logger logger, Map context,
                                         RootScope rootScope, AstParser parser,
                                         FilterMap filters) {
      context['a'] = 123;
      context['b'] = 2;
      rootScope.watch(
          parser('a | multiply:b', filters: filters),
          (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual([246]);
      logger.clear();
      rootScope.digest();
      expect(logger).toEqual([]);
      logger.clear();
    }));

    it('should support arrays in filters', inject((Logger logger, Map context,
                                                   RootScope rootScope,
                                                   AstParser parser,
                                                   FilterMap filters) {
      context['a'] = [1];
      rootScope.watch(
          parser('a | sort | listHead:"A" | listTail:"B"', filters: filters),
          (value, previous) => logger(value));
      rootScope.digest();
      expect(logger).toEqual(['sort', 'listHead', 'listTail', ['A', 1, 'B']]);
      logger.clear();

      rootScope.digest();
      expect(logger).toEqual([]);
      logger.clear();

      context['a'].add(2);
      rootScope.digest();
      expect(logger).toEqual(['sort', 'listHead', 'listTail', ['A', 1, 2, 'B']]);
      logger.clear();

      // We change the order, but sort should change it to same one and it should not
      // call subsequent filters.
      context['a'] = [2, 1];
      rootScope.digest();
      expect(logger).toEqual(['sort']);
      logger.clear();
    }));
  });


  describe('properties', () {
    describe('root', () {
      it('should point to itself', inject((RootScope rootScope) {
        expect(rootScope.rootScope).toEqual(rootScope);
      }));

      it('children should point to root', inject((RootScope rootScope) {
        var child = rootScope.createChild();
        expect(child.rootScope).toEqual(rootScope);
        expect(child.createChild().rootScope).toEqual(rootScope);
      }));
    });


    describe('parent', () {
      it('should not have parent', inject((RootScope rootScope) {
        expect(rootScope.parentScope).toEqual(null);
      }));


      it('should point to parent', inject((RootScope rootScope) {
        var child = rootScope.createChild();
        expect(rootScope.parentScope).toEqual(null);
        expect(child.parentScope).toEqual(rootScope);
        expect(child.createChild().parentScope).toEqual(child);
      }));
    });
  });


  describe(r'events', () {

    describe('on', () {
      it('should allow emit/broadcast when no listeners', inject((RootScope scope) {
        scope.emit('foo');
        scope.broadcast('foo');
      }));


      it(r'should add listener for both emit and broadcast events', inject((RootScope rootScope) {
        var log = '',
        child = rootScope.createChild();

        eventFn(event) {
          expect(event).not.toEqual(null);
          log += 'X';
        }

        child.on('abc').listen(eventFn);
        expect(log).toEqual('');

        child.emit('abc');
        expect(log).toEqual('X');

        child.broadcast('abc');
        expect(log).toEqual('XX');
      }));


      it(r'should return a function that deregisters the listener', inject((RootScope rootScope) {
        var log = '';
        var child = rootScope.createChild();
        var subscription;

        eventFn(e) {
          log += 'X';
        }

        subscription = child.on('abc').listen(eventFn);
        expect(log).toEqual('');
        expect(subscription).toBeDefined();

        child.emit(r'abc');
        child.broadcast('abc');
        expect(log).toEqual('XX');

        log = '';
        expect(subscription.cancel()).toBe(null);
        child.emit(r'abc');
        child.broadcast('abc');
        expect(log).toEqual('');
      }));
    });


    describe('emit', () {
      var log, child, grandChild, greatGrandChild;

      logger(event) {
        log.add(event.currentScope.context['id']);
      }

      beforeEach(module(() {
        return (RootScope rootScope) {
          log = [];
          child = rootScope.createChild({'id': 1});
          grandChild = child.createChild({'id': 2});
          greatGrandChild = grandChild.createChild({'id': 3});

          rootScope.context['id'] = 0;

          rootScope.on('myEvent').listen(logger);
          child.on('myEvent').listen(logger);
          grandChild.on('myEvent').listen(logger);
          greatGrandChild.on('myEvent').listen(logger);
        };
      }));

      it(r'should bubble event up to the root scope', inject((RootScope rootScope) {
        grandChild.emit(r'myEvent');
        expect(log.join('>')).toEqual('2>1>0');
      }));


      it(r'should dispatch exceptions to the exceptionHandler', () {
        module((Module module) {
          module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
        });
        inject((ExceptionHandler e) {
          LoggingExceptionHandler exceptionHandler = e;
          child.on('myEvent').listen((e) { throw 'bubbleException'; });
          grandChild.emit(r'myEvent');
          expect(log.join('>')).toEqual('2>1>0');
          expect(exceptionHandler.errors[0].error).toEqual('bubbleException');
        });
      });


      it(r'should allow stopping event propagation', inject((RootScope rootScope) {
        child.on('myEvent').listen((event) { event.stopPropagation(); });
        grandChild.emit(r'myEvent');
        expect(log.join('>')).toEqual('2>1');
      }));


      it(r'should forward method arguments', inject((RootScope rootScope) {
        var eventName;
        var eventData;
        child.on('abc').listen((event) {
          eventName = event.name;
          eventData = event.data;
        });
        child.emit('abc', ['arg1', 'arg2']);
        expect(eventName).toEqual('abc');
        expect(eventData).toEqual(['arg1', 'arg2']);
      }));


      describe(r'event object', () {
        it(r'should have methods/properties', inject((RootScope rootScope) {
          var event;
          child.on('myEvent').listen((e) {
            expect(e.targetScope).toBe(grandChild);
            expect(e.currentScope).toBe(child);
            expect(e.name).toBe('myEvent');
            event = e;
          });
          grandChild.emit(r'myEvent');
          expect(event).toBeDefined();
        }));


        it(r'should have preventDefault method and defaultPrevented property', inject((RootScope rootScope) {
          var event = grandChild.emit(r'myEvent');
          expect(event.defaultPrevented).toBe(false);

          child.on('myEvent').listen((event) {
            event.preventDefault();
          });
          event = grandChild.emit(r'myEvent');
          expect(event.defaultPrevented).toBe(true);
        }));
      });
    });


    describe('broadcast', () {
      describe(r'event propagation', () {
        var log, child1, child2, child3, grandChild11, grandChild21, grandChild22, grandChild23,
        greatGrandChild211;

        logger(event) {
          log.add(event.currentScope.context['id']);
        }

        beforeEach(inject((RootScope rootScope) {
          log = [];
          child1 = rootScope.createChild({});
          child2 = rootScope.createChild({});
          child3 = rootScope.createChild({});
          grandChild11 = child1.createChild({});
          grandChild21 = child2.createChild({});
          grandChild22 = child2.createChild({});
          grandChild23 = child2.createChild({});
          greatGrandChild211 = grandChild21.createChild({});

          rootScope.context['id'] = 0;
          child1.context['id'] = 1;
          child2.context['id'] = 2;
          child3.context['id'] = 3;
          grandChild11.context['id'] = 11;
          grandChild21.context['id'] = 21;
          grandChild22.context['id'] = 22;
          grandChild23.context['id'] = 23;
          greatGrandChild211.context['id'] = 211;

          rootScope.on('myEvent').listen(logger);
          child1.on('myEvent').listen(logger);
          child2.on('myEvent').listen(logger);
          child3.on('myEvent').listen(logger);
          grandChild11.on('myEvent').listen(logger);
          grandChild21.on('myEvent').listen(logger);
          grandChild22.on('myEvent').listen(logger);
          grandChild23.on('myEvent').listen(logger);
          greatGrandChild211.on('myEvent').listen(logger);

          //          R
          //       /  |   \
          //     1    2    3
          //    /   / | \
          //   11  21 22 23
          //       |
          //      211
        }));


        it(r'should broadcast an event from the root scope', inject((RootScope rootScope) {
          rootScope.broadcast('myEvent');
          expect(log.join('>')).toEqual('0>1>11>2>21>211>22>23>3');
        }));


        it(r'should broadcast an event from a child scope', inject((RootScope rootScope) {
          child2.broadcast('myEvent');
          expect(log.join('>')).toEqual('2>21>211>22>23');
        }));


        it(r'should broadcast an event from a leaf scope with a sibling', inject((RootScope rootScope) {
          grandChild22.broadcast('myEvent');
          expect(log.join('>')).toEqual('22');
        }));


        it(r'should broadcast an event from a leaf scope without a sibling', inject((RootScope rootScope) {
          grandChild23.broadcast('myEvent');
          expect(log.join('>')).toEqual('23');
        }));


        it(r'should not not fire any listeners for other events', inject((RootScope rootScope) {
          rootScope.broadcast('fooEvent');
          expect(log.join('>')).toEqual('');
        }));


        it(r'should return event object', inject((RootScope rootScope) {
          var result = child1.broadcast('some');

          expect(result).toBeDefined();
          expect(result.name).toBe('some');
          expect(result.targetScope).toBe(child1);
        }));
      });


      describe(r'listener', () {
        it(r'should receive event object', inject((RootScope rootScope) {
          var scope = rootScope,
          child = scope.createChild({}),
          event;

          child.on('fooEvent').listen((e) {
            event = e;
          });
          scope.broadcast('fooEvent');

          expect(event.name).toBe('fooEvent');
          expect(event.targetScope).toBe(scope);
          expect(event.currentScope).toBe(child);
        }));

        it(r'should support passing messages as varargs', inject((RootScope rootScope) {
          var scope = rootScope,
          child = scope.createChild({}),
          args;

          child.on('fooEvent').listen((e) {
            args = e.data;
          });
          scope.broadcast('fooEvent', ['do', 're', 'me', 'fa']);

          expect(args.length).toBe(4);
          expect(args).toEqual(['do', 're', 'me', 'fa']);
        }));
      });
    });
  });


  describe(r'destroy', () {
    var first = null, middle = null, last = null, log = null;

    beforeEach(inject((RootScope rootScope) {
      log = '';

      first  = rootScope.createChild({"check": (n) { log+= '$n'; return n;}});
      middle = rootScope.createChild({"check": (n) { log+= '$n'; return n;}});
      last   = rootScope.createChild({"check": (n) { log+= '$n'; return n;}});

      first.watch('check(1)', (v, l) {});
      middle.watch('check(2)', (v, l) {});
      last.watch('check(3)', (v, l) {});

      first.on(ScopeEvent.DESTROY).listen((e) { log += 'destroy:first;'; });

      rootScope.digest();
      log = '';
    }));


    it(r'should ignore remove on root', inject((RootScope rootScope) {
      rootScope.destroy();
      rootScope.digest();
      expect(log).toEqual('123');
    }));


    it(r'should remove first', inject((RootScope rootScope) {
      first.destroy();
      rootScope.digest();
      expect(log).toEqual('destroy:first;23');
    }));


    it(r'should remove middle', inject((RootScope rootScope) {
      middle.destroy();
      rootScope.digest();
      expect(log).toEqual('13');
    }));


    it(r'should remove last', inject((RootScope rootScope) {
      last.destroy();
      rootScope.digest();
      expect(log).toEqual('12');
    }));


    it(r'should broadcast the destroy event', inject((RootScope rootScope) {
      var log = [];
      first.on(ScopeEvent.DESTROY).listen((s) => log.add('first'));
      first.createChild({}).on(ScopeEvent.DESTROY).listen((s) => log.add('first-child'));

      first.destroy();
      expect(log).toEqual(['first', 'first-child']);
    }));
  });


  describe('digest lifecycle', () {
    it(r'should apply expression with full lifecycle', inject((RootScope rootScope) {
      var log = '';
      var child = rootScope.createChild({"parent": rootScope.context});
      rootScope.watch('a', (a, _) { log += '1'; });
      child.apply('parent.a = 0');
      expect(log).toEqual('1');
    }));


    it(r'should catch exceptions', () {
      module((Module module) => module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler));
      inject((RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        var log = [];
        var child = rootScope.createChild({});
        rootScope.watch('a', (a, _) => log.add('1'));
        rootScope.context['a'] = 0;
        child.apply(() { throw 'MyError'; });
        expect(log.join(',')).toEqual('1');
        expect(exceptionHandler.errors[0].error).toEqual('MyError');
        exceptionHandler.errors.removeAt(0);
        exceptionHandler.assertEmpty();
      });
    });


    describe(r'exceptions', () {
      var log;
      beforeEach(module((Module module) {
        return module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
      }));
      beforeEach(inject((RootScope rootScope) {
        rootScope.context['log'] = () { log += 'digest;'; return null; };
        log = '';
        rootScope.watch('log()', (v, o) => null);
        rootScope.digest();
        log = '';
      }));


      it(r'should execute and return value and update', inject(
              (RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        rootScope.context['name'] = 'abc';
        expect(rootScope.apply((context) => context['name'])).toEqual('abc');
        expect(log).toEqual('digest;digest;');
        exceptionHandler.assertEmpty();
      }));


      it(r'should execute and return value and update', inject((RootScope rootScope) {
        rootScope.context['name'] = 'abc';
        expect(rootScope.apply('name', {'name': 123})).toEqual(123);
      }));


      it(r'should catch exception and update', inject((RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        var error = 'MyError';
        rootScope.apply(() { throw error; });
        expect(log).toEqual('digest;digest;');
        expect(exceptionHandler.errors[0].error).toEqual(error);
      }));
    });

    it(r'should proprely reset phase on exception', inject((RootScope rootScope) {
      var error = 'MyError';
      expect(() => rootScope.apply(() { throw error; })).toThrow(error);
      expect(() => rootScope.apply(() { throw error; })).toThrow(error);
    }));
  });


  describe('flush lifecycle', () {
    it(r'should apply expression with full lifecycle', inject((RootScope rootScope) {
      var log = '';
      var child = rootScope.createChild({"parent": rootScope.context});
      rootScope.observe('a', (a, _) { log += '1'; });
      child.apply('parent.a = 0');
      expect(log).toEqual('1');
    }));


    it(r'should schedule domWrites and domReads', inject((RootScope rootScope) {
      var log = '';
      var child = rootScope.createChild({"parent": rootScope.context});
      rootScope.observe('a', (a, _) { log += '1'; });
      child.apply('parent.a = 0');
      expect(log).toEqual('1');
    }));


    it(r'should catch exceptions', () {
      module((Module module) => module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler));
      inject((RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        var log = [];
        var child = rootScope.createChild({});
        rootScope.observe('a', (a, _) => log.add('1'));
        rootScope.context['a'] = 0;
        child.apply(() { throw 'MyError'; });
        expect(log.join(',')).toEqual('1');
        expect(exceptionHandler.errors[0].error).toEqual('MyError');
        exceptionHandler.errors.removeAt(0);
        exceptionHandler.assertEmpty();
      });
    });


    describe(r'exceptions', () {
      var log;
      beforeEach(module((Module module) {
        return module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
      }));
      beforeEach(inject((RootScope rootScope) {
        rootScope.context['log'] = () { log += 'digest;'; return null; };
        log = '';
        rootScope.observe('log()', (v, o) => null);
        rootScope.digest();
        log = '';
      }));


      it(r'should execute and return value and update', inject(
              (RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        rootScope.context['name'] = 'abc';
        expect(rootScope.apply((context) => context['name'])).toEqual('abc');
        expect(log).toEqual('digest;digest;');
        exceptionHandler.assertEmpty();
      }));

      it(r'should execute and return value and update', inject((RootScope rootScope) {
        rootScope.context['name'] = 'abc';
        expect(rootScope.apply('name', {'name': 123})).toEqual(123);
      }));

      it(r'should catch exception and update', inject((RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        var error = 'MyError';
        rootScope.apply(() { throw error; });
        expect(log).toEqual('digest;digest;');
        expect(exceptionHandler.errors[0].error).toEqual(error);
      }));

      it(r'should throw assertion when model changes in flush', inject((RootScope rootScope, Logger log) {
        var retValue = 1;
        rootScope.context['logger'] = (name) { log(name); return retValue; };

        rootScope.watch('logger("watch")', (n, v) => null);
        rootScope.observe('logger("flush")', (n, v) => null);

        // clear watches
        rootScope.digest();
        log.clear();

        rootScope.flush();
        expect(log).toEqual(['flush', /*assertion*/ 'watch', 'flush']);

        retValue = 2;
        expect(rootScope.flush).
          toThrow('Observer reaction functions should not change model. \n'
                  'These watch changes were detected: logger("watch"): 2 <= 1\n'
                  'These observe changes were detected: ');
      }));
    });

  });


  describe('ScopeLocals', () {
    it('should read from locals', inject((RootScope scope) {
      scope.context['a'] = 'XXX';
      scope.context['c'] = 'C';
      var scopeLocal = new ScopeLocals(scope.context, {'a': 'A', 'b': 'B'});
      expect(scopeLocal['a']).toEqual('A');
      expect(scopeLocal['b']).toEqual('B');
      expect(scopeLocal['c']).toEqual('C');
    }));

    it('should write to Scope', inject((RootScope scope) {
      scope.context['a'] = 'XXX';
      scope.context['c'] = 'C';
      var scopeLocal = new ScopeLocals(scope.context, {'a': 'A', 'b': 'B'});

      scopeLocal['a'] = 'aW';
      scopeLocal['b'] = 'bW';
      scopeLocal['c'] = 'cW';

      expect(scope.context['a']).toEqual('aW');
      expect(scope.context['b']).toEqual('bW');
      expect(scope.context['c']).toEqual('cW');

      expect(scopeLocal['a']).toEqual('A');
      expect(scopeLocal['b']).toEqual('B');
      expect(scopeLocal['c']).toEqual('cW');
    }));
  });


  describe(r'watch/digest', () {
    it(r'should watch and fire on simple property change', inject((RootScope rootScope) {
      var log;

      rootScope.watch('name', (a, b) {
        log = [a, b];
      });
      rootScope.digest();
      log = null;

      expect(log).toEqual(null);
      rootScope.digest();
      expect(log).toEqual(null);
      rootScope.context['name'] = 'misko';
      rootScope.digest();
      expect(log).toEqual(['misko', null]);
    }));


    it('should watch/observe on objects other then contex', inject((RootScope rootScope) {
      var log = '';
      var map = {'a': 'A', 'b': 'B'};
      rootScope.watch('a', (a, b) => log += a, context: map);
      rootScope.watch('b', (a, b) => log += a, context: map);
      rootScope.apply();
      expect(log).toEqual('AB');
    }));


    it(r'should watch and fire on expression change', inject((RootScope rootScope) {
      var log;

      rootScope.watch('name.first', (a, b) => log = [a, b]);
      rootScope.digest();
      log = null;

      rootScope.context['name'] = {};
      expect(log).toEqual(null);
      rootScope.digest();
      expect(log).toEqual(null);
      rootScope.context['name']['first'] = 'misko';
      rootScope.digest();
      expect(log).toEqual(['misko', null]);
    }));


    it(r'should delegate exceptions', () {
      module((Module module) {
        module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
      });
      inject((RootScope rootScope, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e;
        rootScope.watch('a', (n, o) {throw 'abc';});
        rootScope.context['a'] = 1;
        rootScope.digest();
        expect(exceptionHandler.errors.length).toEqual(1);
        expect(exceptionHandler.errors[0].error).toEqual('abc');
      });
    });


    it(r'should fire watches in order of addition', inject((RootScope rootScope) {
      // this is not an external guarantee, just our own sanity
      var log = '';
      rootScope.watch('a', (a, b) { log += 'a'; });
      rootScope.watch('b', (a, b) { log += 'b'; });
      rootScope.watch('c', (a, b) { log += 'c'; });
      rootScope.context['a'] = rootScope.context['b'] = rootScope.context['c'] = 1;
      rootScope.digest();
      expect(log).toEqual('abc');
    }));


    it(r'should call child watchers in addition order', inject((RootScope rootScope) {
      // this is not an external guarantee, just our own sanity
      var log = '';
      var childA = rootScope.createChild({});
      var childB = rootScope.createChild({});
      var childC = rootScope.createChild({});
      childA.watch('a', (a, b) { log += 'a'; });
      childB.watch('b', (a, b) { log += 'b'; });
      childC.watch('c', (a, b) { log += 'c'; });
      childA.context['a'] = childB.context['b'] = childC.context['c'] = 1;
      rootScope.digest();
      expect(log).toEqual('abc');
    }));


    it(r'should run digest multiple times', inject(
            (RootScope rootScope) {
          // tests a traversal edge case which we originally missed
          var log = [];
          var childA = rootScope.createChild({'log': log});
          var childB = rootScope.createChild({'log': log});

          rootScope.context['log'] = log;

          rootScope.watch("log.add('r')", (_, __) => null);
          childA.watch("log.add('a')", (_, __) => null);
          childB.watch("log.add('b')", (_, __) => null);

          // init
          rootScope.digest();
          expect(log.join('')).toEqual('rabrab');
        }));


    it(r'should repeat watch cycle while model changes are identified', inject((RootScope rootScope) {
      var log = '';
      rootScope.watch('c', (v, b) {rootScope.context['d'] = v; log+='c'; });
      rootScope.watch('b', (v, b) {rootScope.context['c'] = v; log+='b'; });
      rootScope.watch('a', (v, b) {rootScope.context['b'] = v; log+='a'; });
      rootScope.digest();
      log = '';
      rootScope.context['a'] = 1;
      rootScope.digest();
      expect(rootScope.context['b']).toEqual(1);
      expect(rootScope.context['c']).toEqual(1);
      expect(rootScope.context['d']).toEqual(1);
      expect(log).toEqual('abc');
    }));


    it(r'should repeat watch cycle from the root element', inject((RootScope rootScope) {
      var log = [];
      rootScope.context['log'] = log;
      var child = rootScope.createChild({'log':log});
      rootScope.watch("log.add('a')", (_, __) => null);
      child.watch("log.add('b')", (_, __) => null);
      rootScope.digest();
      expect(log.join('')).toEqual('abab');
    }));


    it(r'should not fire upon watch registration on initial digest', inject((RootScope rootScope) {
      var log = '';
      rootScope.context['a'] = 1;
      rootScope.watch('a', (a, b) { log += 'a'; });
      rootScope.watch('b', (a, b) { log += 'b'; });
      rootScope.digest();
      log = '';
      rootScope.digest();
      expect(log).toEqual('');
    }));


    it(r'should prevent digest recursion', inject((RootScope rootScope) {
      var callCount = 0;
      rootScope.watch('name', (a, b) {
        expect(() {
          rootScope.digest();
        }).toThrow(r'digest already in progress');
        callCount++;
      });
      rootScope.context['name'] = 'a';
      rootScope.digest();
      expect(callCount).toEqual(1);
    }));


    it(r'should return a function that allows listeners to be unregistered', inject(
            (RootScope rootScope) {
          var listener = jasmine.createSpy('watch listener');
          var watch;

          watch = rootScope.watch('foo', listener);
          rootScope.digest(); //init
          expect(listener).toHaveBeenCalled();
          expect(watch).toBeDefined();

          listener.reset();
          rootScope.context['foo'] = 'bar';
          rootScope.digest(); //triger
          expect(listener).toHaveBeenCalledOnce();

          listener.reset();
          rootScope.context['foo'] = 'baz';
          watch.remove();
          rootScope.digest(); //trigger
          expect(listener).not.toHaveBeenCalled();
        }));


    it(r'should not infinitely digest when current value is NaN', inject((RootScope rootScope) {
      rootScope.context['nan'] = double.NAN;
      rootScope.watch('nan', (_, __) => null);

      expect(() {
        rootScope.digest();
      }).not.toThrow();
    }));


    it(r'should prevent infinite digest and should log firing expressions', inject((RootScope rootScope) {
      rootScope.context['a'] = 0;
      rootScope.context['b'] = 0;
      rootScope.watch('a', (a, __) => rootScope.context['a'] = a + 1);
      rootScope.watch('b', (b, __) => rootScope.context['b'] = b + 1);

      expect(() {
        rootScope.digest();
      }).toThrow('Model did not stabilize in 5 digests. '
                 'Last 3 iterations:\n'
                 'a: 2 <= 1, b: 2 <= 1\n'
                 'a: 3 <= 2, b: 3 <= 2\n'
                 'a: 4 <= 3, b: 4 <= 3');
    }));


    it(r'should always call the watchr with newVal and oldVal equal on the first run',
          inject((RootScope rootScope) {
      var log = [];
      var logger = (newVal, oldVal) {
        var val = (newVal == oldVal || (newVal != oldVal && oldVal != newVal)) ? newVal : 'xxx';
        log.add(val);
      };

      rootScope.context['nanValue'] = double.NAN;
      rootScope.context['nullValue'] = null;
      rootScope.context['emptyString'] = '';
      rootScope.context['falseValue'] = false;
      rootScope.context['numberValue'] = 23;

      rootScope.watch('nanValue', logger);
      rootScope.watch('nullValue', logger);
      rootScope.watch('emptyString', logger);
      rootScope.watch('falseValue', logger);
      rootScope.watch('numberValue', logger);

      rootScope.digest();
      expect(log.removeAt(0).isNaN).toEqual(true); //jasmine's toBe and toEqual don't work well with NaNs
      expect(log).toEqual([null, '', false, 23]);
      log = [];
      rootScope.digest();
      expect(log).toEqual([]);
    }));
  });


  describe('special binding modes', () {
    it('should bind one time', inject((RootScope rootScope, Logger log) {
      rootScope.watch('foo', (v, _) => log('foo:$v'));
      rootScope.watch(':foo', (v, _) => log(':foo:$v'));
      rootScope.watch('::foo', (v, _) => log('::foo:$v'));

      rootScope.apply();
      expect(log).toEqual(['foo:null']);
      log.clear();

      rootScope.context['foo'] = true;
      rootScope.apply();
      expect(log).toEqual(['foo:true', ':foo:true', '::foo:true']);
      log.clear();

      rootScope.context['foo'] = 123;
      rootScope.apply();
      expect(log).toEqual(['foo:123', ':foo:123']);
      log.clear();

      rootScope.context['foo'] = null;
      rootScope.apply();
      expect(log).toEqual(['foo:null']);
      log.clear();
    }));
  });

  
  describe('runAsync', () {
    it(r'should run callback before watch', inject((RootScope rootScope) {
      var log = '';
      rootScope.runAsync(() { log += 'parent.async;'; });
      rootScope.watch('value', (_, __) { log += 'parent.digest;'; });
      rootScope.digest();
      expect(log).toEqual('parent.async;parent.digest;');
    }));

    it(r'should cause a digest rerun', inject((RootScope rootScope) {
      rootScope.context['log'] = '';
      rootScope.context['value'] = 0;
      // NOTE(deboer): watch listener string functions not yet supported
      //rootScope.watch('value', 'log = log + ".";');
      rootScope.watch('value', (_, __) { rootScope.context['log'] += "."; });
      rootScope.watch('init', (_, __) {
        rootScope.runAsync(() => rootScope.eval('value = 123; log = log + "=" '));
        expect(rootScope.context['value']).toEqual(0);
      });
      rootScope.digest();
      expect(rootScope.context['log']).toEqual('.=.');
    }));

    it(r'should run async in the same order as added', inject((RootScope rootScope) {
      rootScope.context['log'] = '';
      rootScope.runAsync(() => rootScope.eval("log = log + 1"));
      rootScope.runAsync(() => rootScope.eval("log = log + 2"));
      rootScope.digest();
      expect(rootScope.context['log']).toEqual('12');
    }));
  });


  describe('domRead/domWrite', () {
    it(r'should run writes before reads', () {
      module((Module module) {
        module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
      });
      inject((RootScope rootScope, Logger logger, ExceptionHandler e) {
        LoggingExceptionHandler exceptionHandler = e as LoggingExceptionHandler;
        rootScope.domWrite(() {
          logger('write1');
          rootScope.domWrite(() => logger('write2'));
          throw 'write1';
        });
        rootScope.domRead(() {
          logger('read1');
          rootScope.domRead(() => logger('read2'));
          rootScope.domWrite(() => logger('write3'));
          throw 'read1';
        });
        rootScope.observe('value', (_, __) => logger('observe'));
        rootScope.flush();
        expect(logger).toEqual(['write1', 'write2', 'observe', 'read1', 'read2', 'write3']);
        expect(exceptionHandler.errors.length).toEqual(2);
        expect(exceptionHandler.errors[0].error).toEqual('write1');
        expect(exceptionHandler.errors[1].error).toEqual('read1');
      });
    });
  });
});

@NgFilter(name: 'multiply')
class _MultiplyFilter {
  call(a, b) => a * b;
}

@NgFilter(name: 'listHead')
class _ListHeadFilter {
  Logger logger;
  _ListHeadFilter(Logger this.logger);
  call(list, head) {
    logger('listHead');
    return [head]..addAll(list);
  }
}


@NgFilter(name: 'listTail')
class _ListTailFilter {
  Logger logger;
  _ListTailFilter(Logger this.logger);
  call(list, tail) {
    logger('listTail');
    return new List.from(list)..add(tail);
  }
}

@NgFilter(name: 'sort')
class _SortFilter {
  Logger logger;
  _SortFilter(Logger this.logger);
  call(list) {
    logger('sort');
    return new List.from(list)..sort();
  }
}

@NgFilter(name:'newFilter')
class FilterOne {
  call(String str) {
    return '$str 1';
  }
}

@NgFilter(name:'newFilter')
class FilterTwo {
  call(String str) {
    return '$str 2';
  }
}
