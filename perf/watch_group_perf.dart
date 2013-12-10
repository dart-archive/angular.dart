library angular.perf.watch_group;

import '_perf.dart';
import 'dart:mirrors';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

var reactionFn = (_, __, ___) => null;
var getterCache = new GetterCache({});
main() {
  fieldRead();
  fieldReadGetter();
  mapRead();
  methodInvoke0();
  methodInvoke1();
  function2();
  new CollectionCheck().report();
}

class CollectionCheck extends BenchmarkBase {
  List<int> list = new List.generate(1000, (i) => i);
  var detector = new DirtyCheckingChangeDetector<_Handler>(getterCache);

  CollectionCheck(): super('change-detect List[1000]') {
    detector
        ..watch(list, null, 'handler')
        ..collectChanges(); // intialize
  }

  run() {
    detector.collectChanges();
  }
}

fieldRead() {
  var watchGrp = new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), new Obj())
      ..watch(parse('a'), reactionFn)
      ..watch(parse('b'), reactionFn)
      ..watch(parse('c'), reactionFn)
      ..watch(parse('d'), reactionFn)
      ..watch(parse('e'), reactionFn)
      ..watch(parse('f'), reactionFn)
      ..watch(parse('g'), reactionFn)
      ..watch(parse('h'), reactionFn)
      ..watch(parse('i'), reactionFn)
      ..watch(parse('j'), reactionFn)
      ..watch(parse('k'), reactionFn)
      ..watch(parse('l'), reactionFn)
      ..watch(parse('m'), reactionFn)
      ..watch(parse('n'), reactionFn)
      ..watch(parse('o'), reactionFn)
      ..watch(parse('p'), reactionFn)
      ..watch(parse('q'), reactionFn)
      ..watch(parse('r'), reactionFn)
      ..watch(parse('s'), reactionFn)
      ..watch(parse('t'), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');

  time('fieldRead', () => watchGrp.detectChanges());
}

fieldReadGetter() {
  var getterCache = new GetterCache({
    "a": (o) => o.a, "b": (o) => o.b, "c": (o) => o.c, "d": (o) => o.d, "e": (o) => o.e,
    "f": (o) => o.f, "g": (o) => o.g, "h": (o) => o.h, "i": (o) => o.i, "j": (o) => o.j,
    "k": (o) => o.k, "l": (o) => o.l, "m": (o) => o.m, "n": (o) => o.n, "o": (o) => o.o,
    "p": (o) => o.p, "q": (o) => o.q, "r": (o) => o.r, "n": (o) => o.s, "t": (o) => o.t,
  });
  var  watchGrp= new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), new Obj())
      ..watch(parse('a'), reactionFn)
      ..watch(parse('b'), reactionFn)
      ..watch(parse('c'), reactionFn)
      ..watch(parse('d'), reactionFn)
      ..watch(parse('e'), reactionFn)
      ..watch(parse('f'), reactionFn)
      ..watch(parse('g'), reactionFn)
      ..watch(parse('h'), reactionFn)
      ..watch(parse('i'), reactionFn)
      ..watch(parse('j'), reactionFn)
      ..watch(parse('k'), reactionFn)
      ..watch(parse('l'), reactionFn)
      ..watch(parse('m'), reactionFn)
      ..watch(parse('n'), reactionFn)
      ..watch(parse('o'), reactionFn)
      ..watch(parse('p'), reactionFn)
      ..watch(parse('q'), reactionFn)
      ..watch(parse('r'), reactionFn)
      ..watch(parse('s'), reactionFn)
      ..watch(parse('t'), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');

  time('fieldReadGetter', () => watchGrp.detectChanges());
}

mapRead() {
  var map = {
      'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4,
      'f': 0, 'g': 1, 'h': 2, 'i': 3, 'j': 4,
      'k': 0, 'l': 1, 'm': 2, 'n': 3, 'o': 4,
      'p': 0, 'q': 1, 'r': 2, 's': 3, 't': 4};
  var watchGrp = new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), map)
      ..watch(parse('a'), reactionFn)
      ..watch(parse('b'), reactionFn)
      ..watch(parse('c'), reactionFn)
      ..watch(parse('d'), reactionFn)
      ..watch(parse('e'), reactionFn)
      ..watch(parse('f'), reactionFn)
      ..watch(parse('g'), reactionFn)
      ..watch(parse('h'), reactionFn)
      ..watch(parse('i'), reactionFn)
      ..watch(parse('j'), reactionFn)
      ..watch(parse('k'), reactionFn)
      ..watch(parse('l'), reactionFn)
      ..watch(parse('m'), reactionFn)
      ..watch(parse('n'), reactionFn)
      ..watch(parse('o'), reactionFn)
      ..watch(parse('p'), reactionFn)
      ..watch(parse('q'), reactionFn)
      ..watch(parse('r'), reactionFn)
      ..watch(parse('s'), reactionFn)
      ..watch(parse('t'), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('mapRead', () => watchGrp.detectChanges());
}

methodInvoke0() {
  var context = new Obj();
  context.a = new Obj();
  var watchGrp = new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), context)
      ..watch(method('a', 'methodA'), reactionFn)
      ..watch(method('a', 'methodB'), reactionFn)
      ..watch(method('a', 'methodC'), reactionFn)
      ..watch(method('a', 'methodD'), reactionFn)
      ..watch(method('a', 'methodE'), reactionFn)
      ..watch(method('a', 'methodF'), reactionFn)
      ..watch(method('a', 'methodG'), reactionFn)
      ..watch(method('a', 'methodH'), reactionFn)
      ..watch(method('a', 'methodI'), reactionFn)
      ..watch(method('a', 'methodJ'), reactionFn)
      ..watch(method('a', 'methodK'), reactionFn)
      ..watch(method('a', 'methodL'), reactionFn)
      ..watch(method('a', 'methodM'), reactionFn)
      ..watch(method('a', 'methodN'), reactionFn)
      ..watch(method('a', 'methodO'), reactionFn)
      ..watch(method('a', 'methodP'), reactionFn)
      ..watch(method('a', 'methodQ'), reactionFn)
      ..watch(method('a', 'methodR'), reactionFn)
      ..watch(method('a', 'methodS'), reactionFn)
      ..watch(method('a', 'methodT'), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?()', () => watchGrp.detectChanges());
}

methodInvoke1() {
  var context = new Obj();
  context.a = new Obj();
  var watchGrp = new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), context)
      ..watch(method('a', 'methodA', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodB', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodC', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodD', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodE', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodF', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodG', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodH', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodI', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodJ', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodK', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodL', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodM', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodN', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodO', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodP', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodQ', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodR', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodS', [parse('a')]), reactionFn)
      ..watch(method('a', 'methodT', [parse('a')]), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?(obj)', () => watchGrp.detectChanges());
}

function2() {
  var context = new Obj();
  var watchGrp = new RootWatchGroup(
      new DirtyCheckingChangeDetector<_Handler>(getterCache), context)
      ..watch(add(0, parse('a'), parse('a')), reactionFn)
      ..watch(add(1, parse('a'), parse('a')), reactionFn)
      ..watch(add(2, parse('a'), parse('a')), reactionFn)
      ..watch(add(3, parse('a'), parse('a')), reactionFn)
      ..watch(add(4, parse('a'), parse('a')), reactionFn)
      ..watch(add(5, parse('a'), parse('a')), reactionFn)
      ..watch(add(6, parse('a'), parse('a')), reactionFn)
      ..watch(add(7, parse('a'), parse('a')), reactionFn)
      ..watch(add(8, parse('a'), parse('a')), reactionFn)
      ..watch(add(9, parse('a'), parse('a')), reactionFn)
      ..watch(add(10, parse('a'), parse('a')), reactionFn)
      ..watch(add(11, parse('a'), parse('a')), reactionFn)
      ..watch(add(12, parse('a'), parse('a')), reactionFn)
      ..watch(add(13, parse('a'), parse('a')), reactionFn)
      ..watch(add(14, parse('a'), parse('a')), reactionFn)
      ..watch(add(15, parse('a'), parse('a')), reactionFn)
      ..watch(add(16, parse('a'), parse('a')), reactionFn)
      ..watch(add(17, parse('a'), parse('a')), reactionFn)
      ..watch(add(18, parse('a'), parse('a')), reactionFn)
      ..watch(add(19, parse('a'), parse('a')), reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('add?(a, a)', () => watchGrp.detectChanges());
}

AST add(id, lhs, rhs) =>
    new PureFunctionAST('add$id', (a, b) => a + b, [lhs, rhs]);

AST method(lhs, methodName, [args]) {
  if (args == null) args = [];
  return new MethodAST(parse(lhs), methodName, args);
}

AST parse(String expression) {
  var currentAST = new ContextReferenceAST();
  expression.split('.').forEach((name) {
    currentAST = new FieldReadAST(currentAST, name);
  });
  return currentAST;
}


class Obj {
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
