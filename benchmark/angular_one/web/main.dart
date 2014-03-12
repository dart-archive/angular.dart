import 'package:angular/angular.dart';

import 'package:angular_one/person.dart';
import 'package:angular_one/controller.dart';

void main() {
  Stopwatch moduleCreationStopwatch = new Stopwatch();
  moduleCreationStopwatch.start();
  var m = new BenchmarkModule();
  moduleCreationStopwatch.stop();
  ngBootstrap(module: m);
}

class BenchmarkModule extends Module {
  BenchmarkModule() {
    install(new PersonModule());
    install(new ControllerModule());
  }
}