import 'package:angular/angular.dart';

import 'package:angular_one/person.dart';
import 'package:angular_one/controller.dart';

class BenchmarkModule extends Module {
  BenchmarkModule() {
    install(new PersonModule());
    install(new ControllerModule());
  }
}