library loop_perf;

import 'package:benchmark_harness/benchmark_harness.dart';

class IterationBenchmark extends BenchmarkBase {
  List<int> list = new List.generate(1000, (i) => i);
  Map map;
  var r = 0;
  IterationBenchmark(name) : super(name) {
    map = new Map.fromIterable(list, key: (i) => i, value: (i) => i);
  }
}

class ForEach extends IterationBenchmark {
  ForEach() : super('forEach');
  run() {
    var count = 0;
    list.forEach((int i) => count = count + i);
    return count;
  }
}

class ForEachMap extends IterationBenchmark {
  ForEachMap() : super('forEachMap');
  run() {
    var count = 0;
    map.forEach((int k, int v) => count = count + k + v);
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

class ForInMap extends IterationBenchmark {
  ForInMap() : super('for in Map');
  run() {
    var count = 0;
    for(int key in map.keys) {
      count = count + key + map[key];
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
  new ForEachMap().report();
  new ForInMap().report();
}
