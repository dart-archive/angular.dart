part of angular.directive;

/**
 * Shows or hides the given HTML element based on an expression. The element is shown or hidden
 * by removing or adding the `NgHide` CSS class onto the element. `Selector: [ng-hide]`
 */
@Decorator(
    selector: '[ng-hide]',
    map: const {'ng-hide': '=>hide'})
class NgHide {
  static String NG_HIDE_CLASS = 'ng-hide';

  final dom.Element element;
  final Animate animate;

  NgHide(this.element, this.animate);

  set hide(value) {
    if (toBool(value)) {
      animate.addClass(element, NG_HIDE_CLASS);
    } else {
      animate.removeClass(element, NG_HIDE_CLASS);
    }
  }
}

/**
 * Shows or hides the given HTML element based on an expression. The element is shown or hidden
 * by changing the removing or adding the `NgHide` CSS class onto the element. `Selector: [ng-show]`
 */
@Decorator(
    selector: '[ng-show]',
    map: const {'ng-show': '=>show'})
class NgShow {
  final dom.Element element;
  final Animate animate;

  NgShow(this.element, this.animate);

  set show(value) {
    if (toBool(value)) {
      animate.removeClass(element, NgHide.NG_HIDE_CLASS);
    } else {
      animate.addClass(element, NgHide.NG_HIDE_CLASS);
    }
  }
}

