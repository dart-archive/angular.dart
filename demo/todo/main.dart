import 'package:angular/angular.dart';
import 'todo.dart';

main() {
  bootstrapAngular([new AngularModule()..type(TodoController)]);
}
