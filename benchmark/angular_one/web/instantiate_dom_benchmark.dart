import 'dart:html';
import 'package:angular/angular.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

import 'module.dart';

class InstantiateDomBenchmark extends BenchmarkBase {
  InstantiateDomBenchmark(): super('InstantiateDomBenchmark');

  Compiler compiler;
  Injector injector;
  var rootElements;
  var directiveMap;
  var view;

  void run() {
    view = compiler(rootElements, directiveMap)(injector, rootElements);
  }

  void setup() {
    injector = ngBootstrap(module: new BenchmarkModule());
    rootElements = [document.body];
    compiler = injector.get(Compiler);
    directiveMap = injector.get(DirectiveMap);
  }

  void teardown() {
    view.hashCode;
  }
}

void main() {
  new InstantiateDomBenchmark()..report();
}