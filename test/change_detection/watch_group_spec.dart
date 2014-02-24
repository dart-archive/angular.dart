library watch_group_spec;

import '../_specs.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'dirty_checking_change_detector_spec.dart' hide main;

main() => describe('WatchGroup', () {
  var context;
  var watchGrp;
  DirtyCheckingChangeDetector changeDetector;
  Logger logger;

  AST parse(String expression) {
    var currentAST = new ContextReferenceAST();
    expression.split('.').forEach((name) {
      currentAST = new FieldReadAST(currentAST, name);
    });
    return currentAST;
  }

  expectOrder(list) {
    logger.clear();
    watchGrp.detectChanges(); // Clear the initial queue
    logger.clear();
    watchGrp.detectChanges();
    expect(logger).toEqual(list);
  }

  beforeEach(inject((Logger _logger) {
    context = {};
    changeDetector = new DirtyCheckingChangeDetector(new GetterCache({}));
    watchGrp = new RootWatchGroup(changeDetector, context);
    logger = _logger;
  }));

  describe('watch lifecycle', () {
    it('should prevent reaction fn on removed', () {
      context['a'] = 'hello';
      var watch ;
      watchGrp.watch(parse('a'), (v, p) {
        logger('removed');
        watch.remove();
      });
      watch = watchGrp.watch(parse('a'), (v, p) => logger(v));
      watchGrp.detectChanges();
      expect(logger).toEqual(['removed']);
    });
  });

  describe('property chaining', () {
    it('should read property', () {
      context['a'] = 'hello';

      // should fire on initial adding
      expect(watchGrp.fieldCost).toEqual(0);
      var watch = watchGrp.watch(parse('a'), (v, p) => logger(v));
      expect(watch.expression).toEqual('a');
      expect(watchGrp.fieldCost).toEqual(1);
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra detectChanges
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // Should detect value change
      context['a'] = 'bye';
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello', 'bye']);

      // should cleanup after itself
      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      context['a'] = 'cant see me';
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello', 'bye']);
    });

    it('should read property chain', () {
      context['a'] = {'b': 'hello'};

      // should fire on initial adding
      expect(watchGrp.fieldCost).toEqual(0);
      expect(changeDetector.count).toEqual(0);
      var watch = watchGrp.watch(parse('a.b'), (v, p) => logger(v));
      expect(watch.expression).toEqual('a.b');
      expect(watchGrp.fieldCost).toEqual(2);
      expect(changeDetector.count).toEqual(2);
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra detectChanges
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // make sure no changes or logged when intermediary object changes
      context['a'] = {'b': 'hello'};
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // Should detect value change
      context['a'] = {'b': 'hello2'};
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello', 'hello2']);

      // Should detect value change
      context['a']['b'] = 'bye';
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello', 'hello2', 'bye']);

      // should cleanup after itself
      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      context['a']['b'] = 'cant see me';
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello', 'hello2', 'bye']);
    });

    it('should reuse handlers', () {
      var user1 = {'first': 'misko', 'last': 'hevery'};
      var user2 = {'first': 'misko', 'last': 'Hevery'};

      context['user'] = user1;

      // should fire on initial adding
      expect(watchGrp.fieldCost).toEqual(0);
      var watch = watchGrp.watch(parse('user'), (v, p) => logger(v));
      var watchFirst = watchGrp.watch(parse('user.first'), (v, p) => logger(v));
      var watchLast = watchGrp.watch(parse('user.last'), (v, p) => logger(v));
      expect(watchGrp.fieldCost).toEqual(3);

      watchGrp.detectChanges();
      expect(logger).toEqual([user1, 'misko', 'hevery']);
      logger.clear();

      context['user'] = user2;
      watchGrp.detectChanges();
      expect(logger).toEqual([user2, 'Hevery']);


      watch.remove();
      expect(watchGrp.fieldCost).toEqual(3);

      watchFirst.remove();
      expect(watchGrp.fieldCost).toEqual(2);

      watchLast.remove();
      expect(watchGrp.fieldCost).toEqual(0);

      expect(() => watch.remove()).toThrow('Already deleted!');
    });

    it('should eval pure FunctionApply', () {
      context['a'] = {'val': 1};

      FunctionApply fn = new LoggingFunctionApply(logger);
      var watch = watchGrp.watch(
          new PureFunctionAST('add', fn, [parse('a.val')]),
          (v, p) => logger(v)
      );

      // a; a.val; b; b.val;
      expect(watchGrp.fieldCost).toEqual(2);
      // add
      expect(watchGrp.evalCost).toEqual(1);

      watchGrp.detectChanges();
      expect(logger).toEqual([[1], null]);
      logger.clear();

      context['a'] = {'val': 2};
      watchGrp.detectChanges();
      expect(logger).toEqual([[2]]);
    });


    it('should eval pure function', () {
      context['a'] = {'val': 1};
      context['b'] = {'val': 2};

      var watch = watchGrp.watch(
         new PureFunctionAST('add',
             (a, b) { logger('+'); return a+b; },
             [parse('a.val'), parse('b.val')]
         ),
         (v, p) => logger(v)
      );

      // a; a.val; b; b.val;
      expect(watchGrp.fieldCost).toEqual(4);
      // add
      expect(watchGrp.evalCost).toEqual(1);

      watchGrp.detectChanges();
      expect(logger).toEqual(['+', 3]);

      // extra checks should not trigger functions
      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual(['+', 3]);

      // multiple arg changes should only trigger function once.
      context['a']['val'] = 3;
      context['b']['val'] = 4;

      watchGrp.detectChanges();
      expect(logger).toEqual(['+', 3, '+', 7]);

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      context['a']['val'] = 0;
      context['b']['val'] = 0;

      watchGrp.detectChanges();
      expect(logger).toEqual(['+', 3, '+', 7]);
    });


    it('should eval chained pure function', () {
      context['a'] = {'val': 1};
      context['b'] = {'val': 2};
      context['c'] = {'val': 3};

      var a_plus_b = new PureFunctionAST('add1',
          (a, b) { logger('$a+$b'); return a + b; },
          [parse('a.val'), parse('b.val')]);

      var a_plus_b_plus_c = new PureFunctionAST('add2',
          (b, c) { logger('$b+$c'); return b + c; },
          [a_plus_b, parse('c.val')]);

      var watch = watchGrp.watch(a_plus_b_plus_c, (v, p) => logger(v));

      // a; a.val; b; b.val; c; c.val;
      expect(watchGrp.fieldCost).toEqual(6);
      // add
      expect(watchGrp.evalCost).toEqual(2);

      watchGrp.detectChanges();
      expect(logger).toEqual(['1+2', '3+3', 6]);
      logger.clear();

      // extra checks should not trigger functions
      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual([]);
      logger.clear();

      // multiple arg changes should only trigger function once.
      context['a']['val'] = 3;
      context['b']['val'] = 4;
      context['c']['val'] = 5;
      watchGrp.detectChanges();
      expect(logger).toEqual(['3+4', '7+5', 12]);
      logger.clear();

      context['a']['val'] = 9;
      watchGrp.detectChanges();
      expect(logger).toEqual(['9+4', '13+5', 18]);
      logger.clear();

      context['c']['val'] = 9;
      watchGrp.detectChanges();
      expect(logger).toEqual(['13+9', 22]);
      logger.clear();


      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      context['a']['val'] = 0;
      context['b']['val'] = 0;

      watchGrp.detectChanges();
      expect(logger).toEqual([]);
    });


    it('should eval closure', () {
      var obj;
      obj = {
          'methodA': (arg1) {
            logger('methodA($arg1) => ${obj['valA']}');
            return obj['valA'];
          },
          'valA': 'A'
      };
      context['obj'] = obj;
      context['arg0'] = 1;

      var watch = watchGrp.watch(
          new MethodAST(parse('obj'), 'methodA', [parse('arg0')]),
              (v, p) => logger(v)
      );

      // obj, arg0;
      expect(watchGrp.fieldCost).toEqual(2);
      // methodA()
      expect(watchGrp.evalCost).toEqual(1);

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(1) => A', 'A']);
      logger.clear();

      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(1) => A', 'methodA(1) => A']);
      logger.clear();

      obj['valA'] = 'B';
      context['arg0'] = 2;

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(2) => B', 'B']);
      logger.clear();

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      obj['valA'] = 'C';
      context['arg0'] = 3;

      watchGrp.detectChanges();
      expect(logger).toEqual([]);
    });


    it('should eval method', () {
      var obj = new MyClass(logger);
      obj.valA = 'A';
      context['obj'] = obj;
      context['arg0'] = 1;

      var watch = watchGrp.watch(
          new MethodAST(parse('obj'), 'methodA', [parse('arg0')]),
              (v, p) => logger(v)
      );

      // obj, arg0;
      expect(watchGrp.fieldCost).toEqual(2);
      // methodA()
      expect(watchGrp.evalCost).toEqual(1);

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(1) => A', 'A']);
      logger.clear();

      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(1) => A', 'methodA(1) => A']);
      logger.clear();

      obj.valA = 'B';
      context['arg0'] = 2;

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(2) => B', 'B']);
      logger.clear();

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      obj.valA = 'C';
      context['arg0'] = 3;

      watchGrp.detectChanges();
      expect(logger).toEqual([]);
    });

    it('should eval method chain', () {
      var obj1 = new MyClass(logger);
      var obj2 = new MyClass(logger);
      obj1.valA = obj2;
      obj2.valA = 'A';
      context['obj'] = obj1;
      context['arg0'] = 0;
      context['arg1'] = 1;

      // obj.methodA(arg0)
      var ast = new MethodAST(parse('obj'), 'methodA', [parse('arg0')]);
      ast = new MethodAST(ast, 'methodA', [parse('arg1')]);
      var watch = watchGrp.watch(ast, (v, p) => logger(v));

      // obj, arg0, arg1;
      expect(watchGrp.fieldCost).toEqual(3);
      // methodA(), mothodA()
      expect(watchGrp.evalCost).toEqual(2);

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(0) => MyClass', 'methodA(1) => A', 'A']);
      logger.clear();

      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(0) => MyClass', 'methodA(1) => A',
      'methodA(0) => MyClass', 'methodA(1) => A']);
      logger.clear();

      obj2.valA = 'B';
      context['arg0'] = 10;
      context['arg1'] = 11;

      watchGrp.detectChanges();
      expect(logger).toEqual(['methodA(10) => MyClass', 'methodA(11) => B', 'B']);
      logger.clear();

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      obj2.valA = 'C';
      context['arg0'] = 20;
      context['arg1'] = 21;

      watchGrp.detectChanges();
      expect(logger).toEqual([]);
    });

    it('should read connstant', () {
      // should fire on initial adding
      expect(watchGrp.fieldCost).toEqual(0);
      var watch = watchGrp.watch(new ConstantAST(123), (v, p) => logger(v));
      expect(watch.expression).toEqual('123');
      expect(watchGrp.fieldCost).toEqual(0);
      watchGrp.detectChanges();
      expect(logger).toEqual([123]);

      // make sore no new changes are logged on extra detectChanges
      watchGrp.detectChanges();
      expect(logger).toEqual([123]);
    });

    it('should wrap iterable in ObservableList', () {
      context['list'] = [];
      var watch = watchGrp.watch(new CollectionAST(parse('list')), (v, p) => logger(v));

      expect(watchGrp.fieldCost).toEqual(1);
      expect(watchGrp.collectionCost).toEqual(1);
      expect(watchGrp.evalCost).toEqual(0);

      watchGrp.detectChanges();
      expect(logger.length).toEqual(1);
      expect(logger[0], toEqualCollectionRecord(
          collection: [],
          additions: [],
          moves: [],
          removals: []));
      logger.clear();

      context['list'] = [1];
      watchGrp.detectChanges();
      expect(logger.length).toEqual(1);
      expect(logger[0], toEqualCollectionRecord(
          collection: ['1[null -> 0]'],
          additions: ['1[null -> 0]'],
          moves: [],
          removals: []));
      logger.clear();

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.collectionCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);
    });

    it('should watch literal arrays made of expressions', () {
      context['a'] = 1;
      var ast = new CollectionAST(
        new PureFunctionAST('[a]', new ArrayFn(), [parse('a')])
      );
      var watch = watchGrp.watch(ast, (v, p) => logger(v));
      watchGrp.detectChanges();
      expect(logger[0], toEqualCollectionRecord(
          collection: ['1[null -> 0]'],
          additions: ['1[null -> 0]'],
          moves: [],
          removals: []));
      logger.clear();

      context['a'] = 2;
      watchGrp.detectChanges();
      expect(logger[0], toEqualCollectionRecord(
          collection: ['2[null -> 0]'],
          additions: ['2[null -> 0]'],
          moves: [],
          removals: ['1[0 -> null]']));
      logger.clear();
    });

    it('should watch pure function whose result goes to pure function', () {
      context['a'] = 1;
      var ast = new PureFunctionAST(
          '-',
          (v) => -v,
          [new PureFunctionAST('++', (v) => v + 1, [parse('a')])]
      );
      var watch = watchGrp.watch(ast, (v, p) => logger(v));

      expect(watchGrp.detectChanges()).not.toBe(null);
      expect(logger).toEqual([-2]);
      logger.clear();

      context['a'] = 2;
      expect(watchGrp.detectChanges()).not.toBe(null);
      expect(logger).toEqual([-3]);
    });
  });

  describe('child group', () {
    it('should remove all field watches in group and group\'s children', () {
      watchGrp.watch(parse('a'), (v, p) => logger('0a'));
      var child1a = watchGrp.newGroup(new PrototypeMap(context));
      var child1b = watchGrp.newGroup(new PrototypeMap(context));
      var child2 = child1a.newGroup(new PrototypeMap(context));
      child1a.watch(parse('a'), (v, p) => logger('1a'));
      child1b.watch(parse('a'), (v, p) => logger('1b'));
      watchGrp.watch(parse('a'), (v, p) => logger('0A'));
      child1a.watch(parse('a'), (v, p) => logger('1A'));
      child2.watch(parse('a'), (v, p) => logger('2A'));

      // flush initial reaction functions
      expect(watchGrp.detectChanges()).toEqual(6);
      // expect(logger).toEqual(['0a', '0A', '1a', '1A', '2A', '1b']);
      expect(logger).toEqual(['0a', '1a', '1b', '0A', '1A', '2A']); // we go by registration order
      expect(watchGrp.fieldCost).toEqual(1);
      expect(watchGrp.totalFieldCost).toEqual(4);
      logger.clear();

      context['a'] = 1;
      expect(watchGrp.detectChanges()).toEqual(6);
      expect(logger).toEqual(['0a', '0A', '1a', '1A', '2A', '1b']); // we go by group order
      logger.clear();

      context['a'] = 2;
      child1a.remove(); // should also remove child2
      expect(watchGrp.detectChanges()).toEqual(3);
      expect(logger).toEqual(['0a', '0A', '1b']);
      expect(watchGrp.fieldCost).toEqual(1);
      expect(watchGrp.totalFieldCost).toEqual(2);
    });

    it('should remove all method watches in group and group\'s children', () {
      context['my'] = new MyClass(logger);
      AST countMethod = new MethodAST(parse('my'), 'count', []);
      watchGrp.watch(countMethod, (v, p) => logger('0a'));
      expectOrder(['0a']);

      var child1a = watchGrp.newGroup(new PrototypeMap(context));
      var child1b = watchGrp.newGroup(new PrototypeMap(context));
      var child2 = child1a.newGroup(new PrototypeMap(context));
      child1a.watch(countMethod, (v, p) => logger('1a'));
      expectOrder(['0a', '1a']);
      child1b.watch(countMethod, (v, p) => logger('1b'));
      expectOrder(['0a', '1a', '1b']);
      watchGrp.watch(countMethod, (v, p) => logger('0A'));
      expectOrder(['0a', '0A', '1a', '1b']);
      child1a.watch(countMethod, (v, p) => logger('1A'));
      expectOrder(['0a', '0A', '1a', '1A', '1b']);
      child2.watch(countMethod, (v, p) => logger('2A'));
      expectOrder(['0a', '0A', '1a', '1A', '2A', '1b']);

      // flush initial reaction functions
      expect(watchGrp.detectChanges()).toEqual(6);
      expectOrder(['0a', '0A', '1a', '1A', '2A', '1b']);

      child1a.remove(); // should also remove child2
      expect(watchGrp.detectChanges()).toEqual(3);
      expectOrder(['0a', '0A', '1b']);
    });

    it('should add watches within its own group', () {
      context['my'] = new MyClass(logger);
      AST countMethod = new MethodAST(parse('my'), 'count', []);
      var ra = watchGrp.watch(countMethod, (v, p) => logger('a'));
      var child = watchGrp.newGroup(new PrototypeMap(context));
      var cb = child.watch(countMethod, (v, p) => logger('b'));

      expectOrder(['a', 'b']);
      expectOrder(['a', 'b']);

      ra.remove();
      expectOrder(['b']);

      cb.remove();
      expectOrder([]);

      // TODO: add them back in wrong order, assert events in right order
      cb = child.watch(countMethod, (v, p) => logger('b'));
      ra = watchGrp.watch(countMethod, (v, p) => logger('a'));;
      expectOrder(['a', 'b']);
    });


    it('should not call reaction function on removed group', () {
      var log = [];
      context['name'] = 'misko';
      var child = watchGrp.newGroup(context);
      watchGrp.watch(parse('name'), (v, _) {
        log.add('root $v');
        if (v == 'destroy') {
          child.remove();
        }
      });
      child.watch(parse('name'), (v, _) => log.add('child $v'));
      watchGrp.detectChanges();
      expect(log).toEqual(['root misko', 'child misko']);
      log.clear();

      context['name'] = 'destroy';
      watchGrp.detectChanges();
      expect(log).toEqual(['root destroy']);
    });



    it('should watch children', () {
      var childContext = new PrototypeMap(context);
      context['a'] = 'OK';
      context['b'] = 'BAD';
      childContext['b'] = 'OK';
      watchGrp.watch(parse('a'), (v, p) => logger(v));
      watchGrp.newGroup(childContext).watch(parse('b'), (v, p) => logger(v));

      watchGrp.detectChanges();
      expect(logger).toEqual(['OK', 'OK']);
      logger.clear();

      context['a'] = 'A';
      childContext['b'] = 'B';

      watchGrp.detectChanges();
      expect(logger).toEqual(['A', 'B']);
      logger.clear();
    });
  });

});

class MyClass {
  final Logger logger;
  var valA;
  int _count = 0;

  MyClass(this.logger);

  methodA(arg1) {
    logger('methodA($arg1) => $valA');
    return valA;
  }

  count() => _count++;

  String toString() => 'MyClass';
}

class LoggingFunctionApply extends FunctionApply {
  Logger logger;
  LoggingFunctionApply(this.logger);
  apply(List args) => logger(args);
}
