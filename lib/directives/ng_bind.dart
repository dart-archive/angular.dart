part of angular;

class NgBindAttrDirective  {

  NgBindAttrDirective(dom.Element element, NodeAttrs attrs, Scope scope) {
    scope.$watch(attrs[this], (value) => element.text = value);
  }

}
