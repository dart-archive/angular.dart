library angular.benchmarks.watch_group;

import '_perf.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_dynamic.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_static.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:observe/observe.dart';
import 'package:observe/mirrors_used.dart';
import "dart:io";
import "dart:async";
import "dart:convert";

@MirrorsUsed(
    targets: const [
      'angular.benchmarks.watch_group'
    ],
    override: '*'
)
import 'dart:mirrors' show MirrorsUsed;

var _reactionFn = (_, __) => null;
var _staticFieldGetterFactory = new StaticFieldGetterFactory({
    "a": (o) => o.a, "b": (o) => o.b, "c": (o) => o.c, "d": (o) => o.d, "e": (o) => o.e,
    "f": (o) => o.f, "g": (o) => o.g, "h": (o) => o.h, "i": (o) => o.i, "j": (o) => o.j,
    "k": (o) => o.k, "l": (o) => o.l, "m": (o) => o.m, "n": (o) => o.n, "o": (o) => o.o,
    "p": (o) => o.p, "q": (o) => o.q, "r": (o) => o.r, "s": (o) => o.s, "t": (o) => o.t,
});
var _dynamicFieldGetterFactory = new DynamicFieldGetterFactory();

main() {
  _collectionRead(observable:false, changeCount:0);
  _collectionRead(observable:true, changeCount:0);

  _collectionRead(observable:false, changeCount:1);
  _collectionRead(observable:true, changeCount:1);

  _collectionRead(observable:false, changeCount:10);
  _collectionRead(observable:true, changeCount:10);

  _groupAddRemove(observable:false);
  _groupAddRemove(observable:true);

  _fieldRead(observable:false, staticGetter: false, changeCount: 0);
  _fieldRead(observable:true, staticGetter: false, changeCount: 0);

  _fieldRead(observable:false, staticGetter: false, changeCount: 1);
  _fieldRead(observable:true, staticGetter: false, changeCount: 1);

  _fieldRead(observable:false, staticGetter: false, changeCount: 10);
  _fieldRead(observable:true, staticGetter: false, changeCount: 10);

  _fieldRead(observable:false, staticGetter: true, changeCount: 0);
  _fieldRead(observable:true, staticGetter: true, changeCount: 0);

  _fieldRead(observable:false, staticGetter: true, changeCount: 1);
  _fieldRead(observable:true, staticGetter: true, changeCount: 1);

  _fieldRead(observable:false, staticGetter: true, changeCount: 10);
  _fieldRead(observable:true, staticGetter: true, changeCount: 10);

  _mapRead();
  _methodInvoke0();
  _methodInvoke1();
  _function2();
}

void _collectionRead({bool observable, int changeCount}) {
  var detector = new DirtyCheckingChangeDetector(_dynamicFieldGetterFactory);

  var description = '';

  List<int> list = new List.generate(20, (i) => i);

  if (observable) {
    list = new ObservableList<int>.from(list);
    description += '[CHANGE NOTIFIER]';
  } else {
    description += '[DIRTY CHECK]';
  }
  if (changeCount == 0) {
    description += ' 0/${list.length} change';
  } else if (changeCount == 1) {
    description += ' 1/${list.length} change';
  } else if (changeCount > 1) {
    description += ' $changeCount/${list.length} changes';
  }

  var watch = detector.watch(list, null, 'handler');
  detector.collectChanges();

  time(description + (observable ? ' ObservableList' : ' List'), () {
    detector.collectChanges();
    if (changeCount == 1) {
      list[3]++;
    } else if (changeCount > 1) {
      for (var i = 0; i < list.length; i++) {
        list[i]++;
      }
    }
  });
}

void _groupAddRemove({bool observable}) {
  var description = '';
  if (observable) {
    description += '[CHANGE NOTIFIER]';
  } else {
    description += '[DIRTY CHECK]';
  }
  var rootWatchGrp = new RootWatchGroup(_staticFieldGetterFactory,
        new DirtyCheckingChangeDetector(_staticFieldGetterFactory), {});
  var testRun = () {
    for (int i = 0; i < 10; i++) {
          WatchGroup child = rootWatchGrp.newGroup(observable ? new _ObservableObj() : new _Obj())
                ..watch(_parse('a'), _reactionFn)
                ..watch(_parse('b'), _reactionFn)
                ..watch(_parse('c'), _reactionFn)
                ..watch(_parse('d'), _reactionFn)
                ..watch(_parse('e'), _reactionFn)
                ..watch(_parse('f'), _reactionFn)
                ..watch(_parse('g'), _reactionFn)
                ..watch(_parse('h'), _reactionFn)
                ..watch(_parse('i'), _reactionFn)
                ..watch(_parse('j'), _reactionFn);
          rootWatchGrp.detectChanges();
          child.remove();
        }

  };
  time(description + ' add/remove 10 watchGroups with 10 watches', testRun);
}

void _fieldRead({bool observable, bool staticGetter, int changeCount}) {
  var description = '';
  var obj;
  if (observable) {
    description += '[CHANGE NOTIFIER]';
    obj = new _ObservableObj();
  } else {
    description += '[DIRTY CHECK]';
    obj = new _Obj();
  }
  var fieldGetterFactory;
  if (staticGetter) {
    description += ' staticGetter';
    fieldGetterFactory = _staticFieldGetterFactory;
  } else {
    description += ' dynamicGetter';
    fieldGetterFactory = _dynamicFieldGetterFactory;
  }
  if (changeCount == 0) {
    description +=' 0/20 field change';
  } else if (changeCount == 1) {
    description +=' 1/20 field change';
  } else if (changeCount > 1) {
    description +=' 20/20 field changes';
  }
  var watchGrp = new RootWatchGroup(fieldGetterFactory,
      new DirtyCheckingChangeDetector(fieldGetterFactory), obj)
          ..watch(_parse('a'), _reactionFn)
          ..watch(_parse('b'), _reactionFn)
          ..watch(_parse('c'), _reactionFn)
          ..watch(_parse('d'), _reactionFn)
          ..watch(_parse('e'), _reactionFn)
          ..watch(_parse('f'), _reactionFn)
          ..watch(_parse('g'), _reactionFn)
          ..watch(_parse('h'), _reactionFn)
          ..watch(_parse('i'), _reactionFn)
          ..watch(_parse('j'), _reactionFn)
          ..watch(_parse('k'), _reactionFn)
          ..watch(_parse('l'), _reactionFn)
          ..watch(_parse('m'), _reactionFn)
          ..watch(_parse('n'), _reactionFn)
          ..watch(_parse('o'), _reactionFn)
          ..watch(_parse('p'), _reactionFn)
          ..watch(_parse('q'), _reactionFn)
          ..watch(_parse('r'), _reactionFn)
          ..watch(_parse('s'), _reactionFn)
          ..watch(_parse('t'), _reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');

  time(description + ' on the same object', () {
    if (changeCount == 1) {
      obj.c++;
    } else if (changeCount > 1) {
      obj.a++;
      obj.b++;
      obj.c++;
      obj.d++;
      obj.e++;
      obj.f++;
      obj.g++;
      obj.h++;
      obj.i++;
      obj.j++;
      obj.k++;
      obj.l++;
      obj.m++;
      obj.n++;
      obj.o++;
      obj.p++;
      obj.q++;
      obj.r++;
      obj.s++;
      obj.t++;
    }
    watchGrp.detectChanges();
  });
}

_mapRead() {
  var map = {
      'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4,
      'f': 0, 'g': 1, 'h': 2, 'i': 3, 'j': 4,
      'k': 0, 'l': 1, 'm': 2, 'n': 3, 'o': 4,
      'p': 0, 'q': 1, 'r': 2, 's': 3, 't': 4};
  var watchGrp = new RootWatchGroup(_dynamicFieldGetterFactory,
      new DirtyCheckingChangeDetector(_dynamicFieldGetterFactory), map)
          ..watch(_parse('a'), _reactionFn)
          ..watch(_parse('b'), _reactionFn)
          ..watch(_parse('c'), _reactionFn)
          ..watch(_parse('d'), _reactionFn)
          ..watch(_parse('e'), _reactionFn)
          ..watch(_parse('f'), _reactionFn)
          ..watch(_parse('g'), _reactionFn)
          ..watch(_parse('h'), _reactionFn)
          ..watch(_parse('i'), _reactionFn)
          ..watch(_parse('j'), _reactionFn)
          ..watch(_parse('k'), _reactionFn)
          ..watch(_parse('l'), _reactionFn)
          ..watch(_parse('m'), _reactionFn)
          ..watch(_parse('n'), _reactionFn)
          ..watch(_parse('o'), _reactionFn)
          ..watch(_parse('p'), _reactionFn)
          ..watch(_parse('q'), _reactionFn)
          ..watch(_parse('r'), _reactionFn)
          ..watch(_parse('s'), _reactionFn)
          ..watch(_parse('t'), _reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('mapRead', () => watchGrp.detectChanges());
}

_methodInvoke0() {
  var context = new _Obj();
  context.a = new _Obj();
  var watchGrp = new RootWatchGroup(_dynamicFieldGetterFactory,
      new DirtyCheckingChangeDetector(_dynamicFieldGetterFactory), context)
          ..watch(_method('a', 'methodA'), _reactionFn)
          ..watch(_method('a', 'methodB'), _reactionFn)
          ..watch(_method('a', 'methodC'), _reactionFn)
          ..watch(_method('a', 'methodD'), _reactionFn)
          ..watch(_method('a', 'methodE'), _reactionFn)
          ..watch(_method('a', 'methodF'), _reactionFn)
          ..watch(_method('a', 'methodG'), _reactionFn)
          ..watch(_method('a', 'methodH'), _reactionFn)
          ..watch(_method('a', 'methodI'), _reactionFn)
          ..watch(_method('a', 'methodJ'), _reactionFn)
          ..watch(_method('a', 'methodK'), _reactionFn)
          ..watch(_method('a', 'methodL'), _reactionFn)
          ..watch(_method('a', 'methodM'), _reactionFn)
          ..watch(_method('a', 'methodN'), _reactionFn)
          ..watch(_method('a', 'methodO'), _reactionFn)
          ..watch(_method('a', 'methodP'), _reactionFn)
          ..watch(_method('a', 'methodQ'), _reactionFn)
          ..watch(_method('a', 'methodR'), _reactionFn)
          ..watch(_method('a', 'methodS'), _reactionFn)
          ..watch(_method('a', 'methodT'), _reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?()', () => watchGrp.detectChanges());
}

_methodInvoke1() {
  var context = new _Obj();
  context.a = new _Obj();
  var watchGrp = new RootWatchGroup(_dynamicFieldGetterFactory,
      new DirtyCheckingChangeDetector(_dynamicFieldGetterFactory), context)
          ..watch(_method('a', 'methodA1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodB1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodC1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodD1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodE1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodF1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodG1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodH1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodI1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodJ1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodK1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodL1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodM1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodN1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodO1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodP1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodQ1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodR1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodS1', [_parse('a')]), _reactionFn)
          ..watch(_method('a', 'methodT1', [_parse('a')]), _reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('obj.method?(obj)', () => watchGrp.detectChanges());
}

_function2() {
  var context = new _Obj();
  var watchGrp = new RootWatchGroup(_dynamicFieldGetterFactory,
      new DirtyCheckingChangeDetector(_dynamicFieldGetterFactory), context)
          ..watch(_add(0, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(1, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(2, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(3, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(4, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(5, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(6, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(7, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(8, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(9, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(10, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(11, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(12, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(13, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(14, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(15, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(16, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(17, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(18, _parse('a'), _parse('a')), _reactionFn)
          ..watch(_add(19, _parse('a'), _parse('a')), _reactionFn);

  print('Watch: ${watchGrp.fieldCost}; eval: ${watchGrp.evalCost}');
  time('add?(a, a)', () => watchGrp.detectChanges());
}

AST _add(id, lhs, rhs) =>
    new PureFunctionAST('add$id', (a, b) => a + b, [lhs, rhs]);

AST _method(lhs, methodName, [args, namedArgs]) {
  if (args == null) args = const [];
  if (namedArgs == null) namedArgs = const {};
  return new MethodAST(_parse(lhs), methodName, args, namedArgs);
}

AST _parse(String expression) {
  var currentAST = new ContextReferenceAST();
  expression.split('.').forEach((name) {
    currentAST = new FieldReadAST(currentAST, name);
  });
  return currentAST;
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

  methodA1(arg0) => a;
  methodB1(arg0) => b;
  methodC1(arg0) => c;
  methodD1(arg0) => d;
  methodE1(arg0) => e;
  methodF1(arg0) => f;
  methodG1(arg0) => g;
  methodH1(arg0) => h;
  methodI1(arg0) => i;
  methodJ1(arg0) => j;
  methodK1(arg0) => k;
  methodL1(arg0) => l;
  methodM1(arg0) => m;
  methodN1(arg0) => n;
  methodO1(arg0) => o;
  methodP1(arg0) => p;
  methodQ1(arg0) => q;
  methodR1(arg0) => r;
  methodS1(arg0) => s;
  methodT1(arg0) => t;

  methodA() => a;
  methodB() => b;
  methodC() => c;
  methodD() => d;
  methodE() => e;
  methodF() => f;
  methodG() => g;
  methodH() => h;
  methodI() => i;
  methodJ() => j;
  methodK() => k;
  methodL() => l;
  methodM() => m;
  methodN() => n;
  methodO() => o;
  methodP() => p;
  methodQ() => q;
  methodR() => r;
  methodS() => s;
  methodT() => t;
}

class _ObservableObj extends ChangeNotifier {
  @reflectable @observable dynamic get a => __$a;
  dynamic __$a = 1;
  @reflectable set a(dynamic value) { __$a = notifyPropertyChange(#a, __$a, value); }

  @reflectable @observable dynamic get b => __$b;
  dynamic __$b = 2;
  @reflectable set b(dynamic value) { __$b = notifyPropertyChange(#b, __$b, value); }

  @reflectable @observable dynamic get c => __$c;
  dynamic __$c = 3;
  @reflectable set c(dynamic value) { __$c = notifyPropertyChange(#c, __$c, value); }

  @reflectable @observable dynamic get d => __$d;
  dynamic __$d = 4;
  @reflectable set d(dynamic value) { __$d = notifyPropertyChange(#d, __$d, value); }

  @reflectable @observable dynamic get e => __$e;
  dynamic __$e = 5;
  @reflectable set e(dynamic value) { __$e = notifyPropertyChange(#e, __$e, value); }

  @reflectable @observable dynamic get f => __$f;
  dynamic __$f = 6;
  @reflectable set f(dynamic value) { __$f = notifyPropertyChange(#f, __$f, value); }

  @reflectable @observable dynamic get g => __$g;
  dynamic __$g = 7;
  @reflectable set g(dynamic value) { __$g = notifyPropertyChange(#g, __$g, value); }

  @reflectable @observable dynamic get h => __$h;
  dynamic __$h = 8;
  @reflectable set h(dynamic value) { __$h = notifyPropertyChange(#h, __$h, value); }

  @reflectable @observable dynamic get i => __$i;
  dynamic __$i = 9;
  @reflectable set i(dynamic value) { __$i = notifyPropertyChange(#i, __$i, value); }

  @reflectable @observable dynamic get j => __$j;
  dynamic __$j = 10;
  @reflectable set j(dynamic value) { __$j = notifyPropertyChange(#j, __$j, value); }

  @reflectable @observable dynamic get k => __$k;
  dynamic __$k = 11;
  @reflectable set k(dynamic value) { __$k = notifyPropertyChange(#k, __$k, value); }

  @reflectable @observable dynamic get l => __$l;
  dynamic __$l = 12;
  @reflectable set l(dynamic value) { __$l = notifyPropertyChange(#l, __$l, value); }

  @reflectable @observable dynamic get m => __$m;
  dynamic __$m = 13;
  @reflectable set m(dynamic value) { __$m = notifyPropertyChange(#m, __$m, value); }

  @reflectable @observable dynamic get n => __$n;
  dynamic __$n = 14;
  @reflectable set n(dynamic value) { __$n = notifyPropertyChange(#n, __$n, value); }

  @reflectable @observable dynamic get o => __$o;
  dynamic __$o = 15;
  @reflectable set o(dynamic value) { __$o = notifyPropertyChange(#o, __$o, value); }

  @reflectable @observable dynamic get p => __$p;
  dynamic __$p = 16;
  @reflectable set p(dynamic value) { __$p = notifyPropertyChange(#p, __$p, value); }

  @reflectable @observable dynamic get q => __$q;
  dynamic __$q = 17;
  @reflectable set q(dynamic value) { __$q = notifyPropertyChange(#q, __$q, value); }

  @reflectable @observable dynamic get r => __$r;
  dynamic __$r = 18;
  @reflectable set r(dynamic value) { __$r = notifyPropertyChange(#r, __$r, value); }

  @reflectable @observable dynamic get s => __$s;
  dynamic __$s = 19;
  @reflectable set s(dynamic value) { __$s = notifyPropertyChange(#s, __$s, value); }

  @reflectable @observable dynamic get t => __$t;
  dynamic __$t = 20;
  @reflectable set t(dynamic value) { __$t = notifyPropertyChange(#t, __$t, value); }
}