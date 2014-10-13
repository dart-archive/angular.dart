import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';


main() {
  var injector = applicationFactory().run();
  var scope = injector.get(Scope);
  scope.context['text'] = "Hello future";
  scope.context['max'] = 20;
  scope.context['curValue'] = 12;
  scope.apply();
}
