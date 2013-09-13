library angular.directive.ng_hide;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../utils.dart";


@NgDirective(
    selector: '[ng-hide]',
    map: const {'ng-hide': '=.hide'} )
class NgHideAttrDirective {
  static String NG_HIDE_CLASS = 'ng-hide';

  dom.Element element;

  NgHideAttrDirective(dom.Element this.element);

  set hide(value) {
    if (toBool(value)) {
      element.classes.add(NG_HIDE_CLASS);
    } else {
      element.classes.remove(NG_HIDE_CLASS);
    }
  }
}
