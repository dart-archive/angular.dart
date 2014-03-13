import 'dart:html';
import 'package:angular/angular.dart';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:angular_one/person.dart';

import 'module.dart';

class AddItemBenchmark extends BenchmarkBase {
  List<Person> people;
  Scope scope;
  Injector injector;
  NgZone zone;

  AddItemBenchmark(): super('AddItemBenchmark');

  void run() {
    zone.run(() => people.add(new Person('Misko',[new Contact('mobile', '0406831112'), new Contact('landline', '022991992')])));
  }

  void setup() {
    people = [];
    people.add(new Person('Marko', [new Contact('mobile', '0406831112'), new Contact('landline', '022991992')]));
    people.add(new Person('Amanda', [new Contact('mobile', '0416929865'), new Contact('landline', '0298765432')]));
    injector = ngBootstrap(module: new BenchmarkModule());
    scope = injector.get(RootScope);
    zone = injector.get(NgZone);
    zone.run(() => scope.context['people'] = people);
  }

  void teardown() {}
}

void main() {
  new AddItemBenchmark()..report();
}