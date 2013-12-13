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
});
