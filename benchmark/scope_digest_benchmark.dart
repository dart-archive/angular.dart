import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';

class ScopeDigestBenchmark extends BenchmarkBase {
  ScopeDigestBenchmark() : super("ScopeDigest");

  static void main() {
    new ScopeDigestBenchmark().report();
  }

  Interpolate interpolator;
  Scope rootScope;

  void run() {
    var testScope = rootScope.$new();
    // Simulating a repeater repeating a component with a simple template.
    for (int i = 0; i < 100; i++) {
      var childScope = testScope.$new();
      childScope['hello'] = new TestObject();
      childScope.$watch(interpolator('{{hello.sayHello()}}'), (_) {});
    }
    testScope.$digest();
    testScope.$destroy();
  }

  void setup() {
    Injector injector = new Injector([new AngularModule()]);
    interpolator = injector.get(Interpolate);
    rootScope = injector.get(Scope);
  }

  void teardown() {
    interpolator = null;
    rootScope = null;
  }
}

class TestObject {
  String sayHello() => 'hello';
}

main() {
  ScopeDigestBenchmark.main();
}