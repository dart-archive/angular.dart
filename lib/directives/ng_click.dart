library angular.directive.ng_click;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../scope.dart";

@NgDirective(
    selector: '[ng-click]',
    map: const {'ng-click': '&.onClick'}
)
class NgClickAttrDirective {
  Function onClick;

  NgClickAttrDirective(dom.Element element, Scope scope) {
    element.onClick.listen((event) => scope.$apply(() {
      onClick({r"$event": event});
    }));
  }
}
