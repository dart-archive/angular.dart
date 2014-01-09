library lexer_perf;

import '_perf.dart';
import 'package:angular/core/parser/lexer.dart';

main() {
  Lexer lexer = new Lexer();
  time('ident', () =>
      lexer.call('ctrl foo baz ctrl.foo ctrl.bar ctrl.baz'));
  time('ident-path', () =>
      lexer.call('a.b a.b.c a.b.c.d a.b.c.d.e.f'));
  time('num', () =>
      lexer.call('1 23 34 456 12341234 12351235'));
  time('num-double', () =>
      lexer.call('.0 .1 .12 0.123 0.1234'));
  time('string', () =>
      lexer.call("'quick brown dog and fox say what'"));
  time('string-escapes', () =>
      lexer.call("quick '\\' brown \u1234 dog and fox\n\rsay what'"));
}
