library angular.perf.watch_group;

import '_perf.dart';
import 'dart:mirrors';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/change_detection/watch_group.dart';

var reactionFn = (_, __, ___) => null;
main() {
  // collectionIteration();
  fieldRead();
  mapRead();
  methodInvoke0();
  methodInvoke1();
  function2();
}

collectionIteration() {
  List<int> list = [];
  for(int i = 0, ii = 1000; i < ii; i++) {
    list.add(i);
  }
  time('collection.forEach',() {
    fn(int i) => i;
    list.forEach(fn);
  });
  time('for item in collection', () {
    fn(int i) => i;
    for(var item in list) {
      fn(item);
    }
  });
  time('for i; i<ii; i++', () {
    fn(int i) => i;
    for(var i = 0, ii = list.length; i < ii; i++) {
      fn(list[i]);
    }
  });
}

fieldRead() {
  var watchGrp = new RootWatchGroup(new DirtyCheckingChangeDetector<_Handler>(), new Obj());
  watchGrp.watch(parse('a'), reactionFn);
  watchGrp.watch(parse('b'), reactionFn);
  watchGrp.watch(parse('c'), reactionFn);
  watchGrp.watch(parse('d'), reactionFn);
  watchGrp.watch(parse('e'), reactionFn);

  watchGrp.watch(parse('f'), reactionFn);
  watchGrp.watch(parse('g'), reactionFn);
  watchGrp.watch(parse('h'), reactionFn);
  watchGrp.watch(parse('i'), reactionFn);
  watchGrp.watch(parse('j'), reactionFn);

  watchGrp.watch(parse('k'), reactionFn);
  watchGrp.watch(parse('l'), reactionFn);
  watchGrp.watch(parse('m'), reactionFn);
  watchGrp.watch(parse('n'), reactionFn);
  watchGrp.watch(parse('o'), reactionFn);

  watchGrp.watch(parse('p'), reactionFn);
  watchGrp.watch(parse('q'), reactionFn);
  watchGrp.watch(parse('r'), reactionFn);
  watchGrp.watch(parse('s'), reactionFn);
  watchGrp.watch(parse('t'), reactionFn);
  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');

  time('fieldRead', () => watchGrp.detectChanges());
}

mapRead() {
  var map = {
      'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4,
      'f': 0, 'g': 1, 'h': 2, 'i': 3, 'j': 4,
      'k': 0, 'l': 1, 'm': 2, 'n': 3, 'o': 4,
      'p': 0, 'q': 1, 'r': 2, 's': 3, 't': 4};
  var watchGrp = new RootWatchGroup(new DirtyCheckingChangeDetector<_Handler>(), map);
  watchGrp.watch(parse('a'), reactionFn);
  watchGrp.watch(parse('b'), reactionFn);
  watchGrp.watch(parse('c'), reactionFn);
  watchGrp.watch(parse('d'), reactionFn);
  watchGrp.watch(parse('e'), reactionFn);

  watchGrp.watch(parse('f'), reactionFn);
  watchGrp.watch(parse('g'), reactionFn);
  watchGrp.watch(parse('h'), reactionFn);
  watchGrp.watch(parse('i'), reactionFn);
  watchGrp.watch(parse('j'), reactionFn);

  watchGrp.watch(parse('k'), reactionFn);
  watchGrp.watch(parse('l'), reactionFn);
  watchGrp.watch(parse('m'), reactionFn);
  watchGrp.watch(parse('n'), reactionFn);
  watchGrp.watch(parse('o'), reactionFn);

  watchGrp.watch(parse('p'), reactionFn);
  watchGrp.watch(parse('q'), reactionFn);
  watchGrp.watch(parse('r'), reactionFn);
  watchGrp.watch(parse('s'), reactionFn);
  watchGrp.watch(parse('t'), reactionFn);
  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('mapRead', () => watchGrp.detectChanges());
}

methodInvoke0() {
  var context = new Obj();
  context.a = new Obj();
  var watchGrp = new RootWatchGroup(new DirtyCheckingChangeDetector<_Handler>(), context);
  watchGrp.watch(method('a', 'methodA'), reactionFn);
  watchGrp.watch(method('a', 'methodB'), reactionFn);
  watchGrp.watch(method('a', 'methodC'), reactionFn);
  watchGrp.watch(method('a', 'methodD'), reactionFn);
  watchGrp.watch(method('a', 'methodE'), reactionFn);
  watchGrp.watch(method('a', 'methodF'), reactionFn);
  watchGrp.watch(method('a', 'methodG'), reactionFn);
  watchGrp.watch(method('a', 'methodH'), reactionFn);
  watchGrp.watch(method('a', 'methodI'), reactionFn);
  watchGrp.watch(method('a', 'methodJ'), reactionFn);
  watchGrp.watch(method('a', 'methodK'), reactionFn);
  watchGrp.watch(method('a', 'methodL'), reactionFn);
  watchGrp.watch(method('a', 'methodM'), reactionFn);
  watchGrp.watch(method('a', 'methodN'), reactionFn);
  watchGrp.watch(method('a', 'methodO'), reactionFn);
  watchGrp.watch(method('a', 'methodP'), reactionFn);
  watchGrp.watch(method('a', 'methodQ'), reactionFn);
  watchGrp.watch(method('a', 'methodR'), reactionFn);
  watchGrp.watch(method('a', 'methodS'), reactionFn);
  watchGrp.watch(method('a', 'methodT'), reactionFn);
  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?()', () => watchGrp.detectChanges());
}

methodInvoke1() {
  var context = new Obj();
  context.a = new Obj();
  var watchGrp = new RootWatchGroup(new DirtyCheckingChangeDetector<_Handler>(), context);
  watchGrp.watch(method('a', 'methodA', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodB', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodC', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodD', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodE', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodF', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodG', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodH', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodI', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodJ', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodK', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodL', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodM', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodN', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodO', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodP', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodQ', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodR', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodS', [parse('a')]), reactionFn);
  watchGrp.watch(method('a', 'methodT', [parse('a')]), reactionFn);
  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?(obj)', () => watchGrp.detectChanges());
}

function2() {
  var context = new Obj();
  var watchGrp = new RootWatchGroup(new DirtyCheckingChangeDetector<_Handler>(), context);
  watchGrp.watch(add(0, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(1, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(2, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(3, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(4, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(5, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(6, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(7, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(8, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(9, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(10, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(11, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(12, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(13, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(14, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(15, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(16, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(17, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(18, parse('a'), parse('a')), reactionFn);
  watchGrp.watch(add(19, parse('a'), parse('a')), reactionFn);
  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('add?(a, a)', () => watchGrp.detectChanges());
}

AST add(id, lhs, rhs) {
  return new PureFunctionAST('add$id', (a, b) => a + b, [lhs, rhs]);
}

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
