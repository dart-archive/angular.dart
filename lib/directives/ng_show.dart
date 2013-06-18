part of angular;


class NgShowAttrDirective {
  static String NG_SHOW_CLASS = 'ng-show';

  NgShowAttrDirective(dom.Node node, NodeAttrs attrs, Scope scope) {
    scope.$watch(attrs[this], (value, _, __) {
      if (value != null && toBool(value)) {
        node.classes.add(NG_SHOW_CLASS);
      } else {
        node.classes.remove(NG_SHOW_CLASS);
      }
    });
  }
}
