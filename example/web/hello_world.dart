import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  String name = "world";
}

main() {
  applicationFactory()
      .addModule(new Module()..type(HelloWorldController))
      .run();
}
