part of angular;

class NgBindAttrDirective  {

  List<dom.Node> nodeList;
  DirectiveValue value;

  NgBindAttrDirective(List<dom.Node> this.nodeList, DirectiveValue this.value);

  attach(Scope scope) {
    scope.$watch(value, (value) { nodeList[0].text = value; });
  }

}
