import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/messages/module.dart';

main() {
  applicationFactory()
      .addModule(new MessagesModule())
      .run();
}
