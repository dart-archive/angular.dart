library _perf;

import 'package:intl/intl.dart';
import 'dart:math';

xtime(name, body) => null;
time(name, body) {
  print('$name: => ${statMeasure(body)}');
}

statMeasure(body) {
  var list = [];
  var count = 100;
  for(var i = 0; i < count; i++) {
    list.add(measure(body));
  }
  list.sort((a, b) => (a.rate - b.rate).toInt());
  return new StatSample(list);
}

measure(b) {
  // actual test;
  var count = 0;
  var stopwatch = new Stopwatch();
  var targetTime = 50 * 1000;
  stopwatch.start();
  do {
    b();
    count++;
  } while(stopwatch.elapsedMicroseconds < targetTime);

  stopwatch.reset();
  if (count < 100) {
    for(var i = 0; i < count; i++) {
      b();
    }
  } else {
    var repeat = count ~/ 100;
    for(var i = 0; i < repeat; i++) {
      //0  1    2    3    4    5    6    7    8    9
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 0
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 1
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 2
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 3
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 4
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 5
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 6
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 7
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 8
      b(); b(); b(); b(); b(); b(); b(); b(); b(); b(); // 9
    }
  }
  stopwatch.stop();
  int elapsed = max(1, stopwatch.elapsedMicroseconds);
  return new Sample(count, elapsed);
}

main() {}

class StatSample {
  num meanAll = 0;
  num varianceAll = 0;
  num mean = 0;
  num variance = 0;

  StatSample(l) {
    meanAll = l.fold(0, meanFoldFn) / l.length;
    varianceAll = computeVariance(l);

    var n = l.length;
    var lower = (n*.5).toInt();
    var upper = n - (n*.05).toInt();
    l = l.getRange(lower, upper).toList();
    mean = l.fold(0, meanFoldFn) / l.length;
    variance = computeVariance(l);
  }

  meanFoldFn(p, e) => p + e.rate;
  sumSqrsFn(p, e) => p + (mean-e.rate)*(mean-e.rate);
  sumDiffFn(p, e) => p + (mean-e.rate);
  get mean_ops_sec => mean * 1000000;
  computeVariance(l) {
    var n = l.length;
    var sumDiffs = l.fold(0, sumDiffFn);
    var sumSqrs = l.fold(0, sumSqrsFn);

    return (sumSqrs - sumDiffs*sumDiffs/n)/(n - 1);
  }

  toString() {
    var nf = new NumberFormat.decimalPattern()..maximumFractionDigits = 0;
    var nfp = new NumberFormat.decimalPattern()..maximumFractionDigits = 5;

    return '${nf.format(mean_ops_sec)} ops/sec ' +
        '(${nf.format(1 / mean)} us) ' +
        'stdev(${nfp.format(sqrt(variance))})';
  }
}

class Sample {
  num count;
  num time_us;

  Sample(this.count, this.time_us);

  get rate => count / time_us;

  toString() => rate;
}
