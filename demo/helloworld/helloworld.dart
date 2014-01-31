library angular.demo.hello_world;

import 'package:angular/angular.dart';
import 'package:angular/dart2js_mirrors.dart';

// This annotation allows Dart to shake away any classes
// not used from Dart code nor listed in another @MirrorsUsed.
//
// If you create classes that are referenced from the Angular
// expressions, you must include a library target in @MirrorsUsed.
@MirrorsUsed(targets: const['angular.demo.hello_world'])
import 'dart:mirrors';

main() {
  ngBootstrap();
}
