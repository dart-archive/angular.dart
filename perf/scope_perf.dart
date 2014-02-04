library scope_perf;

import '_perf.dart';
import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

createInjector() {
  return new DynamicInjector(
      modules: [new Module()
        ..type(Parser, implementedBy: DynamicParser)
        ..type(ParserBackend, implementedBy: DynamicParserBackend)],
      allowImplicitInjection:true);
}

var reactionFn = (_, __, ___) => null;
main() {
  _fieldRead();
  _mapRead();
  _methodInvoke0();
  _methodInvoke1();
  _function2();
}

_fieldRead() {
  var injector = createInjector();
  var obj = new _Obj();
  var scope = injector.get(Scope);
  var parser = injector.get(Parser);
  var parse = (exp) {
    var fn = parser(exp).eval;
    var o = obj;
    return (s) => fn(o);
  };
  scope.watch(parse('a'), reactionFn);
  scope.watch(parse('b'), reactionFn);
  scope.watch(parse('c'), reactionFn);
  scope.watch(parse('d'), reactionFn);
  scope.watch(parse('e'), reactionFn);
  scope.watch(parse('f'), reactionFn);
  scope.watch(parse('g'), reactionFn);
  scope.watch(parse('h'), reactionFn);
  scope.watch(parse('i'), reactionFn);
  scope.watch(parse('j'), reactionFn);
  scope.watch(parse('k'), reactionFn);
  scope.watch(parse('l'), reactionFn);
  scope.watch(parse('m'), reactionFn);
  scope.watch(parse('n'), reactionFn);
  scope.watch(parse('o'), reactionFn);
  scope.watch(parse('p'), reactionFn);
  scope.watch(parse('q'), reactionFn);
  scope.watch(parse('r'), reactionFn);
  scope.watch(parse('s'), reactionFn);
  scope.watch(parse('t'), reactionFn);
  scope.apply();
  time('fieldRead', () => scope.apply());
}

_mapRead() {
  var map = {
      'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4,
      'f': 0, 'g': 1, 'h': 2, 'i': 3, 'j': 4,
      'k': 0, 'l': 1, 'm': 2, 'n': 3, 'o': 4,
      'p': 0, 'q': 1, 'r': 2, 's': 3, 't': 4};
  var injector = createInjector();
  var obj = new _Obj();
  var scope = injector.get(Scope);
  map.forEach((k, v) => scope[k] = v);

  scope.watch('a', reactionFn);
  scope.watch('b', reactionFn);
  scope.watch('c', reactionFn);
  scope.watch('d', reactionFn);
  scope.watch('e', reactionFn);
  scope.watch('f', reactionFn);
  scope.watch('g', reactionFn);
  scope.watch('h', reactionFn);
  scope.watch('i', reactionFn);
  scope.watch('j', reactionFn);
  scope.watch('k', reactionFn);
  scope.watch('l', reactionFn);
  scope.watch('m', reactionFn);
  scope.watch('n', reactionFn);
  scope.watch('o', reactionFn);
  scope.watch('p', reactionFn);
  scope.watch('q', reactionFn);
  scope.watch('r', reactionFn);
  scope.watch('s', reactionFn);
  scope.watch('t', reactionFn);
  scope.apply();
  time('mapRead', () => scope.apply());
}

_methodInvoke0() {
  var context = new _Obj();
  var injector = createInjector();
  var obj = new _Obj();
  var scope = injector.get(Scope);
  scope.a = context;
  scope.watch('a.methodA()', reactionFn);
  scope.watch('a.methodB()', reactionFn);
  scope.watch('a.methodC()', reactionFn);
  scope.watch('a.methodD()', reactionFn);
  scope.watch('a.methodE()', reactionFn);
  scope.watch('a.methodF()', reactionFn);
  scope.watch('a.methodG()', reactionFn);
  scope.watch('a.methodH()', reactionFn);
  scope.watch('a.methodI()', reactionFn);
  scope.watch('a.methodJ()', reactionFn);
  scope.watch('a.methodK()', reactionFn);
  scope.watch('a.methodL()', reactionFn);
  scope.watch('a.methodM()', reactionFn);
  scope.watch('a.methodN()', reactionFn);
  scope.watch('a.methodO()', reactionFn);
  scope.watch('a.methodP()', reactionFn);
  scope.watch('a.methodQ()', reactionFn);
  scope.watch('a.methodR()', reactionFn);
  scope.watch('a.methodS()', reactionFn);
  scope.watch('a.methodT()', reactionFn);
  scope.apply();
  time('obj.method?()', () => scope.apply());
}

_methodInvoke1() {
  var context = new _Obj();
  var injector = createInjector();
  var obj = new _Obj();
  var scope = injector.get(Scope);
  scope.a = context;
  scope.watch('a.methodA(a)', reactionFn);
  scope.watch('a.methodB(a)', reactionFn);
  scope.watch('a.methodC(a)', reactionFn);
  scope.watch('a.methodD(a)', reactionFn);
  scope.watch('a.methodE(a)', reactionFn);
  scope.watch('a.methodF(a)', reactionFn);
  scope.watch('a.methodG(a)', reactionFn);
  scope.watch('a.methodH(a)', reactionFn);
  scope.watch('a.methodI(a)', reactionFn);
  scope.watch('a.methodJ(a)', reactionFn);
  scope.watch('a.methodK(a)', reactionFn);
  scope.watch('a.methodL(a)', reactionFn);
  scope.watch('a.methodM(a)', reactionFn);
  scope.watch('a.methodN(a)', reactionFn);
  scope.watch('a.methodO(a)', reactionFn);
  scope.watch('a.methodP(a)', reactionFn);
  scope.watch('a.methodQ(a)', reactionFn);
  scope.watch('a.methodR(a)', reactionFn);
  scope.watch('a.methodS(a)', reactionFn);
  scope.watch('a.methodT(a)', reactionFn);
  scope.apply();
  time('obj.method?(obj)', () => scope.apply());
}

_function2() {
  var injector = createInjector();
  var obj = new _Obj();
  obj.a = 1;
  var scope = injector.get(Scope);
  var parser = injector.get(Parser);
  var aFn = parser('a').eval;
  var add = () {
    var fn = aFn;
    var o = obj;
    return (s) => fn(o) + fn(o);
  };
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.watch(add(), reactionFn);
  scope.apply();
  time('add?(a, a)', () => scope.apply());
}

class _Obj {
  var a = 1;
  var b = 2;
  var c = 3;
  var d = 4;
  var e = 5;

  var f = 6;
  var g = 7;
  var h = 8;
  var i = 9;
  var j = 10;

  var k = 11;
  var l = 12;
  var m = 13;
  var n = 14;
  var o = 15;

  var p = 16;
  var q = 17;
  var r = 18;
  var s = 19;
  var t = 20;

  methodA([arg0]) => a;
  methodB([arg0]) => b;
  methodC([arg0]) => c;
  methodD([arg0]) => d;
  methodE([arg0]) => e;
  methodF([arg0]) => f;
  methodG([arg0]) => g;
  methodH([arg0]) => h;
  methodI([arg0]) => i;
  methodJ([arg0]) => j;
  methodK([arg0]) => k;
  methodL([arg0]) => l;
  methodM([arg0]) => m;
  methodN([arg0]) => n;
  methodO([arg0]) => o;
  methodP([arg0]) => p;
  methodQ([arg0]) => q;
  methodR([arg0]) => r;
  methodS([arg0]) => s;
  methodT([arg0]) => t;
}
