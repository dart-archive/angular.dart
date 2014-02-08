part of angular.directive;

/**
 * Base class for NgIfAttrDirective and NgUnlessAttrDirective.
 */
abstract class _NgUnlessIfAttrDirectiveBase {
  final BoundBlockFactory _boundBlockFactory;
  final BlockHole _blockHole;
  final Scope _scope;

  Block _block;

  /**
   * The new child scope.  This child scope is recreated whenever the `ng-if`
   * subtree is inserted into the DOM and destroyed when it's removed from the
   * DOM.  Refer
   * https://github.com/angular/angular.js/wiki/The-Nuances-of-Scope-Prototypal-Inheritance prototypal inheritance
   */
  Scope _childScope;

  _NgUnlessIfAttrDirectiveBase(this._boundBlockFactory, this._blockHole,
                               this._scope);

  // Override in subclass.
  set condition(value);

  void _ensureBlockExists() {
    if (_block == null) {
      _childScope = _scope.$new();
      _block = _boundBlockFactory(_childScope);
      _block.insertAfter(_blockHole);
    }
  }

  void _ensureBlockDestroyed() {
    if (_block != null) {
      _block.remove();
      _childScope.$destroy();
      _block = null;
      _childScope = null;
    }
  }
}


/**
 * The `ng-if` directive compliments the `ng-unless` (provided by
 * [NgUnlessAttrDirective]) directive.
 *
 * directive based on the **truthy/falsy** value of the provided expression.
 * Specifically, if the expression assigned to `ng-if` evaluates to a `false`
 * value, then the subtree is removed from the DOM.  Otherwise, *a clone of the
 * subtree* is reinserted into the DOM.  This clone is created from the compiled
 * state.  As such, modifications made to the element after compilation (e.g.
 * changing the `class`) are lost when the element is destroyed.
 *
 * Whenever the subtree is inserted into the DOM, it always gets a new child
 * scope.  This child scope is destroyed when the subtree is removed from the
 * DOM.  Refer
 * https://github.com/angular/angular.js/wiki/The-Nuances-of-Scope-Prototypal-Inheritance prototypal inheritance
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
 *          filter, the repeater, etc. -->
 *     <div ng-if="showDetails">
 *        {{obj.details.markdownText | showdown}}
 *        <div ng-repeat="item in obj.details.items">
 *          ...
 *        </div>
 *     </div>
 */
@NgDirective(
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    selector:'[ng-if]',
    map: const {'.': '=>condition'})
class NgIfDirective extends _NgUnlessIfAttrDirectiveBase {
  NgIfDirective(BoundBlockFactory boundBlockFactory,
                BlockHole blockHole,
                Scope scope): super(boundBlockFactory, blockHole, scope);

  set condition(value) {
    if (toBool(value)) {
      _ensureBlockExists();
    } else {
      _ensureBlockDestroyed();
    }
  }
}


/**
 * The `ng-unless` directive compliments the `ng-if` (provided by
 * [NgIfAttrDirective]) directive.
 *
 * The `ng-unless` directive recreates/destroys the DOM subtree containing the
 * directive based on the **falsy/truthy** value of the provided expression.
 * Specifically, if the expression assigned to `ng-unless` evaluates to a `true`
 * value, then the subtree is removed from the DOM.  Otherwise, *a clone of the
 * subtree* is reinserted into the DOM.  This clone is created from the compiled
 * state.  As such, modifications made to the element after compilation (e.g.
 * changing the `class`) are lost when the element is destroyed.
 *
 * Whenever the subtree is inserted into the DOM, it always gets a new child
 * scope.  This child scope is destroyed when the subtree is removed from the
 * DOM.  Refer
 * https://github.com/angular/angular.js/wiki/The-Nuances-of-Scope-Prototypal-Inheritance prototypal inheritance
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
 *     <!-- By using ng-unless instead of ng-show, we avoid the cost of the showdown
 *          filter, the repeater, etc. -->
 *     <div ng-unless="terseView">
 *        {{obj.details.markdownText | showdown}}
 *        <div ng-repeat="item in obj.details.items">
 *          ...
 *        </div>
 *     </div>
 */
@NgDirective(
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    selector:'[ng-unless]',
    map: const {'.': '=>condition'})
class NgUnlessDirective extends _NgUnlessIfAttrDirectiveBase {

  NgUnlessDirective(BoundBlockFactory boundBlockFactory,
                    BlockHole blockHole,
                    Scope scope): super(boundBlockFactory, blockHole, scope);

  set condition(value) {
    if (!toBool(value)) {
      _ensureBlockExists();
    } else {
      _ensureBlockDestroyed();
    }
  }
}
