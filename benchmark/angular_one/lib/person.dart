library person;

import 'package:angular/angular.dart';

@NgComponent(selector: 'person-component',
  templateUrl: 'packages/angular_one/person.html',
  cssUrl: 'packages/angular_one/person.css',
  publishAs: 'ctrl'
)
class PersonComponent {
  @NgOneWay('person')
  Person person;
}

class PersonModule extends Module {
  PersonModule() {
    type(PersonComponent);
  }
}

class Person {
  List<Contact> contacts = [];
  String name;

  Person(this.name, this.contacts);
}

class Contact {
  String type;
  String value;

  Contact(this.type, this.value);
}