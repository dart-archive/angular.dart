library test_files.main;

import 'package:angular/core/annotation_src.dart';

@Decorator(
    children: Directive.TRANSCLUDE_CHILDREN,
    selector:'[ng-if]',
    map: const {'.': '=>ngIfCondition'})
class NgIfDirective {
  bool ngIfCondition;
}

@Component(
    selector: 'my-component',
    map: const {
      'attr': '@attr',
      'expr': '=>expr'
    },
    template: '<div>{{ctrl.inline.template.expression}}</div>',
    exportExpressionAttrs: const ['exported-attr'],
    exportExpressions: const ['exported + expression'])
class MyComponent {
  @Bind('another-expression')
  String anotherExpression;

  @Bind('callback')
  set callback(Function) {}

  set twoWayStuff(String abc) {}
  @Bind('two-way-stuff')
  String get twoWayStuff => null;
}

class CssUrlsString {

}

class CssUrlsList {

}
