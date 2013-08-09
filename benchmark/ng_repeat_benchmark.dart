import 'dart:html';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';

class NgRepeatBenchmark extends BenchmarkBase {
  NgRepeatBenchmark() : super("NgRepeat");

  static void main() {
    new NgRepeatBenchmark().report();
  }

  Injector injector;
  Scope rootScope;
  BlockFactory blockFactory;

  void run() {
    var vals = <int>[];
    for(int i = 0; i < 100; i++) {
      vals.add(i);
    }
    Scope scope = rootScope.$new(true);
    scope.vals = vals;

    blockFactory(injector.createChild([new ScopeModule(scope)]));
    scope.$digest();
    scope.$destroy();
  }

  void setup() {
    var module = new AngularModule();
    injector = new Injector([module]);
    rootScope = injector.get(Scope);
    Compiler compiler = injector.get(Compiler);
    String html = '<div ng-repeat="val in vals">{{i}}</div>';
    blockFactory = compiler([new Element.html(html)]);
  }

  void teardown() {
    injector = null;
    rootScope = null;
    blockFactory = null;
    dumpTimerStats();
  }
}

main() {
  NgRepeatBenchmark.main();
}