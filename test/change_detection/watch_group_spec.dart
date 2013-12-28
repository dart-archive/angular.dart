library scope2_spec;

import '../_specs.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() => ddescribe('WatchGroup', () {
  var context;
  var watchGrp;
  Logger logger;

  AST parse(String expression) {
    var currentAST = new ContextReferenceAST();
    expression.split('.').forEach((name) {
      currentAST = new FieldReadAST(currentAST, name);
    });
    return currentAST;
  }

  beforeEach(inject((Logger _logger) {
    context = {};
    watchGrp = new WatchGroup(new DirtyCheckingChangeDetector(), context);
    logger = _logger;
  }));

  describe('property chaining', () {
    it('should read property', () {
      context['a'] = 'hello';

      // should fire on initial adding
      expect(watchGrp.fieldCost).toEqual(0);
      var watch = watchGrp.watch(parse('a'), (v, p, o) => logger(v));
      expect(watch.expression).toEqual('a');
      expect(watchGrp.fieldCost).toEqual(1);
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra detectChangess
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
      var watch = watchGrp.watch(parse('a.b'), (v, p, o) => logger(v));
      expect(watch.expression).toEqual('a.b');
      expect(watchGrp.fieldCost).toEqual(2);
      watchGrp.detectChanges();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra detectChangess
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
      var watch = watchGrp.watch(parse('user'), (v, p, o) => logger(v));
      var watchFirst = watchGrp.watch(parse('user.first'), (v, p, o) => logger(v));
      var watchLast = watchGrp.watch(parse('user.last'), (v, p, o) => logger(v));
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

    it('should eval function', () {
      context['a'] = {'val': 1};
      context['b'] = {'val': 2};

      var watch = watchGrp.watch(
          new FunctionAST('add', (a, b) => a+b, [parse('a.val'), parse('b.val')]),
          (v, p, o) => logger(v)
      );

      // a; a.val; b; b.val;
      expect(watchGrp.fieldCost).toEqual(4);
      // add
      expect(watchGrp.evalCost).toEqual(1);

      watchGrp.detectChanges();
      expect(logger).toEqual([3]);

      watchGrp.detectChanges();
      watchGrp.detectChanges();
      expect(logger).toEqual([3]);

      context['a']['val'] = 3;
      context['b']['val'] = 4;

      watchGrp.detectChanges();
      expect(logger).toEqual([3, 7]);

      watch.remove();
      expect(watchGrp.fieldCost).toEqual(0);
      expect(watchGrp.evalCost).toEqual(0);

      context['a']['val'] = 0;
      context['b']['val'] = 0;

      watchGrp.detectChanges();
      expect(logger).toEqual([3, 7]);
    });

    it('should eval method', () {
      var obj = new MyClass(logger);
      obj.valA = 'A';
      context['obj'] = obj;
      context['arg0'] = 1;

      var watch = watchGrp.watch(
          new MethodAST(parse('obj'), 'methodA', [parse('arg0')]),
              (v, p, o) => logger(v)
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
    var watch = watchGrp.watch(ast, (v, p, o) => logger(v));

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
});

class MyClass {
  final Logger logger;
  var valA;

  MyClass(this.logger);

  methodA(arg1) {
    logger('methodA($arg1) => $valA');
    return valA;
  }

  toString() => 'MyClass';
}
