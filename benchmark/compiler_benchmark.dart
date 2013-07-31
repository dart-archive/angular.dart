import 'dart:html';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';

class CompilerBenchmark extends BenchmarkBase {
  CompilerBenchmark() : super("Compiler");

  static void main() {
    new CompilerBenchmark().report();
  }

  Compiler compiler;

  void run() {
    StringBuffer sb = new StringBuffer();
    sb.writeln('<div>');
    for (int i = 0; i < 100; i++) {
      sb.writeln('<test-transcluding><span>Transcluded Content</span></test-transcluding>');
      sb.writeln('<test-templated></test-templated>');
    }
    sb.writeln('</div>');
    compiler([new Element.html(sb.toString())]);
  }

  void setup() {
    var module = new AngularModule()
      ..directive(TestTranscludingDirective)
      ..directive(TestTemplatedComponent);
    Injector injector = new Injector([module]);
    compiler = injector.get(Compiler);
  }

  void teardown() {
    compiler = null;
  }
}

@NgDirective(transclude: true)
class TestTranscludingDirective {
}

@NgComponent(template: '<div>Hello World!</div>')
class TestTemplatedComponent {
}

main() {
  CompilerBenchmark.main();
}