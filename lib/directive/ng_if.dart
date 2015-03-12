part of angular.directive;

/**
 * Base class for NgIf and NgUnless.
 */
abstract class _NgUnlessIfAttrDirectiveBase {
  final ViewFactory _viewFactory;
  final ViewPort _viewPort;
  final Scope _scope;

  View _view;

  _NgUnlessIfAttrDirectiveBase(this._viewFactory, this._viewPort, this._scope) {
    assert(_viewFactory != null);
  }

  // Override in subclass.
  void set condition(value);

  void _ensureViewExists() {
    if (_view == null) {
      _view = _viewPort.insertNew(_viewFactory);
    }
  }

  void _ensureViewDestroyed() {
    if (_view != null) {
      _viewPort.remove(_view);
      _view = null;
    }
  }
}


/**
 * Removes or inserts a subtree from the DOM based on whether a provided
 * expression is true or false. `Selector: [ng-if]`
 *
 * Specifically, if the expression assigned to `ng-if` evaluates to a `false`
 * value, then the subtree is removed from the DOM.  Otherwise, a clone of the
 * subtree is reinserted into the DOM.  This clone is created from the compiled
 * state.  As such, modifications made to the element after compilation (e.g.
 * changing the `class`) are lost when the element is destroyed.
 *
 * Whenever the subtree is inserted into the DOM, it always gets a new child
 * scope.  This child scope is destroyed when the subtree is removed from the
 * DOM.  Refer
 * https://github.com/angular/angular.js/wiki/The-Nuances-of-Scope-prototypical-Inheritance prototypical inheritance
 *
 * This has an important implication when `ng-model` is used inside an `ng-if`
 * to bind to a javascript primitive defined in the parent scope.  In such a
 * situation, any modifications made to the variable in the `ng-if` subtree will
 * be made on the child scope and override (hide) the value in the parent scope.
 * The parent scope will remain unchanged by changes affected by this subtree.
 *
 * Note: `ng-if` differs from `ng-show` and `ng-hide` in that `ng-if` completely
 * removes and recreates the element in the DOM rather than changing its
 * visibility via the `display` css property.  A common case when this
 * difference is significant is when using css selectors that rely on an
 * element's position within the DOM (HTML), such as the `:first-child` or
 * `:last-child` pseudo-classes.
 *
 * Example:
 *
 *     <!-- By using ng-if instead of ng-show, we avoid the cost of the showdown
 *          formatter, the repeater, etc. -->
 *     <div ng-if="showDetails">
 *        {{obj.details.markdownText | showdown}}
 *        <div ng-repeat="item in obj.details.items">
 *          ...
 *        </div>
 *     </div>
 */
@Decorator(
    children: Directive.TRANSCLUDE_CHILDREN,
    selector:'[ng-if]',
    map: const {'.': '=>condition'})
class NgIf extends _NgUnlessIfAttrDirectiveBase {
  NgIf(ViewFactory viewFactory, ViewPort viewPort, Scope scope)
      : super(viewFactory, viewPort, scope);

  void set condition(value) {
    if (toBool(value)) {
      _ensureViewExists();
    } else {
      _ensureViewDestroyed();
    }
  }
}


/**
 * Recreates or destroys the DOM subtree containing a directive based on whether a provided
 * expression is true or false. `Selector: [ng-unless]`
 *
 * Specifically, if the expression assigned to `ng-unless` evaluates to a `true`
 * value, then the subtree is removed from the DOM.  Otherwise, a clone of the
 * subtree is reinserted into the DOM.  This clone is created from the compiled
 * state.  As such, modifications made to the element after compilation (e.g.
 * changing the `class`) are lost when the element is destroyed.
 *
 * Whenever the subtree is inserted into the DOM, it always gets a new child
 * scope.  This child scope is destroyed when the subtree is removed from the
 * DOM.  Refer
 * https://github.com/angular/angular.js/wiki/The-Nuances-of-Scope-prototypical-Inheritance prototypical inheritance
 *
 * This has an important implication when `ng-model` is used inside an
 * `ng-unless` to bind to a javascript primitive defined in the parent scope.
 * In such a situation, any modifications made to the variable in the
 * `ng-unless` subtree will be made on the child scope and override (hide) the
 * value in the parent scope.  The parent scope will remain unchanged by changes
 * affected by this subtree.
 *
 * Note: `ng-unless` differs from `ng-show` and `ng-hide` in that `ng-unless`
 * completely removes and recreates the element in the DOM rather than changing
 * its visibility via the `display` css property.  A common case when this
 * difference is significant is when using css selectors that rely on an
 * element's position within the DOM (HTML), such as the `:first-child` or
 * `:last-child` pseudo-classes.
 *
 * Example:
 *
 *     <!-- By using ng-unless instead of ng-show, we avoid the cost of the
 *          showdown formatter, the repeater, etc. -->
 *     <div ng-unless="terseView">
 *        {{obj.details.markdownText | showdown}}
 *        <div ng-repeat="item in obj.details.items">
 *          ...
 *        </div>
 *     </div>
 */
@Decorator(
    children: Directive.TRANSCLUDE_CHILDREN,
    selector:'[ng-unless]',
    map: const {'.': '=>condition'})
class NgUnless extends _NgUnlessIfAttrDirectiveBase {

  NgUnless(ViewFactory viewFactory, ViewPort viewPort, Scope scope)
      : super(viewFactory, viewPort, scope);

  void set condition(value) {
    if (!toBool(value)) {
      _ensureViewExists();
    } else {
      _ensureViewDestroyed();
    }
  }
}
