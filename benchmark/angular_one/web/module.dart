import 'package:angular/angular.dart';

import 'package:angular_one/person.dart';

class BenchmarkModule extends Module {
  BenchmarkModule() {
    install(new PersonModule());
  }
}