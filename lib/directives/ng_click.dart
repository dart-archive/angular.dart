part of angular;


class NgClickAttrDirective {
  String expression;
  dom.Node node;


  NgClickAttrDirective(dom.Node this.node, DirectiveValue directiveValue) {
    expression = directiveValue.value;
  }

  attach(Scope scope) {
    node.onClick.listen((event) => scope.$apply(expression));
  }
}