import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  String name = "world";
}

main() {
  dynamicApplication()
      .addModule(new Module()..type(HelloWorldController))
      .run();
}
