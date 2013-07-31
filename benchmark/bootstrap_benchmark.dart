import 'dart:html';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';

class BootstrapBenchmark extends BenchmarkBase {
  BootstrapBenchmark() : super("Bootstrap");

  static void main() {
    new BootstrapBenchmark().report();
  }

  void run() {
    var ngApp = new Element.div();
    ngApp.attributes['ng-app'] = '';
    ngApp.children.add(new Element.div());
    query('#sandbox').children.add(ngApp);

    bootstrapAngular([new AngularModule()]);

    ngApp.remove();
  }

  void setup() {
  }

  void teardown() {
  }
}

main() {
  BootstrapBenchmark.main();
}