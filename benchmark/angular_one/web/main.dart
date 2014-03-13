import 'dart:html';
import 'package:angular/angular.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular_one/person.dart';
import 'package:angular_one/controller.dart';

class CreteModuleBenchmark extends BenchmarkBase {
  var m;

  CreteModuleBenchmark(): super('CreteModuleBenchmark');

  void run() => m = new BenchmarkModule();

  void tearDown() => m.hashCode;
}

class InstantiateDomBenchmark extends BenchmarkBase {
  InstantiateDomBenchmark(): super('InstantiateDomBenchmark');

  Compiler compiler;
  Injector injector;
  var rootElements;
  var directiveMap;

  void run() {
    compiler(rootElements, directiveMap)(injector, rootElements);
  }

  void setup() {
    injector = ngBootstrap(module: new BenchmarkModule());
    rootElements = [document.body];
    compiler = injector.get(Compiler);
    directiveMap = injector.get(DirectiveMap);
  }
}

void main() {
  new CreteModuleBenchmark()..report();
  new InstantiateDomBenchmark()..report();
}

class BenchmarkModule extends Module {
  BenchmarkModule() {
    install(new PersonModule());
    install(new ControllerModule());
  }
}