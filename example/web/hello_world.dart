import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';

// This annotation allows Dart to shake away any classes
// not used from Dart code nor listed in another @MirrorsUsed.
//
// If you create classes that are referenced from the Angular
// expressions, you must include a library target in @MirrorsUsed.
@MirrorsUsed(override: '*')
import 'dart:mirrors';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  String name = "world";
}

main() {
  ngDynamicApp()
      .addModule(new Module()..type(HelloWorldController))
      .run();
}
