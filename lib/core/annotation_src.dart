library angular.core.annotation_src;

import "package:di/di.dart" show Injector, Visibility;

RegExp _ATTR_NAME = new RegExp(r'\[([^\]]+)\]$');

const String SHADOW_DOM_INJECTOR_NAME = 'SHADOW_INJECTOR';

skipShadow(Injector injector)
    => injector.name == SHADOW_DOM_INJECTOR_NAME ? injector.parent : injector;

localVisibility (Injector requesting, Injector defining) {
  return identical(skipShadow(requesting), defining);
}

directChildrenVisibility(Injector requesting, Injector defining) {
  requesting = skipShadow(requesting);
  return identical(requesting.parent, defining) || localVisibility(requesting, defining);
}

Directive cloneWithNewBind(Directive annotation, Map<String, String> bind)
    => annotation._cloneWithNewBind(bind);


/**
 * An annotation when applied to a class indicates that the class (service) will
 * be instantiated by di injector. This annotation is also used to designate which
 * classes need to have a static factory generated when using static angular, and
 * therefore is required on any injectable class.
 */
class Injectable {
  const Injectable();
}

/**
 * Abstract supper class of [Controller], [Component], and [Decorator].
 */
abstract class Directive {

  /// The directive can only be injected to other directives on the same element.
  static const Visibility LOCAL_VISIBILITY = localVisibility;

  /// The directive can be injected to other directives on the same or child elements.
  static const Visibility CHILDREN_VISIBILITY = null;

  /**
   * The directive on this element can only be injected to other directives
   * declared on elements which are direct children of the current element.
   */
  static const Visibility DIRECT_CHILDREN_VISIBILITY = directChildrenVisibility;

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
  @deprecated
  final String children;

  /**
   * Compile the child nodes of the element.  This is the default.
   */
  @deprecated
  static const String COMPILE_CHILDREN = 'compile';
  /**
   * Compile the child nodes for transclusion and makes available
   * [BoundViewFactory], [ViewFactory] and [ViewPort] for injection.
   */
  @deprecated
  static const String TRANSCLUDE_CHILDREN = 'transclude';
  /**
   * Do not compile/visit the child nodes.  Angular markup on descendant nodes
   * will not be processed.
   */
  @deprecated
  static const String IGNORE_CHILDREN = 'ignore';

  /**
   * A directive/component controller class can be injected into other
   * directives/components. This attribute controls whether the
   * controller is available to others.
   *
   * * `local` [Directive.LOCAL_VISIBILITY] - the controller can be injected
   *   into other directives / components on the same DOM element.
   * * `children` [Directive.CHILDREN_VISIBILITY] - the controller can be
   *   injected into other directives / components on the same or child DOM
   *   elements.
   * * `direct_children` [Directive.DIRECT_CHILDREN_VISIBILITY] - the
   *   controller can be injected into other directives / components on the
   *   direct children of the current DOM element.
   */
  final Visibility visibility;

  /**
   * A directive/component class can publish types by using a factory
   * function to generate a module. The module is then installed into
   * the injector at that element. Any types declared in the module then
   * become available for injection.
   *
   * Example:
   *
   *     @Decorator(
   *       selector: '[foo]',
   *       module: Foo.moduleFactory)
   *     class Foo {
   *       static moduleFactory() => new Module()
   *         ..bind(SomeTypeA, visibility: Directive.LOCAL_VISIBILITY);
   *     }
   *
   * When specifying types, factories or values in the module, notice that
   * `Visibility` maps to:
   *  * [Directive.LOCAL_VISIBILITY]
   *  * [Directive.CHILDREN_VISIBILITY]
   *  * [Directive.DIRECT_CHILDREN_VISIBILITY]
   */
  final Function module;

  final Map<String, String> bind;
  final Map<String, String> observe;
  final bool canChangeModel;

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

  const Directive({
    this.selector,
    this.children: Directive.COMPILE_CHILDREN,
    this.visibility: Directive.LOCAL_VISIBILITY,
    this.module,
    this.bind: const {},
    bool canChangeModel,
    this.observe: const {},
    this.exportExpressions: const [],
    this.exportExpressionAttrs: const []
  })
    : canChangeModel = canChangeModel == null ? true : canChangeModel;

  toString() => selector;
  get hashCode => selector.hashCode;
  operator==(other) =>
      other is Directive && selector == other.selector;

  Directive _cloneWithNewBind(newBind);
}


bool _applyAuthorStylesDeprecationWarningPrinted = false;
bool _resetStyleInheritanceDeprecationWarningPrinted = false;

/**
 * Meta-data marker placed on a class which should act as a controller for the
 * component. Angular components are a light-weight version of web-components.
 * Angular components use shadow-DOM for rendering their templates.
 *
 * Angular components are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Components
 * can also ask for other components or directives declared on the DOM element.
 *
 * Components can implement [AttachAware], [DetachAware],
 * [ShadowRootAware] and declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 * * `onShadowRoot(ShadowRoot shadowRoot)` - Called when [ShadowRoot] is loaded.
 */
class Component extends Directive {
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
   * Set the shadow root applyAuthorStyles property. See shadow-DOM
   * documentation for further details.
   *
   * This feature will be removed in Chrome 35.
   */
  @deprecated
  bool get applyAuthorStyles {
    if (!_applyAuthorStylesDeprecationWarningPrinted && _applyAuthorStyles == true) {
      print("WARNING applyAuthorStyles is deprecated in component $selector");
      _applyAuthorStylesDeprecationWarningPrinted = true;
    }
    return _applyAuthorStyles;
  }
  final bool _applyAuthorStyles;

  /**
   * Set the shadow root resetStyleInheritance property. See shadow-DOM
   * documentation for further details.
   *
   * This feature will be removed in Chrome 35.
   */
  @deprecated
  bool get resetStyleInheritance {
    if (!_resetStyleInheritanceDeprecationWarningPrinted && _resetStyleInheritance == true) {
      print("WARNING resetStyleInheritance is deprecated in component $selector");
      _resetStyleInheritanceDeprecationWarningPrinted = true;
    }
    return _resetStyleInheritance;
  }
  final bool _resetStyleInheritance;

  /**
   * An expression under which the component's controller instance will be
   * published into. This allows the expressions in the template to be referring
   * to controller instance and its properties.
   */
  @deprecated
  final String publishAs;

  /**
   * If set to true, this component will always use shadow DOM.
   * If set to false, this component will never use shadow DOM.
   * If unset, the compiler's default construction strategy will be used
   */
  final bool useShadowDom;

  const Component({
    this.template,
    this.templateUrl,
    cssUrl,
    applyAuthorStyles,
    resetStyleInheritance,
    this.publishAs,
    module,
    bind,
    observe,
    selector,
    canChangeModel,
    visibility,
    exportExpressions,
    exportExpressionAttrs,
    this.useShadowDom})
      : _cssUrls = cssUrl,
        _applyAuthorStyles = applyAuthorStyles,
        _resetStyleInheritance = resetStyleInheritance,
        super(selector: selector,
             children: Directive.COMPILE_CHILDREN,
             visibility: visibility,
             bind: bind,
             observe: observe,
             module: module,
             canChangeModel: canChangeModel,
             exportExpressions: exportExpressions,
             exportExpressionAttrs: exportExpressionAttrs);

  List<String> get cssUrls => _cssUrls == null ?
      const [] :
      _cssUrls is List ?  _cssUrls : [_cssUrls];

  Directive _cloneWithNewBind(newBind) =>
      new Component(
          template: template,
          templateUrl: templateUrl,
          cssUrl: cssUrls,
          applyAuthorStyles: applyAuthorStyles,
          resetStyleInheritance: resetStyleInheritance,
          publishAs: publishAs,
          bind: newBind,
          observe: observe,
          canChangeModel: canChangeModel,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs,
          useShadowDom: useShadowDom);
}

/**
 * Meta-data marker placed on a class which should act as a directive.
 *
 * Angular directives are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Directives
 * can also ask for other components or directives declared on the DOM element.
 *
 * Directives can implement [AttachAware], [DetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
class Decorator extends Directive {
  const Decorator({children: Directive.COMPILE_CHILDREN,
                    bind,
                    observe,
                    selector,
                    module,
                    canChangeModel,
                    visibility,
                    exportExpressions,
                    exportExpressionAttrs})
      : super(selector: selector,
              children: children,
              visibility: visibility,
              bind: bind,
              observe: observe,
              canChangeModel: canChangeModel,
              module: module,
              exportExpressions: exportExpressions,
              exportExpressionAttrs: exportExpressionAttrs);

  Directive _cloneWithNewBind(newBind) =>
      new Decorator(
          children: children,
          bind: newBind,
          observe: observe,
          canChangeModel: canChangeModel,
          module: module,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs);
}

/**
 * Meta-data marker placed on a class which should act as a controller for your
 * application.
 *
 * Controllers are essentially [Decorator]s with few key differences:
 *
 * * Controllers create a new scope at the element.
 * * Controllers should not do any DOM manipulation.
 * * Controllers are meant for application-logic
 *   (rather then DOM manipulation logic which directives are meant for.)
 *
 * Controllers can implement [AttachAware], [DetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.apply()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
@deprecated
class Controller extends Decorator {
  /**
   * An expression under which the controller instance will be published into.
   * This allows the expressions in the template to be referring to controller
   * instance and its properties.
   */
  final String publishAs;

  const Controller({
                    children: Directive.COMPILE_CHILDREN,
                    this.publishAs,
                    bind,
                    observe,
                    module,
                    selector,
                    canChangeModel,
                    visibility,
                    exportExpressions,
                    exportExpressionAttrs
                    })
      : super(selector: selector,
              children: children,
              visibility: visibility,
              bind: bind,
              observe: observe,
              canChangeModel: canChangeModel,
              module: module,
              exportExpressions: exportExpressions,
              exportExpressionAttrs: exportExpressionAttrs);

  Directive _cloneWithNewBind(newBind) =>
      new Controller(
          children: children,
          publishAs: publishAs,
          module: module,
          bind: newBind,
          canChangeModel: canChangeModel,
          observe: observe,
          selector: selector,
          visibility: visibility,
          exportExpressions: exportExpressions,
          exportExpressionAttrs: exportExpressionAttrs);
}

/**
 */
class Bind {
  final String nodeProperty;
  const Bind([this.nodeProperty = null]);
}

/**
 * A directives or components may chose to implements [AttachAware].[attach] method.
 * If implemented the method will be called when the next scope digest occurs after
 * component instantiation. It is guaranteed that when [attach] is invoked, that all
 * attribute mappings have already been processed.
 */
abstract class AttachAware {
  void attach();
}

/**
 * A directives or components may chose to implements [DetachAware].[detach] method.
 * If implemented the method will be called when the next associated scope is destroyed.
 */
abstract class DetachAware {
  void detach();
}

/**
 * Use @[Formatter] annotation to register a new formatter. A formatter is a class
 * with a [call] method (a callable function).
 *
 * Usage:
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
class Formatter {
  final String name;

  const Formatter({this.name});

  int get hashCode => name.hashCode;
  bool operator==(other) => name == other.name;

  toString() => 'Formatter: $name';
}
