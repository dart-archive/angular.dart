library angular.core.annotation_src;

import "package:di/di.dart" show Injector, Visibility, Factory;
import "package:di/annotations.dart" show Injectable;

/**
 * An implementation of [DirectiveBinder] is provided by the framework
 * to [Directive.module]. The provided [DirectiveBinder] can be used
 * to publish types that will become available for injection.
 */
abstract class DirectiveBinder {
 void bind(key, {dynamic toValue,
                 Function toFactory,
                 Type toImplementation,
                 toInstanceOf,
                 inject: const[],
                 Visibility visibility: Visibility.LOCAL});
}

/**
 * A [DirectiveBinderFn] function can be assigned to the [Directive.module] property.
 * The function is called with an implementation of [DirectiveBinder], which
 * can be used to publish types that will become available for injection.
 */
typedef void DirectiveBinderFn(DirectiveBinder binder);

RegExp _ATTR_NAME = new RegExp(r'\[([^\]]+)\]$');

Directive cloneWithNewMap(Directive annotation, map) => annotation._cloneWithNewMap(map);

String mappingSpec(DirectiveAnnotation annotation) => annotation._mappingSpec;

/**
 * This annotation sets the injection permissions of a given directive.
 * Using [DIRECT_CHILDREN], [CHILDREN], or [LOCAL] you can decide whether your directive
 * can be injected by directives living on DOM children, direcives living on indirect DOM children
 * (ancestors) or other directives living on the same element.
 */
class Visibility {
  /// The directive can only be injected to other directives on the same element.
  static const LOCAL = const Visibility._('LOCAL');
  /// The directive can be injected to other directives on the same or child elements.
  static const CHILDREN = const Visibility._('CHILDREN');
  /// The directive on this element can only be injected to other directives
  /// declared on elements which are direct children of the current element.
  static const DIRECT_CHILD = const Visibility._('DIRECT_CHILD');

  final String name;
  const Visibility._(this.name);
  String toString() => 'Visibility: $name';
}

/**
 * Abstract super class of [Component], and [Decorator].
 */
abstract class Directive implements Injectable {

  /// The directive can only be injected to other directives on the same element.
  @Deprecated('Use Visibility.LOCAL instead')
  static const Visibility LOCAL_VISIBILITY = Visibility.LOCAL;

  /// The directive can be injected to other directives on the same or child elements.
  @Deprecated('Use Visibility.CHILDREN instead')
  static const Visibility CHILDREN_VISIBILITY = Visibility.CHILDREN;

  /**
   * The directive on this element can only be injected to other directives
   * declared on elements which are direct children of the current element.
   */
  @Deprecated('Use Visibility.DIRECT_CHILD instead')
  static const Visibility DIRECT_CHILDREN_VISIBILITY = Visibility.DIRECT_CHILD;

  /**
   * CSS selector which will trigger this component/directive.
   * CSS Selectors are limited to a single element and can contain:
   *
   * * `element-name` limit to a given element name.
   * * `.class` limit to an element with a given class.
   * * `[attribute]` limit to an element with a given attribute name.
   * * `[attribute=value]` limit to an element with a given attribute and value.
   * * `:contains(/abc/)` limit to an element which contains the given text.
   *
   *
   * Example: `input[type=checkbox][ng-model]`
   */
  final String selector;

  /**
   * Specifies the compiler action to be taken on the child nodes of the
   * element which this currently being compiled.  The values are:
   *
   * * [COMPILE_CHILDREN] (*default*)
   * * [TRANSCLUDE_CHILDREN]
   * * [IGNORE_CHILDREN]
   */
  final String children;

  /**
   * Compile the child nodes of the element. This is the default.
   */
  static const String COMPILE_CHILDREN = 'compile';
  /**
   * Compile the child nodes for transclusion and makes available
   * [BoundViewFactory], [ViewFactory] and [ViewPort] for injection.
   */
  static const String TRANSCLUDE_CHILDREN = 'transclude';
  /**
   * Do not compile/visit the child nodes. Angular markup on descendant nodes
   * will not be processed.
   */
  static const String IGNORE_CHILDREN = 'ignore';

  /**
   * A directive class can be injected into other directives. This attribute controls whether the
   * directive is available to others.
   *
   * * [Visibility.LOCAL] - the directive can be injected into other directives on the same DOM
   *   element.
   * * [Visibility.CHILDREN] - the directive can be injected into other directives on the same or
   *   child DOM elements (*default*).
   * * [Visibility.DIRECT_CHILD] - the directive can be injected into other directives on the direct
   *   children of the current DOM element.
   */
  final Visibility visibility;

  /**
   * A directive/component class can publish types by using a factory function to generate a module.
   * The module is then installed into the injector at that element. Any types declared in the
   * module then become available for injection.
   *
   * Example:
   *
   *     @Decorator(
   *       selector: '[foo]',
   *       module: Foo.moduleFactory)
   *     class Foo {
   *       static moduleFactory(DirectiveBinder binder) =>
   *          binder.bind(SomeTypeA, visibility: Visibility.LOCAL);
   *     }
   *
   * `visibility` is one of:
   *  * [Visibility.LOCAL]
   *  * [Visibility.CHILDREN] (default)
   *  * [Visibility.DIRECT_CHILD]
   */
  final DirectiveBinderFn module;

  /**
   * Use map to define the mapping of  DOM attributes to fields.
   * The map's key is the DOM attribute name (DOM attribute is in dash-case).
   * The Map's value consists of a mode prefix followed by an expression.
   * The destination expression will be evaluated against the instance of the
   * directive / component class.
   *
   * * `@` - Map the DOM attribute string. The attribute string will be taken
   *   literally or interpolated if it contains binding {{}} systax and assigned
   *   to the expression. (cost: 0 watches)
   *
   * * `=>` - Treat the DOM attribute value as an expression. Set up a watch,
   *   which will read the expression in the attribute and assign the value
   *   to destination expression. (cost: 1 watch)
   *
   * * `<=>` - Treat the DOM attribute value as an expression. Set up a watch
   *   on both outside as well as component scope to keep the src and
   *   destination in sync. (cost: 2 watches)
   *
   * * `=>!` - Treat the DOM attribute value as an expression. Set up a one time
   *   watch on expression. Once the expression turns truthy it will no longer
   *   update. (cost: 1 watches until not null, then 0 watches)
   *
   * * `&` - Treat the DOM attribute value as an expression. Assign a closure
   *   function into the field. This allows the component to control
   *   the invocation of the closure. This is useful for passing
   *   expressions into controllers which act like callbacks. (cost: 0 watches)
   *
   * Example:
   *
   *     <my-component title="Hello {{username}}"
   *                   selection="selectedItem"
   *                   on-selection-change="doSomething()">
   *
   *     @Component(
   *       selector: 'my-component'
   *       map: const {
   *         'title': '@title',
   *         'selection': '<=>currentItem',
   *         'on-selection-change': '&onChange'})
   *     class MyComponent {
   *       String title;
   *       var currentItem;
   *       ParsedFn onChange;
   *     }
   *
   *  The above example shows how all three mapping modes are used.
   *
   *  * `@title` maps the title DOM attribute to the controller `title`
   *    field. Notice that this maps the content of the attribute, which
   *    means that it can be used with `{{}}` interpolation.
   *
   *  * `<=>currentItem` maps the expression (in this case the `selectedItem`
   *    in the current scope into the `currentItem` in the controller. Notice
   *    that mapping is bi-directional. A change either in field or on
   *    parent scope will result in change to the other.
   *
   *  * `&onChange` maps the expression into the controller `onChange`
   *    field. The result of mapping is a callable function which can be
   *    invoked at any time by the controller. The invocation of the
   *    callable function will result in the expression `doSomething()` to
   *    be executed in the parent context.
   */
  final Map<String, String> map;

  /**
   * Use the list to specify expressions containing attributes which are not
   * included under [map] with '=' or '@' specification. This is used by
   * angular transformer during deployment.
   */
  final List<String> exportExpressionAttrs;

  /**
   * Use the list to specify expressions which are evaluated dynamically
   * (ex. via [Scope.eval]) and are otherwise not statically discoverable.
   * This is used by angular transformer during deployment.
   */
  final List<String> exportExpressions;

  /**
   * Event names to listen to during Web Component two-way binding.
   *
   * To support web components efficiently, Angular only reads element
   * bindings when specific events are fired.  By default, Angular listens
   * to 'change'.  Adding events names to this listen will cause Angular
   * to listen to those events instead.
   *
   * The name is intentionally long: this should be rarely used and therefore
   * it is important that it is self-documenting.
   */
  final List<String> updateBoundElementPropertiesOnEvents;

  const Directive({
    this.selector,
    this.children,
    this.visibility,
    this.module,
    this.map: const {},
    this.exportExpressions: const [],
    this.exportExpressionAttrs: const [],
    this.updateBoundElementPropertiesOnEvents
  });

  String toString() => selector;
  Directive _cloneWithNewMap(newMap);
}

/**
 * Annotation placed on a class which should act as a controller for the
 * component. Angular components are a light-weight version of web-components.
 * Angular components use shadow-DOM for rendering their templates.
 *
 * Angular components are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Components
 * can also ask for other components or decorators declared on the DOM element.
 *
 * Components can implement [AttachAware], [DetachAware],
 * [ShadowRootAware], [ScopeAware](#angular/angular-core.ScopeAware) and declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 * * `onShadowRoot(ShadowRoot shadowRoot)` - Called when
 * [ShadowRoot](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-dom-html.ShadowRoot) is loaded.
 * * `set scope(Scope scope)` - Called right after construction with the component scope.
 */
class Component extends Directive {
  /**
   * This property is left here for backward compatibility, but it is not required.
   *
   * Before:
   *
   *     @Component(publishAs: 'ctrl', ...)
   *     class MyComponent {
   *       // ...
   *     }
   *
   *    in component template:  {{ctrl.foo}}
   *
   * After:
   *
   *    @Component(publishAs: 'ctrl', ...)
   *     class MyComponent {
   *       // You must add a getter named after the publishAs configuration
   *       MyComponent get ctrl => this;
   *
   *       // ...
   *     }
   *
   * Finally:
   *
   *    @Component()
   *    class MyComponent {}
   *
   *    in component template:  {{foo}}
   */
  @Deprecated('next release. This property is left for backward compatibility but setting it has no'
              ' effect.')
  final String publishAs;

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
   * A list of CSS URLs to load into the shadow DOM.
   */
  final _cssUrls;

  /**
   * If set to true, this component will always use shadow DOM.
   * If set to false, this component will never use shadow DOM.
   * If unset, the compiler's default construction strategy will be used
   */
  final bool useShadowDom;

  /**
   * Defaults to true, but if set to false any NgBaseCss stylesheets will be ignored.
   */
  final bool useNgBaseCss;

  const Component({
    this.template,
    this.templateUrl,
    cssUrl,
    DirectiveBinderFn module,
    map,
    selector,
    visibility,
    exportExpressions,
    exportExpressionAttrs,
    this.useShadowDom,
    this.useNgBaseCss: true,
    updateBoundElementPropertiesOnEvents,
    this.publishAs
  }) : _cssUrls = cssUrl,
        super(selector: selector,
             children: Directive.COMPILE_CHILDREN,
             visibility: visibility,
             map: map,
             module: module,
             exportExpressions: exportExpressions,
             exportExpressionAttrs: exportExpressionAttrs,
             updateBoundElementPropertiesOnEvents: updateBoundElementPropertiesOnEvents);

  List<String> get cssUrls => _cssUrls == null ?
      const [] :
      _cssUrls is List ?  _cssUrls : [_cssUrls];

  Directive _cloneWithNewMap(newMap) =>
      new Component(
          template: template,
          templateUrl: templateUrl,
          cssUrl: cssUrls,
          map: newMap,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs,
          useShadowDom: useShadowDom,
          useNgBaseCss: useNgBaseCss,
          updateBoundElementPropertiesOnEvents: updateBoundElementPropertiesOnEvents,
          publishAs: publishAs);
}

/**
 * Annotation placed on a class which should act as a decorator.
 *
 * Angular decorators are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Decorators
 * can also ask for other components or decorators declared on the DOM element.
 *
 * Decorators can implement [AttachAware], [DetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 * * `set scope(Scope scope)` - Called right after construction with the owning scope.
 */
class Decorator extends Directive {
  const Decorator({children: Directive.COMPILE_CHILDREN,
                    map,
                    selector,
                    DirectiveBinderFn module,
                    visibility,
                    exportExpressions,
                    exportExpressionAttrs,
                    updateBoundElementPropertiesOnEvents})
      : super(selector: selector,
              children: children,
              visibility: visibility,
              map: map,
              module: module,
              exportExpressions: exportExpressions,
              exportExpressionAttrs: exportExpressionAttrs,
              updateBoundElementPropertiesOnEvents: updateBoundElementPropertiesOnEvents);

  Directive _cloneWithNewMap(newMap) =>
      new Decorator(
          children: children,
          map: newMap,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs,
          updateBoundElementPropertiesOnEvents: updateBoundElementPropertiesOnEvents);
}

/**
 * Abstract super class of [NgAttr], [NgCallback], [NgOneWay], [NgOneWayOneTime], and [NgTwoWay].
 */
abstract class DirectiveAnnotation {
  /// Element attribute name
  final String attrName;
  const DirectiveAnnotation(this.attrName);
  /// Element attribute mapping mode: `@`, `=>`, `=>!`, `<=>`, and `&`.
  String get _mappingSpec;
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to a DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a string, equivalent
 * to `@` specification.
 */
class NgAttr extends DirectiveAnnotation {
  final _mappingSpec = '@';
  const NgAttr(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to a DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a one-way expression, equivalent
 * to `=>` specification.
 */
class NgOneWay extends DirectiveAnnotation {
  final _mappingSpec = '=>';
  const NgOneWay(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a one time one-way expression,
 * equivalent to `=>!` specification.
 */
class NgOneWayOneTime extends DirectiveAnnotation {
  final _mappingSpec = '=>!';
  const NgOneWayOneTime(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to a DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a two-way expression,
 * equivalent to `<=>` specification.
 */
class NgTwoWay extends DirectiveAnnotation {
  final _mappingSpec = '<=>';
  const NgTwoWay(String attrName) : super(attrName);
}

/**
 * When applied as an annotation on a directive field specifies that
 * the field is to be mapped to a DOM attribute with the provided [attrName].
 * The value of the attribute to be treated as a callback expression,
 * equivalent to `&` specification.
 */
class NgCallback extends DirectiveAnnotation {
  final _mappingSpec = '&';
  const NgCallback(String attrName) : super(attrName);
}

/**
 * A decorator or a component may choose to implement the [AttachAware].[attach] method.
 * If implemented, the method will be called when the next scope digest occurs after
 * component instantiation. It is guaranteed that when [attach] is invoked, all
 * attribute mappings have already been processed.
 */
abstract class AttachAware {
  void attach();
}

/**
 * A decorator or a component may choose to implement the [DetachAware].[detach] method.
 * If implemented, the method will be called when the next associated scope is destroyed.
 */
abstract class DetachAware {
  void detach();
}

/**
 * Use the @[Formatter] class annotation to identify a class as a formatter.
 *
 * A formatter is a pure function that performs a transformation on input data from an expression.
 * For more on formatters in Angular, see the documentation for the
 * [angular:formatter](#angular-formatter) library.
 *
 * A formatter class must have a call method with at least one parameter, which specifies the value
 * to format. Any additional parameters are treated as arguments of the formatter.
 *
 * **Usage**
 *
 *     // Declaration
 *     @Formatter(name:'myFormatter')
 *     class MyFormatter {
 *       call(valueToFormat, optArg1, optArg2) {
 *          return ...;
 *       }
 *     }
 *
 *
 *     // Registration
 *     var module = ...;
 *     module.bind(MyFormatter);
 *
 *
 *     <!-- Usage -->
 *     <span>{{something | myFormatter:arg1:arg2}}</span>
 */
class Formatter implements Injectable {
  final String name;

  const Formatter({this.name});

  String toString() => 'Formatter: $name';
}
