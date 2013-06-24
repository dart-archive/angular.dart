part of angular;


class NgHideAttrDirective {
  static String NG_HIDE_CLASS = 'ng-hide';

  String expression;
  dom.Element node;

  NgHideAttrDirective(dom.Node this.node, DirectiveValue value) {
    expression = value.value;
  }

  attach(Scope scope) {
    scope.$watch(expression, (value, _, __) {
      if (value != null && toBool(value)) {
        node.classes.add(NG_HIDE_CLASS);
      } else {
        node.classes.remove(NG_HIDE_CLASS);
      }
    });
  }
}
