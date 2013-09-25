library angular.directive.ng_a;

import 'dart:html' as dom;
import '../dom/directive.dart';

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
