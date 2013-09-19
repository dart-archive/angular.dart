library angular.directive.ng_show;

import 'dart:html' as dom;
import '../dom/directive.dart';
import '../utils.dart';

@NgDirective(
    selector: '[ng-show]',
    map: const {'ng-show': '=.show'})
class NgShowAttrDirective {
  static String NG_SHOW_CLASS = 'ng-show';

  dom.Element element;

  NgShowAttrDirective(dom.Element this.element);

  set show(value) {
    if (toBool(value)) {
      element.classes.add(NG_SHOW_CLASS);
    } else {
      element.classes.remove(NG_SHOW_CLASS);
    }
  }
}
