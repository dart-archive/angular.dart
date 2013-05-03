part of angular;

abstract class Directive {
  attach(Scope scope);
}

class DirectiveFactory {
  Type directiveType;
  String $name;
  Function $generate;
  String $transclude;

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
  DirectiveFactory directiveFactory;

  DirectiveInfo(this.element, this.selector, [this.name = null, this.value = null]) {
    ASSERT(element != null);
    ASSERT(selector != null);
  }

  String toString() {
    return '{ element: ${element.outerHtml}, selector: $selector, name: $name, value: $value }';
  }
}


class Directives {
  Map<String, DirectiveFactory> directiveMap = {};

  List<String> enumerate() => directiveMap.keys.toList();

  register(Type directiveType) {
   var directiveFactory = new DirectiveFactory(directiveType);
   directiveFactory.$name = '[bind]';

   directiveMap[directiveFactory.$name] = directiveFactory;
  }

  DirectiveFactory operator[](String selector) {
    if (directiveMap.containsKey(selector)){
      return directiveMap[selector];
    } else {
      throw new ArgumentError('Unknown selector: $selector');
    }
  }
}
