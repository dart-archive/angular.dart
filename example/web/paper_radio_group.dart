import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'dart:html';

@Decorator(
    selector: 'paper-radio-group',
    updateBoundElementPropertiesOnEvents: const ['core-select']
)
class PaperRadioGroupBindings {}

@Decorator(
    selector: 'paper-radio-button',
    updateBoundElementPropertiesOnEvents: const ['change', 'core-change']
)
class PaperRadioButtonBindings {}

@Component(
    selector: 'cmp',
    template: '<paper-radio-group bind-selected="insertOption"> <paper-radio-button name="asis" label="Insert as is"></paper-radio-button> <paper-radio-button name="duplicate" label="Insert as duplicate"></paper-radio-button> </paper-radio-group> {{insertOption}}'
)
class Cmp {
  Object insertOption;
}

main() {
  applicationFactory()
      .addModule(new Module()
          ..bind(PaperRadioButtonBindings)
          ..bind(PaperRadioGroupBindings)
          ..bind(Cmp))
      .run();
}
