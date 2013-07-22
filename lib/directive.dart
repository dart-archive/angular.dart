part of angular;

String _COMPONENT = '-component';
String _DIRECTIVE = '-directive';
String _ATTR_DIRECTIVE = '-attr' + _DIRECTIVE;

class NgComponent {
  final String template;
  final String templateUrl;
  final String cssUrl;
  final String visibility;
  final Map<String, String> map;
  final String publishAs;
  final bool applyAuthorStyles;
  final bool resetStyleInheritance;

  const NgComponent({
    this.template,
    this.templateUrl,
    this.cssUrl,
    this.visibility: NgDirective.LOCAL_VISIBILITY,
    this.map,
    this.publishAs,
    this.applyAuthorStyles,
    this.resetStyleInheritance
  });
}

class NgDirective {
  static const String LOCAL_VISIBILITY = 'local';
  static const String CHILDREN_VISIBILITY = 'children';
  static const String DIRECT_CHILDREN_VISIBILITY = 'direct_children';

  final String selector;
  final String transclude;
  final int priority;
  final String visibility;

  const NgDirective({
    this.selector,
    this.transclude,
    this.priority : 0,
    this.visibility: LOCAL_VISIBILITY
  });
}

/**
 * See:
 * http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-201/#toc-style-inheriting
 */
class NgShadowRootOptions {
  final bool applyAuthorStyles;
  final bool resetStyleInheritance;
  const NgShadowRootOptions([this.applyAuthorStyles = false,
                             this.resetStyleInheritance = false]);
}

// TODO(pavelgj): Get rid of Directive and use NgComponent/NgDirective directly.
class Directive {
  Type type;
  // TODO(misko): this should be renamed to selector once we change over to meta-data.
  String $name;
  Function $generate;
  String $transclude;
  int $priority = 0;
  String $template;
  String $templateUrl;
  String $cssUrl;
  String $publishAs;
  Map<String, String> $map;
  String $visibility;
  NgShadowRootOptions $shadowRootOptions = new NgShadowRootOptions();

  bool isComponent = false;
  bool isStructural = false;

  Directive(this.type) {
    var name = type.toString();
    var isAttr = false;
    $name = name.splitMapJoin(
        new RegExp(r'[A-Z]'),
        onMatch: (m) => '-' + m.group(0).toLowerCase())
      .substring(1);

    var directive = _reflectSingleMetadata(type, NgDirective);
    var component = _reflectSingleMetadata(type, NgComponent);
    if (directive != null && component != null) {
      throw 'Cannot have both NgDirective and NgComponent annotations.';
    }

    var selector;
    if (directive != null) {
      selector = directive.selector;
      $transclude = directive.transclude;
      $priority = directive.priority;
      $visibility = directive.visibility;
    }
    if (component != null) {
      $template = component.template;
      $templateUrl = component.templateUrl;
      $cssUrl = component.cssUrl;
      $visibility = component.visibility;
      $map = component.map;
      $publishAs = component.publishAs;
      $shadowRootOptions = new NgShadowRootOptions(component.applyAuthorStyles,
          component.resetStyleInheritance);
    }

    if (selector != null) {
      $name = selector;
    } else if ($name.endsWith(_ATTR_DIRECTIVE)) {
      $name = '[${$name.substring(0, $name.length - _ATTR_DIRECTIVE.length)}]';
    } else if ($name.endsWith(_DIRECTIVE)) {
      $name = $name.substring(0, $name.length - _DIRECTIVE.length);
    } else if ($name.endsWith(_COMPONENT)) {
      isComponent = true;
      $name = $name.substring(0, $name.length - _COMPONENT.length);
    } else {
      throw "Directive name '$name' must end with $_DIRECTIVE, $_ATTR_DIRECTIVE, $_COMPONENT or have a \$selector field.";
    }

    isStructural = $transclude != null;
    if (isComponent && $map == null) {
      $map = new Map<String, String>();
    }
  }
}

_reflectSingleMetadata(Type type, Type metadataType) {
  var metadata = reflectMetadata(type, metadataType);
  if (metadata.length == 0) {
    return null;
  }
  if (metadata.length > 1) {
    throw 'Expecting not more than one annotation of type $metadataType';
  }
  return metadata.first;
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

class Controller {

}
