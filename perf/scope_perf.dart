library scope_perf;

import '_perf.dart';
import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/new_eval.dart'
    show ParserBackend, ParserBackendForEvaluation;
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

main() {
  var scope = new DynamicInjector(
      modules: [new Module()
        ..type(Parser, implementedBy: DynamicParser)
        ..type(ParserBackend, implementedBy: ParserBackendForEvaluation)],
      allowImplicitInjection:true).get(Scope);
  var scope2, scope3, scope4, scope5;
  var fill = (scope) {
    for(var i = 0; i < 10000; i++) {
      scope['key_$i'] = i;
    }
    return scope;
  };

  scope = fill(scope);
  scope2 = fill(scope.$new());
  scope3 = fill(scope2.$new());
  scope4 = fill(scope3.$new());
  scope5 = fill(scope4.$new());

  time('noop', () {});

  time('empty scope \$digest()', () {
    scope.$digest();
  });

  scope.a = new A();

  List watchFns = new List.generate(4000, (i) => () => i);
  time('adding/removing 4000 watchers', () {
    List watchers = watchFns.map(scope.$watch).toList();
    watchers.forEach((e) => e());
  });

  List watchers = watchFns.map(scope.$watch).toList();
  time('4000 dummy watchers on scope', () => scope.$digest());
  watchers.forEach((e) => e());

  for(var i = 0; i < 1000; i++ ) {
    scope.$watch('a.number', () => null);
    scope.$watch('a.str', () => null);
    scope.$watch('a.obj', () => null);
  }

  time('3000 watchers on scope', () => scope.$digest());

  //TODO(misko): build matrics of these
  time('scope[] 1 deep', () => scope['nenexistant']);
  time('scope[] 2 deep', () => scope2['nenexistant']);
  time('scope[] 3 deep', () => scope3['nenexistant']);
  time('scope[] 4 deep', () => scope4['nenexistant']);
  time('scope[] 5 deep', () => scope5['nenexistant']);
}

class A {
  var number = 1;
  var str = 'abc';
  var obj = {};
}
