library angular.directive.ng_bind;

import 'dart:html' as dom;
import '../angular.dart';

@NgDirective(
  selector: '[ng-bind]',
  map: const {'ng-bind': '=.value'})
class NgBindAttrDirective {
  dom.Element element;

  NgBindAttrDirective(dom.Element this.element);

  set value(value) => element.text = value == null ? '' : value.toString();
}
