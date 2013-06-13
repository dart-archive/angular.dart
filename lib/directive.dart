part of angular;

String _DIRECTIVE = '-directive';
String _ATTR_DIRECTIVE = '-attr' + _DIRECTIVE;

class Directive {
  Type directiveControllerType;
  String $name;
  Function $generate;
  String $transclude;
  int $priority = 0;
  Type $controllerType;
  String $requiredController;
  String $template;

  Directive(this.directiveControllerType) {
    var name = directiveControllerType.toString();
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
    $transclude = reflectStaticField(directiveControllerType, '\$transclude');
    $template = reflectStaticField(directiveControllerType, '\$template');
    $controllerType = reflectStaticField(directiveControllerType, '\$controller');
    //TODO (misko): remove this. No need for $require since the directives can just ask for each other
    var required = reflectStaticField(directiveControllerType, '\$require');
    if (required != null) {
      $requiredController = "\$${required}Controller";
    }

    if ($controllerType != null) {
      assert($requiredController == null);
      $requiredController = "\$${$name}Controller";
    }
    var $selector = reflectStaticField(directiveControllerType, r'$selector');
    if ($selector != null) {
      $name = $selector;
    }
  }
}

class DirectiveDef {
  Directive directive;
  String value;
  Map<String, BlockType> blockTypes;

  DirectiveDef(Directive this.directive,
               String this.value,
               [Map<String, BlockType> this.blockTypes]);

  bool isComponent() => this.blockTypes != null;
}

class DirectiveRef {
  dom.Node element;
  String selector;
  String name;
  String value;
  Directive directive;

  DirectiveRef(this.element, this.selector, [this.name = null, this.value = null]) {
    ASSERT(element != null);
    ASSERT(selector != null);
  }

  String toString() {
    return '{ element: ${element.outerHtml}, selector: $selector, name: $name, value: $value }';
  }
}


class DirectiveRegistry {
  Map<String, Directive> directiveMap = {};

  List<String> enumerate() => directiveMap.keys.toList();

  register(Type directiveType) {
   var directive = new Directive(directiveType);

   directiveMap[directive.$name] = directive;
  }

  Directive operator[](String selector) {
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

class Controller {

}
