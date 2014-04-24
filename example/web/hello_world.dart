import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Controller(selector: '[hello-world-controller]')
class HelloWorld {
  String name = "world";
}

main() {
  applicationFactory()
      .addModule(new Module()..bind(HelloWorld))
      .run();
}
