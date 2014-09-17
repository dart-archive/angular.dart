import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import '../packages/quiver/core.dart'; 

main() {
  var module = new Module()..bind(MainComponent)..bind(ComponentTwo);

  applicationFactory()
      .addModule(module)
      .run();
}

@Component(
  selector: 'cmp-one',
  template: '''<div>
  <input type="checkbox" ng-model="ctrl.optionalPresent" />
  <label>Toggle optional</label>
</div>
<div ng-if="ctrl.optional.isPresent">
  <cmp-two value="ctrl.optional.value" />
</div>''',
  publishAs: 'ctrl')
class MainComponent {
  Optional<String> optional = new Optional.absent();

  int count = 1;
  
  bool get optionalPresent => optional.isPresent;
  void set optionalPresent(bool value) {
    optional = new Optional.fromNullable(value ? "optionalPresent" + (count++).toString() : null);
  }
}

@Component(
  selector: 'cmp-two',
  template: '<div>{{ctrl.value}}</div>',
  publishAs: 'ctrl')
class ComponentTwo {
  @NgOneWay('value')
  String value;
}