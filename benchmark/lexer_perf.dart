library lexer_perf;

import '_perf.dart';
import '_reporter.dart';
import 'package:angular/core/parser/lexer.dart';


Reporter reporter = new Reporter();
var lexerStats = reporter.data.newChild("lexer", "lexer benchmarks");


report(name, fn) {
  var stats = lexerStats.newChild(name, "");
  var metrics = statMeasure(fn);
  stats.metrics["ops_per_sec"] = metrics.mean_ops_sec;
  stats.metrics["variance"] = metrics.variance;
  print('$name: => $metrics');
  reporter.saveReport();
}


main() {
  Lexer lexer = new Lexer();

  report('ident', () =>
      lexer.call('ctrl foo baz ctrl.foo ctrl.bar ctrl.baz'));
  report('ident-path', () =>
      lexer.call('a.b a.b.c a.b.c.d a.b.c.d.e.f'));
  report('num', () =>
      lexer.call('1 23 34 456 12341234 12351235'));
  report('num-double', () =>
      lexer.call('.0 .1 .12 0.123 0.1234'));
  report('string', () =>
      lexer.call("'quick brown dog and fox say what'"));
  report('string-escapes', () =>
      lexer.call("quick '\\' brown \u1234 dog and fox\n\rsay what'"));

  reporter.saveReport();
}
