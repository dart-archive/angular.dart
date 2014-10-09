library angular.core.aware_interface;

import "dart:html" show ShadowRoot;

/**
 * Implementing components [onShadowRoot] method will be called when
 * the template for the component has been loaded and inserted into Shadow DOM.
 * It is guaranteed that when [onShadowRoot] is invoked, that shadow DOM
 * has been loaded and is ready.
 */
abstract class ShadowRootAware {
  void onShadowRoot(ShadowRoot shadowRoot);
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
 * When a [Directive] or the root context class implements [ScopeAware] the scope
 * setter will be called to set the [Scope] on this component.
 *
 * The order of calls is as follows:
 * - [Component] instance is created.
 * - [Scope] instance is created (taking [Component] instance as evaluation context).
 * - if [Component] is [ScopeAware], set scope method is called with scope instance.
 *
 * [ScopeAware] is guaranteed to be called before [AttachAware] or [DetachAware] methods.
 *
 * Example:
 *     @Component(...)
 *     class MyComponent implements ScopeAware {
 *       Watch watch;
 *
 *       MyComponent(Dependency myDep) {
 *         // It is an error to add a Scope argument to the ctor and will result in a DI
 *         // circular dependency error - the scope has a dependency on the component instance.
 *       }
 *
 *       void set scope(Scope scope) {
 *          // This setter gets called to initialize the scope
 *          watch = scope.watch("expression", (v, p) => ...);
 *       }
 *     }
 */
abstract class ScopeAware {
  void set scope(Scope scope);
}