import "../test/_specs.dart";
import "_perf.dart";
import '../test/parser/generated_functions.dart' as generated_functions;
import 'package:intl/intl.dart';

class ATest {
  var b = new BTest();
}

class BTest {
  var c = 6;
}

class EqualsThrows {
  var b = 3;
  operator ==(x) {
    try {
      throw "no";
    } catch (e) {
      return false;
    }
  }
}

main() => describe('parser', () {
  var scope;
  var reflectivParser, generatedParser;

  beforeEach(module((Module module) {
    module.type(StaticParser);
    module.value(StaticParserFunctions, generated_functions.functions());
  }));

  beforeEach(inject((Scope _scope, DynamicParser _dynamic, StaticParser _parser){
    scope = _scope;
    reflectivParser = _dynamic;
    generatedParser = _parser;
    scope['a'] = new ATest();
    scope['e1'] = new EqualsThrows();
  }));

  compare(expr, idealFn) {
    iit(expr, () {
      var nf = new NumberFormat.decimalPattern();
      var reflectionExpr = reflectivParser(expr);
      var generatedExpr = generatedParser(expr);
      var gTime = measure(() => generatedExpr.eval(scope));
      var rTime = measure(() => reflectionExpr.eval(scope));
      var iTime = measure(() => idealFn(scope));
      dump('$expr => g: ${nf.format(gTime)} ops/sec   ' +
                    'r: ${nf.format(rTime)} ops/sec   ' +
                    'i: ${nf.format(iTime)} ops/sec = ' +
                    'i/g: ${nf.format(iTime / gTime)} x  ' +
                    'i/r: ${nf.format(iTime / rTime)} x  ' +
                    'g/r: ${nf.format(gTime / rTime)} x');
    });
  }

  compare('x.b.c', (s, [l]) {
    if (l != null && l.containsKey('x')) s = l['x'];
    else if (s != null ) s = s is Map ? s['x'] : s.x;
    if (s != null ) s = s is Map ? s['b'] : s.b;
    if (s != null ) s = s is Map ? s['c'] : s.c;
    return s;
  });
  compare('a.b.c', (scope) => scope['a'].b.c);
  compare('e1.b', (scope) => scope['e1'].b);
  compare('null', (scope) => null);
  compare('doesNotExist', (scope) => scope['doesNotExists']);
});
