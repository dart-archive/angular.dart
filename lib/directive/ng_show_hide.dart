part of angular.directive;

/**
 * The ngHide directive shows or hides the given HTML element based on the
 * expression provided to the ngHide attribute. The element is shown or hidden
 * by changing the removing or adding the ng-hide CSS class onto the element.
 */
@NgDirective(
    selector: '[ng-hide]',
    map: const {'ng-hide': '=>hide'})
class NgHideDirective {
  static String NG_HIDE_CLASS = 'ng-hide';

  final dom.Element element;
  final NgAnimate animate;

  NgHideDirective(this.element, this.animate);

  set hide(value) {
    if (toBool(value)) {
      animate.addClass(element, NG_HIDE_CLASS);
    } else {
      animate.removeClass(element, NG_HIDE_CLASS);
    }
  }
}

/**
 * The ngShow directive shows or hides the given HTML element based on the
 * expression provided to the ngHide attribute. The element is shown or hidden
 * by changing the removing or adding the ng-hide CSS class onto the element.
 */
@NgDirective(
    selector: '[ng-show]',
    map: const {'ng-show': '=>show'})
class NgShowDirective {
  final dom.Element element;
  final NgAnimate animate;

  NgShowDirective(this.element, this.animate);

  set show(value) {
    if (toBool(value)) {
      animate.removeClass(element, NgHideDirective.NG_HIDE_CLASS);
    } else {
      animate.addClass(element, NgHideDirective.NG_HIDE_CLASS);
    }
  }
}

