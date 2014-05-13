part of angular.directive;

/**
 * The ngHide directive shows or hides the given HTML element based on the
 * expression provided to the ngHide attribute. The element is shown or hidden
 * by changing the removing or adding the ng-hide CSS class onto the element.
 */
@Decorator(
    selector: '[ng-hide]',
    canChangeModel: false,
    bind: const {'ngHide': 'hide'})
class NgHide {
  static String NG_HIDE_CLASS = 'ng-hide';

  final dom.Element element;
  final Animate animate;

  NgHide(this.element, this.animate);

  set hide(value) {
    if (toBool(value)) {
      element.addClass(NgHide.NG_HIDE_CLASS);
    } else {
      element.removeClass(NgHide.NG_HIDE_CLASS);
    }
  }
}

/**
 * The ngShow directive shows or hides the given HTML element based on the
 * expression provided to the ngHide attribute. The element is shown or hidden
 * by changing the removing or adding the ng-hide CSS class onto the element.
 */
@Decorator(
    selector: '[ng-show]',
    canChangeModel: false,
    bind: const {'ngShow': 'show'})
class NgShow {
  final NgElement element;

  NgShow(this.element);

  set show(value) {
    if (toBool(value)) {
      element.removeClass(NgHide.NG_HIDE_CLASS);
    } else {
      element.addClass(NgHide.NG_HIDE_CLASS);
    }
  }
}

