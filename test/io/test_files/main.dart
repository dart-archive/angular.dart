library test_files.main;

import 'package:angular/core/module.dart';

@NgComponent(
    selector: 'my-component',
    map: const {
      'attr': '@attr',
      'expr': '=>expr'
    },
    exportExpressionAttrs: const ['exported-attr'],
    exportExpressions: const ['exported + expression']
)
class MyComponent {
  @NgOneWay('another-expression')
  String anotherExpression;

  @NgCallback('callback')
  set callback(Function) {}

  set twoWayStuff(String abc) {}
  @NgTwoWay('two-way-stuff')
  String get twoWayStuff => null;
}