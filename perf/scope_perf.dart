library scope_perf;

import "_perf.dart";
import "dart:async";
import "package:angular/scope.dart";
import "package:angular/parser/parser_library.dart";
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

main() {
  var scope = new DynamicInjector(
      modules: [new Module()
        ..type(Parser, implementedBy: DynamicParser)],
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
