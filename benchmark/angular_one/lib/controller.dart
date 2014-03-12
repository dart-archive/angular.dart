library main;

import 'person.dart';
import 'package:angular/angular.dart';

@NgController(selector: '[main]', publishAs: 'ctrl')
class MainController {
  List<Person> people;

  MainController() {
    people = [];
    people.add(new Person('Marko', [new Contact('mobile', '0406831112'), new Contact('landline', '022991992')]));
    people.add(new Person('Amanda', [new Contact('mobile', '0416929865'), new Contact('landline', '0298765432')]));
  }
}

class ControllerModule extends Module {
  ControllerModule() {
    type(MainController);
  }
}