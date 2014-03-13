import 'package:angular/angular.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

import 'module.dart';

class CreteModuleBenchmark extends BenchmarkBase {
  var m;

  CreteModuleBenchmark(): super('CreteModuleBenchmark');

  void run() {
    m = new BenchmarkModule();
  }

  void teardown() {
    m.hashCode;
  }
}

void main() {
  new CreteModuleBenchmark()..report();
}