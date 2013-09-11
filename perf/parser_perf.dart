import "../test/_specs.dart";
import "_perf.dart";
import '../test/parser/generated_functions.dart' as generated_functions;
import '../test/parser/generated_getter_setter.dart' as generated_getter_setter;
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
  var reflectivParser, generatedParser, hybridParser;

  beforeEach(module((Module module) {
    module.type(StaticParser);
    module.value(StaticParserFunctions, generated_functions.functions());
  }));

  beforeEach(inject((Scope _scope, DynamicParser _dynamic, StaticParser _parser){
    scope = _scope;
    new SpecInjector()
      ..module((AngularModule module) {
          module.type(DynamicParser);
          module.type(GetterSetter, implementedBy: generated_getter_setter.StaticGetterSetter);
      })
      ..inject((DynamicParser p) => hybridParser = p);
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
      var hybridExpr = hybridParser(expr);
      var measure = (b) => statMeasure(b).mean_ops_sec;
      var gTime = measure(() => generatedExpr.eval(scope));
      var rTime = measure(() => reflectionExpr.eval(scope));
      var hTime = measure(() => hybridExpr.eval(scope));
      var iTime = measure(() => idealFn(scope));
      dump('$expr => g: ${nf.format(gTime)} ops/sec   ' +
                    'r: ${nf.format(rTime)} ops/sec   ' +
                    'h: ${nf.format(hTime)} ops/sec   ' +
                    'i: ${nf.format(iTime)} ops/sec = ' +
                    'i/g: ${nf.format(iTime / gTime)} x  ' +
                    'i/r: ${nf.format(iTime / rTime)} x  ' +
                    'i/h: ${nf.format(iTime / hTime)} x  ' +
                    'g/h: ${nf.format(gTime / hTime)} x  ' +
                    'h/r: ${nf.format(hTime / rTime)} x  ' +
                    'g/r: ${nf.format(gTime / rTime)} x');
    });
  }

  compare('a.b.c', (scope) => scope['a'].b.c);
  compare('e1.b', (scope) => scope['e1'].b);
  compare('null', (scope) => null);
  compare('x.b.c', (s, [l]) {
    if (l != null && l.containsKey('x')) s = l['x'];
    else if (s != null ) s = s is Map ? s['x'] : s.x;
    if (s != null ) s = s is Map ? s['b'] : s.b;
    if (s != null ) s = s is Map ? s['c'] : s.c;
    return s;
  });
  compare('doesNotExist', (scope) => scope['doesNotExists']);
});
