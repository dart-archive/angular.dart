import 'dart:html';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';

class BlockFactoryBenchmark extends BenchmarkBase {
  BlockFactoryBenchmark() : super("BlockFactory");

  static void main() {
    new BlockFactoryBenchmark().report();
  }

  Injector injector;
  BlockFactory blockFactory;

  void run() {
    blockFactory(injector);
  }

  void setup() {
    var module = new AngularModule()
      ..directive(TestTranscludingDirective)
      ..directive(TestTemplatedComponent);
    injector = new Injector([module]);
    Compiler compiler = injector.get(Compiler);
    StringBuffer sb = new StringBuffer();
    sb.writeln('<div>');
    for (int i = 0; i < 100; i++) {
      sb.writeln('<div><test-templated>Hello</test-templated></div>');
      sb.writeln('<div><test-transcluding><span>Transcluded Content</span>'
          '</test-transcluding></div>');
    }
    sb.writeln('</div>');
    blockFactory = compiler([new Element.html(sb.toString())]);
  }

  void teardown() {
    injector = null;
    blockFactory = null;
    dumpTimerStats();
  }
}

@NgDirective(transclude: true)
class TestTranscludingDirective {
  TestTranscludingDirective(BoundBlockFactory blockFactory, BlockHole anchor, Scope scope) {
    blockFactory(scope).insertAfter(anchor);
  }
}

@NgComponent(template: '<div>Hello World!</div><content></content>')
class TestTemplatedComponent {
}

main() {
  BlockFactoryBenchmark.main();
}