library angular.directive.ng_class;

import "dart:html" as dom;
import "../dom/directive.dart";

@NgDirective(
    selector: '[ng-class]',
    map: const {'ng-class': '=.value'})
class NgClassAttrDirective {
  dom.Element element;
  var previousSet = [];

  NgClassAttrDirective(dom.Element this.element);

  set value(current) {
    var currentSet;

    if (current == null) {
      currentSet = [];
    } else {
      currentSet = current.split(' ');
    }

    previousSet.forEach((cls) {
      if (!currentSet.contains(cls)) {
        element.classes.remove(cls);
      }
    });

    currentSet.forEach((cls) {
      if (!previousSet.contains(cls)) {
        element.classes.add(cls);
      }
    });

    previousSet = currentSet;
  }
}
