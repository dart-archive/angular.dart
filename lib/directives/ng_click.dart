part of angular;


class NgClickAttrDirective {
  NgClickAttrDirective(dom.Node node, NodeAttrs attrs, Scope scope) {
    var expression = attrs[this];
    node.onClick.listen((event) => scope.$apply(expression));
  }
}
