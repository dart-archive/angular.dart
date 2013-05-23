part of angular;

class NgBindAttrDirective  {

  dom.Element element;
  DirectiveValue value;

  NgBindAttrDirective(dom.Element this.element, DirectiveValue this.value);

  attach(Scope scope) {
    scope.$watch(value, (value) { element.text = value; });
  }

}
