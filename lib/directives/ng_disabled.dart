library angular.directive.ng_disabled;

import 'dart:html' as dom;
import '../dom/directive.dart';
import '../utils.dart';

@NgDirective(
    selector: '[ng-disabled]',
    map: const {'ng-disabled': '=.disabled'})
class NgDisabledAttrDirective {
  dom.Element element;

  NgDisabledAttrDirective(dom.Element this.element);

  // TODO: should be if (understands(element, #disabled)) ...
  set disabled(value) => (element as dynamic).disabled = toBool(value);
}
