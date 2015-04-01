import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Decorator(
    selector: 'paper-input',
    updateBoundElementPropertiesOnEvents: const ['change', 'input'])
class PaperInputBindings {}

main() {
  applicationFactory().addModule(new Module()..bind(PaperInputBindings)).run();
}
