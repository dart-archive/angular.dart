library scope2_spec;

import '../_specs.dart';
import 'package:angular/change_detection/scope2.dart';

main() => ddescribe('Scope2', () {
  var context;
  var scope;
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
    scope = new Scope2(context);
    logger = _logger;
  }));

  describe('property chaining', () {
    it('should read property', () {
      context['a'] = 'hello';

      // should fire on initial adding
      expect(scope.watchCost).toEqual(0);
      var watch = scope.watch(parse('a'), (v, p, o) => logger(v));
      expect(watch.expression).toEqual('a');
      expect(scope.watchCost).toEqual(1);
      scope.digest();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra digests
      scope.digest();
      expect(logger).toEqual(['hello']);

      // Should detect value change
      context['a'] = 'bye';
      scope.digest();
      expect(logger).toEqual(['hello', 'bye']);

      // should cleanup after itself
      watch.remove();
      expect(scope.watchCost).toEqual(0);
      context['a'] = 'cant see me';
      scope.digest();
      expect(logger).toEqual(['hello', 'bye']);
    });

    it('should read property chain', () {
      context['a'] = {'b': 'hello'};

      // should fire on initial adding
      expect(scope.watchCost).toEqual(0);
      var watch = scope.watch(parse('a.b'), (v, p, o) => logger(v));
      expect(watch.expression).toEqual('a.b');
      expect(scope.watchCost).toEqual(2);
      scope.digest();
      expect(logger).toEqual(['hello']);

      // make sore no new changes are logged on extra digests
      scope.digest();
      expect(logger).toEqual(['hello']);

      // make sure no changes or logged when intermediary object changes
      context['a'] = {'b': 'hello'};
      scope.digest();
      expect(logger).toEqual(['hello']);

      // Should detect value change
      context['a'] = {'b': 'hello2'};
      scope.digest();
      expect(logger).toEqual(['hello', 'hello2']);

      // Should detect value change
      context['a']['b'] = 'bye';
      scope.digest();
      expect(logger).toEqual(['hello', 'hello2', 'bye']);

      // should cleanup after itself
      watch.remove();
      expect(scope.watchCost).toEqual(0);
      context['a']['b'] = 'cant see me';
      scope.digest();
      expect(logger).toEqual(['hello', 'hello2', 'bye']);
    });

    it('should reuse handlers', () {
      var user1 = {'first': 'misko', 'last': 'hevery'};
      var user2 = {'first': 'misko', 'last': 'Hevery'};

      context['user'] = user1;

      // should fire on initial adding
      expect(scope.watchCost).toEqual(0);
      var watch = scope.watch(parse('user'), (v, p, o) => logger(v));
      var watchFirst = scope.watch(parse('user.first'), (v, p, o) => logger(v));
      var watchLast = scope.watch(parse('user.last'), (v, p, o) => logger(v));
      expect(scope.watchCost).toEqual(3);

      scope.digest();
      expect(logger).toEqual([user1, 'misko', 'hevery']);
      logger.clear();

      context['user'] = user2;
      scope.digest();
      expect(logger).toEqual([user2, 'Hevery']);


      watch.remove();
      expect(scope.watchCost).toEqual(3);

      watchFirst.remove();
      expect(scope.watchCost).toEqual(2);

      watchLast.remove();
      expect(scope.watchCost).toEqual(0);

      expect(() => watch.remove()).toThrow('Already deleted!');
    });

    it('should eval function', () {
      context['a'] = {'val': 1};
      context['b'] = {'val': 2};

      var watch = scope.watch(
          new FunctionAST('add', (a, b) => a+b, [parse('a.val'), parse('b.val')]),
          (v, p, o) => logger(v)
      );

      // a; a.val; b; b.val;
      expect(scope.watchCost).toEqual(4);
      // add
      expect(scope.evalCost).toEqual(1);

      scope.digest();
      expect(logger).toEqual([3]);

      scope.digest();
      scope.digest();
      expect(logger).toEqual([3]);

      context['a']['val'] = 3;
      context['b']['val'] = 4;

      scope.digest();
      expect(logger).toEqual([3, 7]);

      watch.remove();
      expect(scope.watchCost).toEqual(0);
      expect(scope.evalCost).toEqual(0);

      context['a']['val'] = 0;
      context['b']['val'] = 0;

      scope.digest();
      expect(logger).toEqual([3, 7]);
    });
  });

  // test gc of evalFunctions
  // test evalFunction Cost count
  // test two separate loops
  // test digest multiloop.
  // test flush single loop, check no second change.
});

