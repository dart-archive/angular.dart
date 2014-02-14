library parser_perf;

import '_perf.dart';
import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/filter/module.dart';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:intl/intl.dart';

import '../gen/generated_functions.dart' as generated_functions;
import '../gen/generated_getter_setter.dart' as generated_getter_setter;

main() {
  var module = new Module()
    ..type(Parser, implementedBy: DynamicParser)
    ..type(ParserBackend, implementedBy: DynamicParserBackend)
    ..type(SubstringFilter)
    ..type(IncrementFilter)
    ..install(new NgFilterModule());
  var injector = new DynamicInjector(
      modules: [module],
      allowImplicitInjection:true);
  var scope = injector.get(Scope);
  var reflectiveParser = injector.get(Parser);
  var filterMap = injector.get(FilterMap);

  var generatedParser = new DynamicInjector(
      modules: [new Module()
        ..type(Parser, implementedBy: StaticParser)
        ..type(ParserBackend, implementedBy: DynamicParserBackend)
        ..value(StaticParserFunctions, generated_functions.functions())],
      allowImplicitInjection:true).get(Parser);

  var hybridParser = new DynamicInjector(
      modules: [new Module()
        ..type(Parser, implementedBy: DynamicParser)
        ..type(ParserBackend, implementedBy: DynamicParserBackend)
        ..type(ClosureMap, implementedBy: generated_getter_setter.StaticClosureMap)],
      allowImplicitInjection:true).get(Parser);

  scope['a'] = new ATest();
  scope['e1'] = new EqualsThrows();
  scope['o'] = new OTest();

  compare(expr, idealFn) {
    var nf = new NumberFormat.decimalPattern();
    Expression reflectionExpr = reflectiveParser(expr);
    Expression generatedExpr = generatedParser(expr);
    Expression hybridExpr = hybridParser(expr);
    var measure = (b) => statMeasure(b).mean_ops_sec;
    var gTime = measure(() => generatedExpr.eval(scope));
    var rTime = measure(() => reflectionExpr.eval(scope));
    var hTime = measure(() => hybridExpr.eval(scope));
    var iTime = measure(() => idealFn(scope));
    print('$expr => g: ${nf.format(gTime)} ops/sec   ' +
          'r: ${nf.format(rTime)} ops/sec   ' +
          'h: ${nf.format(hTime)} ops/sec   ' +
          'i: ${nf.format(iTime)} ops/sec = ' +
          'i/g: ${nf.format(iTime / gTime)} x  ' +
          'i/r: ${nf.format(iTime / rTime)} x  ' +
          'i/h: ${nf.format(iTime / hTime)} x  ' +
          'g/h: ${nf.format(gTime / hTime)} x  ' +
          'h/r: ${nf.format(hTime / rTime)} x  ' +
          'g/r: ${nf.format(gTime / rTime)} x');
  }

  compare('a.b.c', (scope) => scope['a'].b.c);
  compare('e1.b', (scope) => scope['e1'].b);
  compare('o.f()', (scope) => scope['o'].f());
  compare('null', (scope) => null);
  compare('x.b.c', (s, [l]) {
    if (l != null && l.containsKey('x')) s = l['x'];
    else if (s != null ) s = s is Map ? s['x'] : s.x;
    if (s != null ) s = s is Map ? s['b'] : s.b;
    if (s != null ) s = s is Map ? s['c'] : s.c;
    return s;
  });
  compare('doesNotExist', (scope) => scope['doesNotExists']);
}


class ATest {
  var b = new BTest();
}

class BTest {
  var c = 6;
}

class OTest {
  f() => 42;
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

@NgFilter(name:'increment')
class IncrementFilter {
  call(a, b) => a + b;
}

@NgFilter(name:'substring')
class SubstringFilter {
  call(String str, startIndex, [endIndex]) {
    return str.substring(startIndex, endIndex);
  }
}

