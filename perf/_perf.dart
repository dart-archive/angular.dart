import '../test/_specs.dart';
import 'package:intl/intl.dart';

time(name, body) => _time(it, name, body);
ttime(name, body) => _time(iit, name, body);
_time(fn, name, body) {
  fn(name, () {
    var nf = new NumberFormat.decimalPattern();
    nf.maximumFractionDigits = 0;
    var rate = measure(body);
    dump('$name: ${nf.format(rate)} ops/sec (${nf.format(1000000 / rate)} us.)');
  });
}

measure(body) {
  var count = 0;
  var stopwatch = new Stopwatch();
  stopwatch.start();
  do {
    // 1
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    // 2
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    // 3
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    // 4
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    // 5
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    // 6
    body(); // 1
    body(); // 2
    body(); // 3
    body(); // 4
    body(); // 5
    body(); // 6
    body(); // 7
    body(); // 8
    body(); // 9
    body(); // 10

    count += 50;
  } while(stopwatch.elapsedMicroseconds < 1000000);
  stopwatch.stop();
  var rate = count / stopwatch.elapsedMicroseconds;
  return rate * 1000000;
}

main() {}
