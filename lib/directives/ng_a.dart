library angular.directive.ng_a;

import 'dart:html' as dom;
import '../dom/directive.dart';

/**
 * @ngdoc directive
 * @name ng.directive:a
 * @restrict E
 *
 * @description
 * Modifies the default behavior of the html A tag so that the default action is prevented when
 * the href attribute is empty.
 *
 * This change permits the easy creation of action links with the `ngClick` directive
 * without changing the location or causing page reloads, e.g.:
 * `<a href="" ng-click="model.$save()">Save</a>`
 */
@NgDirective(selector: 'a[href]')
class NgAAttrDirective {
  dom.Element element;

  NgAAttrDirective(dom.Element element) {
    if(element.attributes["href"] == "") {
      element.onClick.listen((event) {
        event.preventDefault();
      });
    }
  }
}
