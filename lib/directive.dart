part of angular;

abstract class Directive {
  attach(Scope scope);
}

String _DIRECTIVE = '-directive';
String _ATTR_DIRECTIVE = '-attr' + _DIRECTIVE;

class DirectiveFactory {
  Type directiveType;
  String $name;
  Function $generate;
  String $transclude;
  int $priority = 0;

  DirectiveFactory(this.directiveType) {
    var name = directiveType.toString();
    var isAttr = false;
    $name = name.splitMapJoin(
        new RegExp(r'[A-Z]'),
        onMatch: (m) => '-' + m.group(0).toLowerCase())
      .substring(1);

    if ($name.endsWith(_ATTR_DIRECTIVE)) {
      $name = '[${$name.substring(0, $name.length - _ATTR_DIRECTIVE.length)}]';
    } else if ($name.endsWith(_DIRECTIVE)) {
      $name = $name.substring(0, $name.length - _DIRECTIVE.length);
    } else {
      throw "Directive name must end with $_DIRECTIVE or $_ATTR_DIRECTIVE.";
    }

    // Check the $transclude.
    // TODO(deboer): I'm not a fan of 'null' as a configuration value.
    // It would be awesome if $transclude could be an enum.
    $transclude = reflectStaticField(directiveType, '\$transclude');
  }
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

class DirectiveValue {
  String value;
  DirectiveValue() : this.value = "ERROR DEFAULT";
  DirectiveValue.fromString(this.value);
}
