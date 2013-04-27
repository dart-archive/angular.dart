part of angular;

abstract class Directive {
  attach(Scope scope);
}

class DirectiveFactory {
  Type directiveType;
  String $name;

  DirectiveFactory(this.directiveType);
}

class DirectiveDef {
  DirectiveFactory directiveFactory;
  String value;
  Map<String, BlockType> blockTypes;

  DirectiveDef(DirectiveFactory this.directiveFactory,
               String this.value,
               [Map<String, BlockType> this.blockTypes]);

  bool isComponent() => this.blockTypes != null;
}

class DirectiveInfo {
  dom.Node element;
  String selector;
  String name;
  String value;
  Type directiveType;

  DirectiveInfo(this.element, this.selector, [this.name = null, this.value = null]) {
    ASSERT(element != null);
    ASSERT(selector != null);
  }

  String toString() {
    return '{ element: ${element.outerHtml}, selector: $selector, name: $name, value: $value }';
  }
}
