part of angular.animate;

/**
 * This provides DOM controls for turning animations on and off for individual
 * dom elements. Valid options are [always] [never] and [auto]. If this
 * directive is not applied the default value is [auto] for animation.
 */
@NgDirective(selector: '[ng-animate]', map: const {'ng-animate': '@option'})
class NgAnimateDirective  extends NgAnimateDirectiveBase {
  set option(value) {
    _option = value;

    print("Setting animate option: $value");
    _optimizer.alwaysAnimate(_element, _option);
  }

  NgAnimateDirective(dom.Element element, AnimationOptimizer optimizer)
  : super(element, optimizer);
}

/**
 * This provides DOM controls for turning animations on and off for child
 * dom elements. Valid options are [always] [never] and [auto]. If this
 * directive is not applied the default value is [auto] for animation.
 *
 * Values provided in [ng-animate] will override this directive since they are
 * more specific.
 */
@NgDirective(selector: '[ng-animate-children]',
map: const {'ng-animate-children': '@option'})
class NgAnimateChildrenDirective extends NgAnimateDirectiveBase {
  set option(value) {
    _option = value;

    print("Setting Child option: $value");
    _optimizer.alwaysAnimateChildren(_element, _option);
  }

  NgAnimateChildrenDirective(dom.Element element, AnimationOptimizer optimizer)
    : super(element, optimizer);
}

/**
 * Base class for directives that control animations with an
 * [AnimationOptimizer].
 */
abstract class NgAnimateDirectiveBase implements NgDetachAware {
  AnimationOptimizer _optimizer;
  dom.Element _element;

  String _option = "auto";
  String get option => _option;
  set option(value);

  NgAnimateDirectiveBase(this._element, this._optimizer) {
    print("CONSTRUCTING STUFF!!!");
  }

  detach() {
    _optimizer.detachAlwaysAnimateOptions(element);
  }
}