import 'package:angular/angular.dart';

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
