library angular.benchmarks.invoke;

import 'package:benchmark_harness/benchmark_harness.dart';

main() {
  new MonomorphicClosure0ListInvoke().report();
  new PolymorphicMethod0ListInvoke().report();
  new PolymorphicClosure0ListInvoke().report();
  new PolymorphicMethod1ListInvoke().report();
  new PolymorphicClosure1ListInvoke().report();
}

var closure0Factory = [
        () => () => 0,
        () => () => 1,
        () => () => 2,
        () => () => 3,
        () => () => 4,
        () => () => 5,
        () => () => 6,
        () => () => 7,
        () => () => 8,
        () => () => 9,
];

var closure1Factory = [
        () => (i) => 0,
        () => (i) => 1,
        () => (i) => 2,
        () => (i) => 3,
        () => (i) => 4,
        () => (i) => 5,
        () => (i) => 6,
        () => (i) => 7,
        () => (i) => 8,
        () => (i) => 9,
];

var instanceFactory = [
        () => new Obj0(),
        () => new Obj1(),
        () => new Obj2(),
        () => new Obj3(),
        () => new Obj4(),
        () => new Obj5(),
        () => new Obj6(),
        () => new Obj7(),
        () => new Obj8(),
        () => new Obj9(),
];

class Obj0 { method0() => 0; method1(i) => 0; }
class Obj1 { method0() => 1; method1(i) => 1; }
class Obj2 { method0() => 2; method1(i) => 2; }
class Obj3 { method0() => 3; method1(i) => 3; }
class Obj4 { method0() => 4; method1(i) => 4; }
class Obj5 { method0() => 5; method1(i) => 5; }
class Obj6 { method0() => 6; method1(i) => 6; }
class Obj7 { method0() => 7; method1(i) => 7; }
class Obj8 { method0() => 8; method1(i) => 8; }
class Obj9 { method0() => 9; method1(i) => 9; }

class PolymorphicClosure0ListInvoke extends BenchmarkBase {
  PolymorphicClosure0ListInvoke() : super('PolymorphicClosure0ListInvoke');

  var list = new List.generate(10000, (i) => closure0Factory[i%10]());

  run() {
    int sum = 0;
    for(var i=0; i < list.length; i++) {
      sum += list[i]();
    }
    return sum;
  }
}

class MonomorphicClosure0ListInvoke extends BenchmarkBase {
  MonomorphicClosure0ListInvoke() : super('MonomorphicClosure0ListInvoke');

  var list = new List.generate(10000, (i) => closure0Factory[0]());

  run() {
    int sum = 0;
    for(var i=0; i < list.length; i++) {
      sum += list[i]();
    }
    return sum;
  }
}

class PolymorphicClosure1ListInvoke extends BenchmarkBase {
  PolymorphicClosure1ListInvoke() : super('PolymorphicClosure1ListInvoke');

  var list = new List.generate(10000, (i) => closure1Factory[i%10]());

  run() {
    int sum = 0;
    for(var i=0; i < list.length; i++) {
      sum += list[i](i);
    }
    return sum;
  }
}

class PolymorphicMethod0ListInvoke extends BenchmarkBase {
  PolymorphicMethod0ListInvoke() : super('PolymorphicMethod0ListInvoke');

  var list = new List.generate(10000, (i) => instanceFactory[i%10]());

  run() {
    int sum = 0;
    for(var i=0; i < list.length; i++) {
      sum += list[i].method0();
    }
    return sum;
  }
}

class PolymorphicMethod1ListInvoke extends BenchmarkBase {
  PolymorphicMethod1ListInvoke() : super('PolymorphicMethod1ListInvoke');

  var list = new List.generate(10000, (i) => instanceFactory[i%10]());

  run() {
    int sum = 0;
    for(var i=0; i < list.length; i++) {
      sum += list[i].method1(i);
    }
    return sum;
  }
}

