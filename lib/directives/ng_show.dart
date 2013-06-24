part of angular;


class NgShowAttrDirective {
  static String NG_SHOW_CLASS = 'ng-show';

  String expression;
  dom.Element node;

  NgShowAttrDirective(dom.Node this.node, DirectiveValue value) {
    expression = value.value;
  }

  attach(Scope scope) {
    scope.$watch(expression, (value, _, __) {
      if (value != null && toBool(value)) {
        node.classes.add(NG_SHOW_CLASS);
      } else {
        node.classes.remove(NG_SHOW_CLASS);
      }
    });
  }
}
