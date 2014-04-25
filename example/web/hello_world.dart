import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

class HelloWorld {
  String name = "world";
}

main() {
  applicationFactory()
      .rootContextType(HelloWorld)
      .run();
}
