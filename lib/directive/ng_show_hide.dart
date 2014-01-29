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

  NgHideDirective(this.element);

  set hide(value) {
    if (toBool(value)) {
      element.classes.add(NG_HIDE_CLASS);
    } else {
      element.classes.remove(NG_HIDE_CLASS);
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
  static String NG_SHOW_CLASS = 'ng-show';

  final dom.Element element;

  NgShowDirective(this.element);

  set show(value) {
    if (toBool(value)) {
      element.classes.add(NG_SHOW_CLASS);
    } else {
      element.classes.remove(NG_SHOW_CLASS);
    }
  }
}

