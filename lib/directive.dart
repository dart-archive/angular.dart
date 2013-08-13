part of angular;

String _COMPONENT = '-component';
String _DIRECTIVE = '-directive';
String _ATTR_DIRECTIVE = '-attr' + _DIRECTIVE;

class _NgAnnotationBase {
  final String selector;
  final String visibility;
  final List<Type> publishTypes;

  const _NgAnnotationBase({
    this.selector,
    this.visibility: NgDirective.LOCAL_VISIBILITY,
    this.publishTypes
  });
}

/**
 * Meta-data marker placed on a class which should act as a controller for the
 * component. Angular components are a light-weight version of web-components.
 * Angular components use shadow-DOM for rendering their templates.
 */
class NgComponent extends _NgAnnotationBase {
  /**
   * Inlined HTML template for the component.
   */
  final String template;

  /**
   * A URL to HTML template. This will be loaded asynchronously and
   * cached for future component instances.
   */
  final String templateUrl;

  /**
   * A CSS URL to load into the shadow DOM.
   */
  final String cssUrl;

  /**
   * Use map to define the mapping of component's DOM attributes into
   * the component instance or scope. The map's key is the DOM attribute name
   * to map in camelCase (DOM attribute is in dash-case). The Map's value
   * consists of a mode character, and an expression. If expression is not
   * specified, it maps to the same scope parameter as is the DOM attribute.
   *
   * * `@` - Map the DOM attribute string. The attribute string will be taken
   *   literally or interpolated if it contains binding {{}} systax.
   *
   * * `=` - Treat the DOM attribute value as an expression. Set up a watch
   *   on both outside as well as component scope to keep the src and
   *   destination in sync.
   *
   * * `&` - Treat the DOM attribute value as an expression. Assign a closure
   *   function into the component. This allows the component to control
   *   the invocation of the closure. This is useful for passing
   *   expressions into controllers which act like callbacks.
   *
   * NOTE: an expression may start with `.` which evaluates the expression
   * against the current controller rather then current scope.
   *
   * Example:
   *
   *     <my-component title="Hello {{username}}"
   *                   selection="selectedItem"
   *                   on-selection-change="doSomething()">
   *
   *     @NgComponent(
   *       selector: 'my-component'
   *       map: cost {
   *         'title': '@.title',
   *         'selection': '=.currentItem',
   *         'onSelectionChange': '&.onChange'
   *       }
   *     )
   *     class MyComponent {
   *       String title;
   *       var currentItem;
   *       ParsedFn onChange;
   *     }
   *
   *  The above example shows how all three mapping modes are used.
   *
   *  * `@.title` maps the title DOM attribute to the controller `title`
   *    field. Notice that this maps the content of the attribute, which
   *    means that it can be used with `{{}}` interpolation.
   *
   *  * `=.currentItem` maps the expression (in this case the `selectedItem`
   *    in the current scope into the `currentItem` in the controller. Notice
   *    that mapping is bi-directional. A change either in controller or on
   *    parent scope will result in change of the other.
   *
   *  * `&.onChange` maps the expression into tho controllers `onChange`
   *    field. The result of mapping is a callable function which can be
   *    invoked at any time by the controller. The invocation of the
   *    callable function will result in the expression `doSomething()` to
   *    be executed in the parent context.
   */
  final Map<String, String> map;

  /**
   * An expression under which the controller instance will be published into.
   * This allows the expressions in the template to be referring to controller
   * instance and its properties.
   */
  final String publishAs;

  /**
   * Set the shadow root applyAuthorStyles property. See shadow-DOM
   * documentation for further details.
   */
  final bool applyAuthorStyles;

  /**
   * Set the shadow root resetStyleInheritance property. See shadow-DOM
   * documentation for further details.
   */
  final bool resetStyleInheritance;

  const NgComponent({
    this.template,
    this.templateUrl,
    this.cssUrl,
    this.map,
    this.publishAs,
    this.applyAuthorStyles,
    this.resetStyleInheritance,
    selector,
    visibility,
    publishTypes : const <Type>[]
  }) : super(selector: selector, visibility: visibility, publishTypes: publishTypes);
}

class NgDirective extends _NgAnnotationBase {
  static const String LOCAL_VISIBILITY = 'local';
  static const String CHILDREN_VISIBILITY = 'children';
  static const String DIRECT_CHILDREN_VISIBILITY = 'direct_children';

  final bool transclude;

  const NgDirective({
    this.transclude: false,
    selector,
    visibility,
    publishTypes : const <Type>[]
  }) : super(selector: selector, visibility: visibility, publishTypes: publishTypes);
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

Map<Type, Directive> _directiveCache = new Map<Type, Directive>();

// TODO(pavelgj): Get rid of Directive and use NgComponent/NgDirective directly.
class Directive {
  static int STRUCTURAL_PRIORITY = 2;
  static int ATTR_PRIORITY = 1;
  static int COMPONENT_PRIORITY = 0;

  Type type;
  // TODO(misko): this should be renamed to selector once we change over to meta-data.
  String $name;
  Function $generate;
  bool $transclude = false;
  int $priority = Directive.ATTR_PRIORITY;
  String $template;
  String $templateUrl;
  String $cssUrl;
  String $publishAs;
  Map<String, String> $map;
  String $visibility;
  NgShadowRootOptions $shadowRootOptions = new NgShadowRootOptions();
  List<Type> $publishTypes = <Type>[];

  bool isComponent = false;
  bool isStructural = false;

  Directive._new(Type this.type);

  factory Directive(Type type) {
    var instance = _directiveCache[type];
    if (instance != null) {
      return instance;
    }

    instance = new Directive._new(type);
    var name = type.toString();
    var isAttr = false;
    instance.$name = name.splitMapJoin(
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
      instance.$transclude = directive.transclude;
      instance.$visibility = directive.visibility;
      instance.$publishTypes = directive.publishTypes;
    }
    if (component != null) {
      instance.$priority = Directive.COMPONENT_PRIORITY;
      instance.$template = component.template;
      selector = component.selector;
      instance.$templateUrl = component.templateUrl;
      instance.$cssUrl = component.cssUrl;
      instance.$visibility = component.visibility;
      instance.$map = component.map;
      instance.$publishAs = component.publishAs;
      instance.$shadowRootOptions =
          new NgShadowRootOptions(component.applyAuthorStyles,
                                  component.resetStyleInheritance);
      instance.$publishTypes = component.publishTypes;
    }

    if (selector != null) {
      instance.$name = selector;
    } else if (instance.$name.endsWith(_ATTR_DIRECTIVE)) {
      var attrName = instance.$name.
          substring(0, instance.$name.length - _ATTR_DIRECTIVE.length);
      instance.$name = '[$attrName]';
    } else if (instance.$name.endsWith(_DIRECTIVE)) {
      instance.$name = instance.$name.
          substring(0, instance.$name.length - _DIRECTIVE.length);
    } else if (instance.$name.endsWith(_COMPONENT)) {
      instance.isComponent = true;
      instance.$name = instance.$name.
          substring(0, instance.$name.length - _COMPONENT.length);
    } else {
      throw "Directive name '$name' must end with $_DIRECTIVE, "
            "$_ATTR_DIRECTIVE, $_COMPONENT or have a \$selector field.";
    }

    instance.isStructural = instance.$transclude;
    if (instance.isStructural) {
      instance.$priority = Directive.STRUCTURAL_PRIORITY;
    }
    if (instance.isComponent && instance.$map == null) {
      instance.$map = new Map<String, String>();
    }
    _directiveCache[type] = instance;
    return instance;
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
  String value;
  Directive directive;
  BlockFactory blockFactory;

  DirectiveRef(dom.Node this.element, Directive this.directive, [
               String this.value,
               BlockFactory this.blockFactory]) {
  }

  String toString() {
    return '{ element: ${element.outerHtml}, selector: ${directive.$name}, value: $value }';
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
