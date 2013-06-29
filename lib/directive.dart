part of angular;

String _COMPONENT = '-component';
String _DIRECTIVE = '-directive';
String _ATTR_DIRECTIVE = '-attr' + _DIRECTIVE;

class Directive {
  Type type;
  // TODO(misko): this should be renamed to selector once we change over to meta-data.
  String $name;
  Function $generate;
  String $transclude;
  int $priority = 0;
  Type $controllerType;
  String $template;
  String $templateUrl;
  String $cssUrl;
  String $publishAs;
  Map<String, String> $map;
  String $visibility;
  ShadowRootOptions $shadowRootOptions;

  bool isComponent = false;
  bool isStructural = false;

  Directive(this.type) {
    var name = type.toString();
    var isAttr = false;
    $name = name.splitMapJoin(
        new RegExp(r'[A-Z]'),
        onMatch: (m) => '-' + m.group(0).toLowerCase())
      .substring(1);

    var $selector = reflectStaticField(type, r'$selector');
    if ($selector != null) {
      $name = $selector;
    } else if ($name.endsWith(_ATTR_DIRECTIVE)) {
      $name = '[${$name.substring(0, $name.length - _ATTR_DIRECTIVE.length)}]';
    } else if ($name.endsWith(_DIRECTIVE)) {
      $name = $name.substring(0, $name.length - _DIRECTIVE.length);
    } else if ($name.endsWith(_COMPONENT)) {
      isComponent = true;
      $name = $name.substring(0, $name.length - _COMPONENT.length);
    } else {
      throw "Directive name must end with $_DIRECTIVE or $_ATTR_DIRECTIVE.";
    }

    // Check the $transclude.
    // TODO(deboer): I'm not a fan of 'null' as a configuration value.
    // It would be awesome if $transclude could be an enum.
    $transclude = reflectStaticField(type, '\$transclude');
    $template = reflectStaticField(type, '\$template');
    $templateUrl = reflectStaticField(type, '\$templateUrl');
    $cssUrl = reflectStaticField(type, '\$cssUrl');
    $priority = _defaultIfNull(reflectStaticField(type, '\$priority'), 0);
    $visibility = _defaultIfNull(
        reflectStaticField(type, '\$visibility'), DirectiveVisibility.LOCAL);
    $map = reflectStaticField(type, '\$map');
    $publishAs = reflectStaticField(type, r'$publishAs');
    isStructural = $transclude != null;
    if (isComponent && $map == null) {
      $map = new Map<String, String>();
    }
    if (isComponent) {
      $shadowRootOptions = _defaultIfNull(
          reflectStaticField(type, '\$shadowRootOptions'),
          new ShadowRootOptions());
    }
  }
}

dynamic _defaultIfNull(dynamic value, dynamic defaultValue) =>
    value == null ? defaultValue : value;

class DirectiveRef {
  dom.Node element;
  String selector;
  String name;
  String value;
  Directive directive;
  Map<String, BlockType> blockTypes;

  DirectiveRef(this.element, this.selector, [
               String this.name,
               String this.value,
               Directive this.directive,
               Map<String, BlockType> this.blockTypes]) {
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

abstract class DirectiveVisibility {
  static const String LOCAL = 'local';
  static const String CHILDREN = 'children';
  static const String DIRECT_CHILDREN = 'direct_children';
}

/**
 * See:
 * http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-201/#toc-style-inheriting
 */
class ShadowRootOptions {
  bool $applyAuthorStyles = false;
  bool $resetStyleInheritance = false;
  ShadowRootOptions([this.$applyAuthorStyles = false,
                     this.$resetStyleInheritance = false]);
}

class Controller {

}
