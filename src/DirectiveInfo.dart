part of angular;

class DirectiveInfo {
  dom.Node element;
  String selector;
  String name;
  String value;
  Type directiveType;

  DirectiveInfo(this.element, this.selector, [this.name = null, this.value = null]);

  String toString() {
    return '{ element: ${element.outerHtml}, selector: $selector, name: $name, value: $value }';
  }
}
