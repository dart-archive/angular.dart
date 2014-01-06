import 'package:benchmark_harness/benchmark_harness.dart';

class IterationBenchmark extends BenchmarkBase {
  List<int> list = new List.generate(1000, (i) => i);
  var r = 0;
  IterationBenchmark(name) : super(name);
}

class ForEach extends IterationBenchmark {
  ForEach() : super('forEach');
  run() {
    var count = 0;
    list.forEach((int i) => count = count + i);
    return count;
  }
}

class ForIn extends IterationBenchmark {
  ForIn() : super('for in');
  run() {
    var count = 0;
    for(int item in list) {
      count = count + item;
    }
    return count;
  }
}

class ForLoop extends IterationBenchmark {
  ForLoop() : super('for loop');
  run() {
    int count = 0;
    for(int i = 0; i < list.length; i++) {
      count += list[i];
    }
    return count;
  }
}

void main() {
  new ForEach().report();
  new ForIn().report();
  new ForLoop().report();
}
