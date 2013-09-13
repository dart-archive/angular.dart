library angular.directive.ng_cloak;

import "dart:html" as dom;
import "../dom/directive.dart";


@NgDirective(
    selector: '[ng-cloak]'
)
class NgCloakAttrDirective {
  NgCloakAttrDirective(dom.Element element) {
    element.attributes.remove('ng-cloak');
  }
}
