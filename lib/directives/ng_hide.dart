part of angular;


class NgHideAttrDirective {
  static String NG_HIDE_CLASS = 'ng-hide';

  NgHideAttrDirective(dom.Node node, NodeAttrs attrs, Scope scope) {
    scope.$watch(attrs[this], (value) {
      if (value != null && toBool(value)) {
        node.classes.add(NG_HIDE_CLASS);
      } else {
        node.classes.remove(NG_HIDE_CLASS);
      }
    });
  }
}
