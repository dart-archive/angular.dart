library scope_spec;

import '../_specs.dart';
import 'dart:convert' show JSON;


main() {
  describe(r'Scope', () {
    NgZone zone;

    noop() {}

    beforeEach(module(() {
      return (NgZone _zone) {
        zone = _zone;
        zone.onError = (e, s, l) => null;
      };
    }));

    describe(r'$root', () {
      it(r'should point to itself', inject((Scope $rootScope) {
        expect($rootScope.$root).toEqual($rootScope);
        expect($rootScope.$root).toEqual($rootScope);
        expect($rootScope.$root).toBeTruthy();
      }));


      it(r'should not have $root on children, but should inherit', inject((Scope $rootScope) {
        var child = $rootScope.$new();
        expect(child.$root).toEqual($rootScope);
        expect(child._$root).toBeFalsy();
      }));

    });


    describe(r'$parent', () {
      it(r'should point to itself in root', inject((Scope $rootScope) {
        expect($rootScope.$root).toEqual($rootScope);
      }));


      it(r'should point to parent', inject((Scope $rootScope) {
        var child = $rootScope.$new();
        expect($rootScope.$parent).toEqual(null);
        expect(child.$parent).toEqual($rootScope);
        expect(child.$new().$parent).toEqual(child);
      }));
    });


    describe(r'$id', () {
      it(r'should have a unique id', inject((Scope $rootScope) {
        expect($rootScope.$id != $rootScope.$new().$id).toBe(true);
      }));
    });


    describe(r'this', () {
      it('should have a \'this\'', inject((Scope $rootScope) {
        expect($rootScope['this']).toEqual($rootScope);
      }));
    });


    describe(r'$new()', () {
      it(r'should create a child scope', inject((Scope $rootScope) {
        var child = $rootScope.$new();
        $rootScope.a = 123;
        expect(child.a).toEqual(123);
      }));

      it(r'should create a non prototypically inherited child scope', inject((Scope $rootScope) {
        var child = $rootScope.$new(isolate: true);
        $rootScope.a = 123;
        expect(child.a).toEqual(null);
        expect(child.$parent).toEqual($rootScope);
        expect(child.$root).toBe($rootScope);
      }));
    });


    describe(r'auto digest', () {
      it(r'should auto digest at the end of the turn', inject((Scope $rootScope) {
        var digestedValue = 0;
        $rootScope.a = 1;
        $rootScope.$watch('a', (newValue, oldValue, _this) {
          digestedValue = newValue;
        });
        expect(digestedValue).toEqual(0);
        zone.run(noop);
        expect(digestedValue).toEqual(1);
      }));

      it(r'should skip auto digest if requested', inject((Scope $rootScope) {
        var digestedValue = 0;
        $rootScope.a = 1;
        $rootScope.$watch('a', (newValue, oldValue, _this) {
          digestedValue = newValue;
        });
        expect(digestedValue).toEqual(0);
        zone.run(() {
          $rootScope.$skipAutoDigest();
        });
        expect(digestedValue).toEqual(0);
        zone.run(noop);
        expect(digestedValue).toEqual(1);
      }));

      it(r'should skip auto digest if requested on any scope', inject((Scope $rootScope) {
        var scope = $rootScope.$new();
        var digestedValue = 0;
        scope.a = 1;
        scope.$watch('a', (newValue, oldValue, _this) {
          digestedValue = newValue;
        });
        expect(digestedValue).toEqual(0);
        zone.run(() {
          scope.$skipAutoDigest();
        });
        expect(digestedValue).toEqual(0);
        zone.run(noop);
        expect(digestedValue).toEqual(1);
      }));

      it(r'should throw exception if asked to skip auto digest outside of a turn',
         inject((Scope $rootScope) {
        var digestedValue = 0;
        $rootScope.a = 1;
        $rootScope.$watch('a', (newValue, oldValue, _this) {
          digestedValue = newValue;
        });
        expect(digestedValue).toEqual(0);
        expect($rootScope.$skipAutoDigest).toThrow();
      }));
    });


    describe(r'$watch/$digest', () {
      it(r'should watch and fire on simple property change', inject((Scope $rootScope) {
        var log;

        $rootScope.$watch('name', (a, b, c) {
          log = [a, b, c];
        });
        $rootScope.$digest();
        log = null;

        expect(log).toEqual(null);
        $rootScope.$digest();
        expect(log).toEqual(null);
        $rootScope.name = 'misko';
        $rootScope.$digest();
        expect(log).toEqual(['misko', null, $rootScope]);
      }));


      it(r'should watch and fire on expression change', inject((Scope $rootScope) {
        var log;

        $rootScope.$watch('name.first', (a, b, c) {
          log = [a, b, c];
        });
        $rootScope.$digest();
        log = null;

        $rootScope.name = {};
        expect(log).toEqual(null);
        $rootScope.$digest();
        expect(log).toEqual(null);
        $rootScope.name['first'] = 'misko';
        $rootScope.$digest();
        expect(log).toEqual(['misko', null, $rootScope]);
      }));


      it(r'should delegate exceptions', () {
        module((Module module) {
          module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
        });
        inject((Scope $rootScope, ExceptionHandler e) {
          LoggingExceptionHandler $exceptionHandler = e;
          $rootScope.$watch('a', () {throw 'abc';});
          $rootScope.a = 1;
          $rootScope.$digest();
          expect($exceptionHandler.errors.length).toEqual(1);
          expect($exceptionHandler.errors[0].error).toEqual('abc');
        });
      });


      it(r'should fire watches in order of addition', inject((Scope $rootScope) {
        // this is not an external guarantee, just our own sanity
        var log = '';
        $rootScope.$watch('a', (a, b, c) { log += 'a'; });
        $rootScope.$watch('b', (a, b, c) { log += 'b'; });
        $rootScope.$watch('c', (a, b, c) { log += 'c'; });
        $rootScope.a = $rootScope.b = $rootScope.c = 1;
        $rootScope.$digest();
        expect(log).toEqual('abc');
      }));


      it(r'should call child $watchers in addition order', inject((Scope $rootScope) {
        // this is not an external guarantee, just our own sanity
        var log = '';
        var childA = $rootScope.$new();
        var childB = $rootScope.$new();
        var childC = $rootScope.$new();
        childA.$watch('a', (a, b, c) { log += 'a'; });
        childB.$watch('b', (a, b, c) { log += 'b'; });
        childC.$watch('c', (a, b, c) { log += 'c'; });
        childA.a = childB.b = childC.c = 1;
        $rootScope.$digest();
        expect(log).toEqual('abc');
      }));


      it(r'should allow $digest on a child scope with and without a right sibling', inject(
          (Scope $rootScope) {
        // tests a traversal edge case which we originally missed
        var log = [],
            childA = $rootScope.$new(),
            childB = $rootScope.$new();

        $rootScope.$watch((a) { log.add('r'); });
        childA.$watch((a) { log.add('a'); });
        childB.$watch((a) { log.add('b'); });

        // init
        $rootScope.$digest();
        expect(log.join('')).toEqual('rabra');

        log.removeWhere((e) => true);
        childA.$digest();
        expect(log.join('')).toEqual('a');

        log.removeWhere((e) => true);
        childB.$digest();
        expect(log.join('')).toEqual('b');
      }));


      it(r'should repeat watch cycle while model changes are identified', inject((Scope $rootScope) {
        var log = '';
        $rootScope.$watch('c', (v, b, c) {$rootScope.d = v; log+='c'; });
        $rootScope.$watch('b', (v, b, c) {$rootScope.c = v; log+='b'; });
        $rootScope.$watch('a', (v, b, c) {$rootScope.b = v; log+='a'; });
        $rootScope.$digest();
        log = '';
        $rootScope.a = 1;
        $rootScope.$digest();
        expect($rootScope.b).toEqual(1);
        expect($rootScope.c).toEqual(1);
        expect($rootScope.d).toEqual(1);
        expect(log).toEqual('abc');
      }));


      it(r'should repeat watch cycle from the root element', inject((Scope $rootScope) {
        var log = '';
        var child = $rootScope.$new();
        $rootScope.$watch((a) { log += 'a'; });
        child.$watch((a) { log += 'b'; });
        $rootScope.$digest();
        expect(log).toEqual('aba');
      }));


      it(r'should not fire upon $watch registration on initial $digest', inject((Scope $rootScope) {
        var log = '';
        $rootScope.a = 1;
        $rootScope.$watch('a', (a, b, c) { log += 'a'; });
        $rootScope.$watch('b', (a, b, c) { log += 'b'; });
        $rootScope.$digest();
        log = '';
        $rootScope.$digest();
        expect(log).toEqual('');
      }));


      it(r'should watch functions', () {
        module((Module module) {
          module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
        });
        inject((Scope $rootScope, ExceptionHandler e) {
          LoggingExceptionHandler exceptionHandler = e;
          $rootScope.fn = () {return 'a';};
          $rootScope.$watch('fn', (fn, a, b) {
            exceptionHandler.errors.add(fn());
          });
          $rootScope.$digest();
          expect(exceptionHandler.errors).toEqual(['a']);
          $rootScope.fn = () {return 'b';};
          $rootScope.$digest();
          expect(exceptionHandler.errors).toEqual(['a', 'b']);
        });
      });


      it(r'should prevent $digest recursion', inject((Scope $rootScope) {
        var callCount = 0;
        $rootScope.$watch('name', (a, b, c) {
          expect(() {
            $rootScope.$digest();
          }).toThrow(r'$digest already in progress');
          callCount++;
        });
        $rootScope.name = 'a';
        $rootScope.$digest();
        expect(callCount).toEqual(1);
      }));


      it(r'should return a function that allows listeners to be unregistered', inject(
          (Scope $rootScope) {
        var listener = jasmine.createSpy('watch listener'),
            listenerRemove;

        listenerRemove = $rootScope.$watch('foo', listener);
        $rootScope.$digest(); //init
        expect(listener).toHaveBeenCalled();
        expect(listenerRemove).toBeDefined();

        listener.reset();
        $rootScope.foo = 'bar';
        $rootScope.$digest(); //triger
        expect(listener).toHaveBeenCalledOnce();

        listener.reset();
        $rootScope.foo = 'baz';
        listenerRemove();
        $rootScope.$digest(); //trigger
        expect(listener).not.toHaveBeenCalled();
      }));


      it(r'should not infinitely digest when current value is NaN', inject((Scope $rootScope) {
        $rootScope.$watch((a) { return double.NAN;});

        expect(() {
          $rootScope.$digest();
        }).not.toThrow();
      }));


      it(r'should prevent infinite digest and should log firing expressions', inject((Scope $rootScope) {
        $rootScope['a'] = 0;
        $rootScope['b'] = 0;
        $rootScope.$watch('a = a + 1');
        $rootScope.$watch('b = b + 1');

        expect(() {
          $rootScope.$digest();
        }).toThrow('Watchers fired in the last 3 iterations: ['
              '["a = a + 1","b = b + 1"],'
              '["a = a + 1","b = b + 1"],'
              '["a = a + 1","b = b + 1"]'
            ']');
      }));


      it(r'should always call the watchr with newVal and oldVal equal on the first run',
          inject((Scope $rootScope) {
        var log = [];
        var logger = (scope, newVal, oldVal) {
          var val = (newVal == oldVal || (newVal != oldVal && oldVal != newVal)) ? newVal : 'xxx';
          log.add(val);
        };

        $rootScope.$watch((s) { return double.NAN;}, logger);
        $rootScope.$watch((s) { return null;}, logger);
        $rootScope.$watch((s) { return '';}, logger);
        $rootScope.$watch((s) { return false;}, logger);
        $rootScope.$watch((s) { return 23;}, logger);

        $rootScope.$digest();
        expect(log.removeAt(0).isNaN).toEqual(true); //jasmine's toBe and toEqual don't work well with NaNs
        expect(log).toEqual([null, '', false, 23]);
        log = [];
        $rootScope.$digest();
        expect(log).toEqual([]);
      }));

      describe('lazy digest', () {
        var rootScope, lazyScope, eagerScope;

        beforeEach(inject((Scope root) {
          rootScope = root;
          lazyScope = root.$new(lazy: true);
          eagerScope = root.$new();
        }));

        it('should digest initially', () {
          var log = '';
          lazyScope.$watch(() {log += 'lazy;';});
          eagerScope.$watch(() {log += 'eager;';});

          rootScope.$digest();
          expect(log).toEqual('lazy;eager;');

          rootScope.$digest();
          expect(log).toEqual('lazy;eager;eager;');

          lazyScope.$dirty();
          rootScope.$digest();
          expect(log).toEqual('lazy;eager;eager;lazy;eager;');
        });
      });

      describe('disabled digest', () {
        var rootScope, childScope;

        beforeEach(inject((Scope root) {
          rootScope = root;
          childScope = root.$new();
        }));

        it('should disable digest', () {
          var log = '';
          childScope.$watch(() {log += 'digest;';});

          rootScope.$digest();
          expect(log).toEqual('digest;');

          childScope.$disabled = true;
          expect(childScope.$disabled).toEqual(true);
          rootScope.$digest();
          expect(log).toEqual('digest;');

          childScope.$disabled = false;
          expect(childScope.$disabled).toEqual(false);
          rootScope.$digest();
          expect(log).toEqual('digest;digest;');
        });
      });
    });


    describe(r'$watchSet', () {
      var scope;
      beforeEach(inject((Scope s) => scope = s));

      it('should skip empty sets', () {
        expect(scope.$watchSet([], null)()).toBe(null);
      });

      it('should treat set of 1 as direct watch', () {
        var lastValues = ['foo'];
        var log = '';
        var clean = scope.$watchSet(['a'], (values, oldValues, s) {
          log += values.join(',') + ';';
          expect(s).toBe(scope);
          expect(oldValues).toEqual(lastValues);
          lastValues = new List.from(values);
        });

        scope.a = 'foo';
        scope.$digest();
        expect(log).toEqual('foo;');

        scope.$digest();
        expect(log).toEqual('foo;');

        scope.a = 'bar';
        scope.$digest();
        expect(log).toEqual('foo;bar;');

        clean();
        scope.a = 'xxx';
        scope.$digest();
        expect(log).toEqual('foo;bar;');
      });

      it('should detect a change to any one in a set', () {
        var lastValues = ['foo', 'bar'];
        var log = '';
        var clean = scope.$watchSet(['a', 'b'], (values, oldValues, s) {
          log += values.join(',') + ';';
          expect(oldValues).toEqual(lastValues);
          lastValues = new List.from(values);
        });

        scope.a = 'foo';
        scope.b = 'bar';
        scope.$digest();
        expect(log).toEqual('foo,bar;');

        scope.$digest();
        expect(log).toEqual('foo,bar;');

        scope.a = 'a';
        scope.$digest();
        expect(log).toEqual('foo,bar;a,bar;');

        scope.a = 'A';
        scope.b = 'B';
        scope.$digest();
        expect(log).toEqual('foo,bar;a,bar;A,B;');

        clean();
        scope.a = 'xxx';
        scope.$digest();
        expect(log).toEqual('foo,bar;a,bar;A,B;');
      });
    });


    describe(r'$destroy', () {
      var first = null, middle = null, last = null, log = null;

      beforeEach(inject((Scope $rootScope) {
        log = '';

        first = $rootScope.$new();
        middle = $rootScope.$new();
        last = $rootScope.$new();

        first.$watch((s) { log += '1';});
        middle.$watch((s) { log += '2';});
        last.$watch((s) { log += '3';});

        $rootScope.$digest();
        log = '';
      }));


      it(r'should ignore remove on root', inject((Scope $rootScope) {
        $rootScope.$destroy();
        $rootScope.$digest();
        expect(log).toEqual('123');
      }));


      it(r'should remove first', inject((Scope $rootScope) {
        first.$destroy();
        $rootScope.$digest();
        expect(log).toEqual('23');
      }));


      it(r'should remove middle', inject((Scope $rootScope) {
        middle.$destroy();
        $rootScope.$digest();
        expect(log).toEqual('13');
      }));


      it(r'should remove last', inject((Scope $rootScope) {
        last.$destroy();
        $rootScope.$digest();
        expect(log).toEqual('12');
      }));


      it(r'should broadcast the $destroy event', inject((Scope $rootScope) {
        var log = [];
        first.$on(r'$destroy', (s) => log.add('first'));
        first.$new().$on(r'$destroy', (s) => log.add('first-child'));

        first.$destroy();
        expect(log).toEqual(['first', 'first-child']);
      }));
    });


    describe(r'$eval', () {
      it(r'should eval an expression', inject((Scope $rootScope) {
        expect($rootScope.$eval('a=1')).toEqual(1);
        expect($rootScope.a).toEqual(1);

        $rootScope.$eval((self, locals) {self.b=2;});
        expect($rootScope.b).toEqual(2);
      }));


      it(r'should allow passing locals to the expression', inject((Scope $rootScope) {
        expect($rootScope.$eval('a+1', {"a": 2})).toBe(3);

        $rootScope.$eval((scope) {
          scope['c'] = scope['b'] + 4;
        }, {"b": 3});
        expect($rootScope.c).toBe(7);
      }));
    });


    describe(r'$evalAsync', () {

      it(r'should run callback before $watch', inject((Scope $rootScope) {
        var log = '';
        var child = $rootScope.$new();
        $rootScope.$evalAsync((scope, _) { log += 'parent.async;'; });
        $rootScope.$watch('value', (_, _0, _1) { log += 'parent.\$digest;'; });
        child.$evalAsync((scope, _) { log += 'child.async;'; });
        child.$watch('value', (_, _0, _1) { log += 'child.\$digest;'; });
        $rootScope.$digest();
        expect(log).toEqual('parent.async;child.async;parent.\$digest;child.\$digest;');
      }));

      it(r'should cause a $digest rerun', inject((Scope $rootScope) {
        $rootScope.log = '';
        $rootScope.value = 0;
        // NOTE(deboer): watch listener string functions not yet supported
        //$rootScope.$watch('value', 'log = log + ".";');
        $rootScope.$watch('value', (__, _, scope) { scope.log = scope.log + "."; });
        $rootScope.$watch('init', (_, __, _0) {
          $rootScope.$evalAsync('value = 123; log = log + "=" ');
          expect($rootScope.value).toEqual(0);
        });
        $rootScope.$digest();
        expect($rootScope.log).toEqual('.=.');
      }));

      it(r'should run async in the same order as added', inject((Scope $rootScope) {
        $rootScope.log = '';
        $rootScope.$evalAsync("log = log + 1");
        $rootScope.$evalAsync("log = log + 2");
        $rootScope.$digest();
        expect($rootScope.log).toEqual('12');
      }));

      it(r'should allow running after digest', inject((Scope $rootScope) {
        $rootScope.log = '';
        $rootScope.$evalAsync(() => $rootScope.log += 'eval;', outsideDigest: true);
        $rootScope.$watch(() { $rootScope.log += 'digest;'; });
        $rootScope.$digest();
        expect($rootScope.log).toEqual('digest;eval;');
      }));

      it(r'should allow running after digest in issolate scope', inject((Scope $rootScope) {
        var isolateScope = $rootScope.$new(isolate: true);
        isolateScope.log = '';
        isolateScope.$evalAsync(() => isolateScope.log += 'eval;', outsideDigest: true);
        isolateScope.$watch(() { isolateScope.log += 'digest;'; });
        isolateScope.$digest();
        expect(isolateScope.log).toEqual('digest;eval;');
      }));

    });


    describe(r'$apply', () {
      it(r'should apply expression with full lifecycle', inject((Scope $rootScope) {
        var log = '';
        var child = $rootScope.$new();
        $rootScope.$watch('a', (a, _, __) { log += '1'; });
        child.$apply(r'$parent.a=0');
        expect(log).toEqual('1');
      }));


      it(r'should catch exceptions', () {
        module((Module module) => module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler));
        inject((Scope $rootScope, ExceptionHandler e) {
          LoggingExceptionHandler $exceptionHandler = e;
          var log = [];
          var child = $rootScope.$new();
          $rootScope.$watch('a', (a, _, __) => log.add('1'));
          $rootScope.a = 0;
          child.$apply((_, __) { throw 'MyError'; });
          expect(log.join(',')).toEqual('1');
          expect($exceptionHandler.errors[0].error).toEqual('MyError');
          $exceptionHandler.errors.removeAt(0);
          $exceptionHandler.assertEmpty();
        });
      });


      describe(r'exceptions', () {
        var log;
        beforeEach(module((Module module) {
          return module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
        }));
        beforeEach(inject((Scope $rootScope) {
          log = '';
          $rootScope.$watch(() { log += '\$digest;'; });
          $rootScope.$digest();
          log = '';
        }));


        it(r'should execute and return value and update', inject(
            (Scope $rootScope, ExceptionHandler e) {
          LoggingExceptionHandler $exceptionHandler = e;
          $rootScope.name = 'abc';
          expect($rootScope.$apply((scope) => scope.name)).toEqual('abc');
          expect(log).toEqual(r'$digest;');
          $exceptionHandler.assertEmpty();
        }));


        it(r'should catch exception and update', inject((Scope $rootScope, ExceptionHandler e) {
          LoggingExceptionHandler $exceptionHandler = e;
          var error = 'MyError';
          $rootScope.$apply(() { throw error; });
          expect(log).toEqual(r'$digest;');
          expect($exceptionHandler.errors[0].error).toEqual(error);
        }));
      });

      it(r'should proprely reset phase on exception', inject((Scope $rootScope) {
        var error = 'MyError';
        expect(() =>$rootScope.$apply(() { throw error; })).toThrow(error);
        expect(() =>$rootScope.$apply(() { throw error; })).toThrow(error);
      }));
    });


    describe(r'events', () {

      describe(r'$on', () {

        it(r'should add listener for both $emit and $broadcast events', inject((Scope $rootScope) {
          var log = '',
              child = $rootScope.$new();

          eventFn() {
            log += 'X';
          }

          child.$on('abc', eventFn);
          expect(log).toEqual('');

          child.$emit(r'abc');
          expect(log).toEqual('X');

          child.$broadcast('abc');
          expect(log).toEqual('XX');
        }));


        it(r'should return a function that deregisters the listener', inject((Scope $rootScope) {
          var log = '',
              child = $rootScope.$new(),
              listenerRemove;

          eventFn() {
            log += 'X';
          }

          listenerRemove = child.$on('abc', eventFn);
          expect(log).toEqual('');
          expect(listenerRemove).toBeDefined();

          child.$emit(r'abc');
          child.$broadcast('abc');
          expect(log).toEqual('XX');

          log = '';
          listenerRemove();
          child.$emit(r'abc');
          child.$broadcast('abc');
          expect(log).toEqual('');
        }));
      });


      describe(r'$emit', () {
        var log, child, grandChild, greatGrandChild;

        logger(event) {
          log.add(event.currentScope.id);
        }

        beforeEach(module((Module module) {
          return module.type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
        }));
        beforeEach(inject((Scope $rootScope) {
          log = [];
          child = $rootScope.$new();
          grandChild = child.$new();
          greatGrandChild = grandChild.$new();

          $rootScope.id = 0;
          child.id = 1;
          grandChild.id = 2;
          greatGrandChild.id = 3;

          $rootScope.$on('myEvent', logger);
          child.$on('myEvent', logger);
          grandChild.$on('myEvent', logger);
          greatGrandChild.$on('myEvent', logger);
        }));

        it(r'should bubble event up to the root scope', () {
          grandChild.$emit(r'myEvent');
          expect(log.join('>')).toEqual('2>1>0');
        });


        it(r'should dispatch exceptions to the $exceptionHandler',
            inject((ExceptionHandler e) {
          LoggingExceptionHandler $exceptionHandler = e;
          child.$on('myEvent', () { throw 'bubbleException'; });
          grandChild.$emit(r'myEvent');
          expect(log.join('>')).toEqual('2>1>0');
          expect($exceptionHandler.errors[0].error).toEqual('bubbleException');
        }));


        it(r'should allow stopping event propagation', () {
          child.$on('myEvent', (event) { event.stopPropagation(); });
          grandChild.$emit(r'myEvent');
          expect(log.join('>')).toEqual('2>1');
        });


        it(r'should forward method arguments', () {
          child.$on('abc', (event, arg1, arg2) {
            expect(event.name).toBe('abc');
            expect(arg1).toBe('arg1');
            expect(arg2).toBe('arg2');
          });
          child.$emit(r'abc', ['arg1', 'arg2']);
        });


        describe(r'event object', () {
          it(r'should have methods/properties', () {
            var event;
            child.$on('myEvent', (e) {
              expect(e.targetScope).toBe(grandChild);
              expect(e.currentScope).toBe(child);
              expect(e.name).toBe('myEvent');
              event = e;
            });
            grandChild.$emit(r'myEvent');
            expect(event).toBeDefined();
          });


          it(r'should have preventDefault method and defaultPrevented property', () {
            var event = grandChild.$emit(r'myEvent');
            expect(event.defaultPrevented).toBe(false);

            child.$on('myEvent', (event) {
              event.preventDefault();
            });
            event = grandChild.$emit(r'myEvent');
            expect(event.defaultPrevented).toBe(true);
          });
        });
      });


      describe(r'$broadcast', () {
        describe(r'event propagation', () {
          var log, child1, child2, child3, grandChild11, grandChild21, grandChild22, grandChild23,
              greatGrandChild211;

          logger(event) {
            log.add(event.currentScope.id);
          }

          beforeEach(inject((Scope $rootScope) {
            log = [];
            child1 = $rootScope.$new();
            child2 = $rootScope.$new();
            child3 = $rootScope.$new();
            grandChild11 = child1.$new();
            grandChild21 = child2.$new();
            grandChild22 = child2.$new();
            grandChild23 = child2.$new();
            greatGrandChild211 = grandChild21.$new();

            $rootScope.id = 0;
            child1.id = 1;
            child2.id = 2;
            child3.id = 3;
            grandChild11.id = 11;
            grandChild21.id = 21;
            grandChild22.id = 22;
            grandChild23.id = 23;
            greatGrandChild211.id = 211;

            $rootScope.$on('myEvent', logger);
            child1.$on('myEvent', logger);
            child2.$on('myEvent', logger);
            child3.$on('myEvent', logger);
            grandChild11.$on('myEvent', logger);
            grandChild21.$on('myEvent', logger);
            grandChild22.$on('myEvent', logger);
            grandChild23.$on('myEvent', logger);
            greatGrandChild211.$on('myEvent', logger);

            //          R
            //       /  |   \
            //     1    2    3
            //    /   / | \
            //   11  21 22 23
            //       |
            //      211
          }));


          it(r'should broadcast an event from the root scope', inject((Scope $rootScope) {
            $rootScope.$broadcast('myEvent');
            expect(log.join('>')).toEqual('0>1>11>2>21>211>22>23>3');
          }));


          it(r'should broadcast an event from a child scope', () {
            child2.$broadcast('myEvent');
            expect(log.join('>')).toEqual('2>21>211>22>23');
          });


          it(r'should broadcast an event from a leaf scope with a sibling', () {
            grandChild22.$broadcast('myEvent');
            expect(log.join('>')).toEqual('22');
          });


          it(r'should broadcast an event from a leaf scope without a sibling', () {
            grandChild23.$broadcast('myEvent');
            expect(log.join('>')).toEqual('23');
          });


          it(r'should not not fire any listeners for other events', inject((Scope $rootScope) {
            $rootScope.$broadcast('fooEvent');
            expect(log.join('>')).toEqual('');
          }));


          it(r'should return event object', () {
            var result = child1.$broadcast('some');

            expect(result).toBeDefined();
            expect(result.name).toBe('some');
            expect(result.targetScope).toBe(child1);
          });
        });


        describe(r'listener', () {
          it(r'should receive event object', inject((Scope $rootScope) {
            var scope = $rootScope,
                child = scope.$new(),
                event;

            child.$on('fooEvent', (e) {
              event = e;
            });
            scope.$broadcast('fooEvent');

            expect(event.name).toBe('fooEvent');
            expect(event.targetScope).toBe(scope);
            expect(event.currentScope).toBe(child);
          }));


          it(r'should support passing messages as varargs', inject((Scope $rootScope) {
            var scope = $rootScope,
                child = scope.$new(),
                args;

            child.$on('fooEvent', (a, b, c, d, e) {
              args = [a, b, c, d, e];
            });
            scope.$broadcast('fooEvent', ['do', 're', 'me', 'fa']);

            expect(args.length).toBe(5);
            expect(args.sublist(1)).toEqual(['do', 're', 'me', 'fa']);
          }));
        });
      });
    });


    describe('\$watchCollection', () {
      var log, $rootScope, deregister;

      beforeEach(inject((Scope _$rootScope_) {
        log = [];
        $rootScope = _$rootScope_;
        deregister = $rootScope.$watchCollection('obj', (obj) {
          log.add(JSON.encode(obj));
        });
      }));


      it('should not trigger if nothing change', inject((Scope $rootScope) {
        $rootScope.$digest();
        expect(log).toEqual(['null']);

        $rootScope.$digest();
        expect(log).toEqual(['null']);
      }));


      it('should allow deregistration', inject((Scope $rootScope) {
        $rootScope.obj = [];
        $rootScope.$digest();

        expect(log).toEqual(['[]']);

        $rootScope.obj.add('a');
        deregister();

        $rootScope.$digest();
        expect(log).toEqual(['[]']);
      }));


      describe('array', () {
        it('should trigger when property changes into array', () {
          $rootScope.obj = 'test';
          $rootScope.$digest();
          expect(log).toEqual(['"test"']);

          $rootScope.obj = [];
          $rootScope.$digest();
          expect(log).toEqual(['"test"', '[]']);
        });


        it('should not trigger change when object in collection changes', () {
          $rootScope.obj = [{}];
          $rootScope.$digest();
          expect(log).toEqual(['[{}]']);

          $rootScope.obj[0]['name'] = 'foo';
          $rootScope.$digest();
          expect(log).toEqual(['[{}]']);
        });


        it('should watch array properties', () {
          $rootScope.obj = [];
          $rootScope.$digest();
          expect(log).toEqual(['[]']);

          $rootScope.obj.add('a');
          $rootScope.$digest();
          expect(log).toEqual(['[]', '["a"]']);

          $rootScope.obj[0] = 'b';
          $rootScope.$digest();
          expect(log).toEqual(['[]', '["a"]', '["b"]']);

          $rootScope.obj.add([]);
          $rootScope.obj.add({});
          log = [];
          $rootScope.$digest();
          expect(log).toEqual(['["b",[],{}]']);

          var temp = $rootScope.obj[1];
          $rootScope.obj[1] = $rootScope.obj[2];
          $rootScope.obj[2] = temp;
          $rootScope.$digest();
          expect(log).toEqual([ '["b",[],{}]', '["b",{},[]]' ]);

          $rootScope.obj.removeAt(0);
          log = [];
          $rootScope.$digest();
          expect(log).toEqual([ '[{},[]]' ]);
        });
      });


      it('should watch iterable properties', () {
        $rootScope.obj = _toJsonableIterable([]);
        $rootScope.$digest();
        expect(log).toEqual(['[]']);

        $rootScope.obj = _toJsonableIterable(['a']);
        $rootScope.$digest();
        expect(log).toEqual(['[]', '["a"]']);

        $rootScope.obj = _toJsonableIterable(['b']);
        $rootScope.$digest();
        expect(log).toEqual(['[]', '["a"]', '["b"]']);

        $rootScope.obj = _toJsonableIterable(['b', [], {}]);
        log = [];
        $rootScope.$digest();
        expect(log).toEqual(['["b",[],{}]']);
      });


      describe('objects', () {
        it('should trigger when property changes into object', () {
          $rootScope.obj = 'test';
          $rootScope.$digest();
          expect(log).toEqual(['"test"']);

          $rootScope.obj = {};
          $rootScope.$digest();
          expect(log).toEqual(['"test"', '{}']);
        });


        it('should not trigger change when object in collection changes', () {
          $rootScope.obj = {'name': {}};
          $rootScope.$digest();
          expect(log).toEqual(['{"name":{}}']);

          $rootScope.obj['name']['bar'] = 'foo';
          $rootScope.$digest();
          expect(log).toEqual(['{"name":{}}']);
        });


        it('should watch object properties', () {
          $rootScope.obj = {};
          $rootScope.$digest();
          expect(log).toEqual(['{}']);

          $rootScope.obj['a']= 'A';
          $rootScope.$digest();
          expect(log).toEqual(['{}', '{"a":"A"}']);

          $rootScope.obj['a'] = 'B';
          $rootScope.$digest();
          expect(log).toEqual(['{}', '{"a":"A"}', '{"a":"B"}']);

          $rootScope.obj['b'] = [];
          $rootScope.obj['c'] = {};
          log = [];
          $rootScope.$digest();
          expect(log).toEqual(['{"a":"B","b":[],"c":{}}']);

          var temp = $rootScope.obj['a'];
          $rootScope.obj['a'] = $rootScope.obj['b'];
          $rootScope.obj['c'] = temp;
          $rootScope.$digest();
          expect(log).toEqual([ '{"a":"B","b":[],"c":{}}', '{"a":[],"b":[],"c":"B"}' ]);

          $rootScope.obj.remove('a');
          log = [];
          $rootScope.$digest();
          expect(log).toEqual([ '{"b":[],"c":"B"}' ]);
        });
      });
    });


    describe('perf', () {
      describe('counters', () {

        it('should expose scope count', inject((Profiler perf, Scope scope) {
          scope.$digest();
          expect(perf.counters['ng.scopes']).toEqual(1);

          scope.$new();
          scope.$new();
          var lastChild = scope.$new();
          scope.$digest();
          expect(perf.counters['ng.scopes']).toEqual(4);

          // Create a child scope and make sure it's counted as well.
          lastChild.$new();
          scope.$digest();
          expect(perf.counters['ng.scopes']).toEqual(5);
        }));


        it('should update scope count when scope destroyed',
            inject((Profiler perf, Scope scope) {

          var child = scope.$new();
          scope.$digest();
          expect(perf.counters['ng.scopes']).toEqual(2);

          child.$destroy();
          scope.$digest();
          expect(perf.counters['ng.scopes']).toEqual(1);
        }));


        it('should expose watcher count', inject((Profiler perf, Scope scope) {
          scope.$digest();
          expect(perf.counters['ng.scope.watchers']).toEqual(0);

          scope.$watch(() => 0, (_) {});
          scope.$watch(() => 0, (_) {});
          scope.$watch(() => 0, (_) {});
          scope.$digest();
          expect(perf.counters['ng.scope.watchers']).toEqual(3);

          // Create a child scope and make sure it's counted as well.
          scope.$new().$watch(() => 0, (_) {});
          scope.$digest();
          expect(perf.counters['ng.scope.watchers']).toEqual(4);
        }));


        it('should update watcher count when watcher removed',
            inject((Profiler perf, Scope scope) {

          var unwatch = scope.$new().$watch(() => 0, (_) {});
          scope.$digest();
          expect(perf.counters['ng.scope.watchers']).toEqual(1);

          unwatch();
          scope.$digest();
          expect(perf.counters['ng.scope.watchers']).toEqual(0);
        }));
      });
    });


    describe('optimizations', () {
      var scope;
      var log;
      beforeEach(inject((Scope _scope, Logger _log) {
        scope = _scope;
        log = _log;
        scope['a'] = 1;
        scope['b'] = 2;
        scope['c'] = 3;
        scope.$watch(() {log('a'); return scope['a'];}, (value) => log('fire:a'));
        scope.$watch(() {log('b'); return scope['b'];}, (value) => log('fire:b'));
        scope.$watch(() {log('c'); return scope['c'];}, (value) {log('fire:c'); scope['b']++; });
        scope.$digest();
        log.clear();
      }));

      it('should loop once on no dirty', () {
        scope.$digest();
        expect(log.result()).toEqual('a; b; c');
      });

      it('should exit early on second loop', () {
        scope['b']++;
        scope.$digest();
        expect(log.result()).toEqual('a; b; fire:b; c; a');
      });

      it('should continue checking if second loop dirty', () {
        scope['c']++;
        scope.$digest();
        expect(log.result()).toEqual('a; b; c; fire:c; a; b; fire:b; c; a');
      });
    });

    describe('ScopeLocals', () {
      var scope;

      beforeEach(inject((Scope _scope) => scope = _scope));

      it('should read from locals', () {
        scope['a'] = 'XXX';
        scope['c'] = 'C';
        var scopeLocal = new ScopeLocals(scope, {'a': 'A', 'b': 'B'});
        expect(scopeLocal['a']).toEqual('A');
        expect(scopeLocal['b']).toEqual('B');
        expect(scopeLocal['c']).toEqual('C');
      });

      it('should write to Scope', () {
        scope['a'] = 'XXX';
        scope['c'] = 'C';
        var scopeLocal = new ScopeLocals(scope, {'a': 'A', 'b': 'B'});

        scopeLocal['a'] = 'aW';
        scopeLocal['b'] = 'bW';
        scopeLocal['c'] = 'cW';

        expect(scope['a']).toEqual('aW');
        expect(scope['b']).toEqual('bW');
        expect(scope['c']).toEqual('cW');

        expect(scopeLocal['a']).toEqual('A');
        expect(scopeLocal['b']).toEqual('B');
        expect(scopeLocal['c']).toEqual('cW');
      });
    });

    describe('filters', () {

      it('should use filters from correct scope when digesting scope trees', inject((Scope rootScope, Injector injector) {
        var withFilterOne = injector.createChild([new Module()..type(FilterOne)],
            forceNewInstances: [FilterMap]).get(FilterMap);
        var withFilterTwo = injector.createChild([new Module()..type(FilterTwo)],
            forceNewInstances: [FilterMap]).get(FilterMap);

        var childScopeOne = rootScope.$new(filters: withFilterOne);
        var childScopeTwo = rootScope.$new(filters: withFilterTwo);

        var valueOne;
        var valueTwo;
        childScopeOne.$watch('"str" | newFilter', (val) => valueOne = val);
        childScopeTwo.$watch('"str" | newFilter', (val) => valueTwo = val);

        rootScope.$digest();

        expect(valueOne).toEqual('str 1');
        expect(valueTwo).toEqual('str 2');
      }));

    });
  });
}

_toJsonableIterable(Iterable source) => new _JsonableIterableWrapper(source);

class _JsonableIterableWrapper<T> implements Iterable<T> {
  final Iterable<T> source;

  _JsonableIterableWrapper(this.source);

  bool any(bool test(T element)) => source.any(test);

  bool contains(Object element) => source.contains(element);

  T elementAt(int index) => source.elementAt(index);

  bool every(bool test(T element)) => source.every(test);

  Iterable expand(Iterable f(T element)) => source.expand(f);

  T get first => source.first;

  T firstWhere(bool test(T element), {T orElse()}) =>
      source.firstWhere(test, orElse: orElse);

  fold(initialValue, combine(previousValue, T element)) =>
      source.fold(initialValue, combine);

  void forEach(void f(T element)) => source.forEach(f);

  bool get isEmpty => source.isEmpty;

  bool get isNotEmpty => source.isNotEmpty;

  Iterator<T> get iterator => source.iterator;

  String join([String separator = ""]) => source.join(separator);

  T get last => source.last;

  T lastWhere(bool test(T element), {T orElse()}) =>
      source.lastWhere(test, orElse: orElse);

  int get length => source.length;

  Iterable map(f(T element)) => source.map(f);

  T reduce(T combine(T value, T element)) => source.reduce(combine);

  T get single => source.single;

  T singleWhere(bool test(T element)) => source.singleWhere(test);

  Iterable<T> skip(int n) => source.skip(n);

  Iterable<T> skipWhile(bool test(T value)) => source.skipWhile(test);

  Iterable<T> take(int n) => source.take(n);

  Iterable<T> takeWhile(bool test(T value)) => source.takeWhile(test);

  List<T> toList({bool growable: true}) => source.toList(growable: growable);

  Set<T> toSet() => source.toSet();

  Iterable<T> where(bool test(T element)) => source.where(test);

  toJson() => source.toList();
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
