part of angular.directive;

/**
 * @ngdoc directive
 * @name ng.directive:a
 * @restrict E
 *
 * @description
 * Modifies the default behavior of the html A tag so that the default action is prevented when
 * the a href is empty or it contains `ng-click` directive.
 *
 * This change permits the easy creation of action links with the `ngClick` directive
 * without changing the location or causing page reloads, e.g.:
 * `<a href="" ng-click="model.$save()">Save</a>`
 */
@NgDirective(selector: 'a[href]')
class NgADirective {
  final dom.Element element;

  NgADirective(this.element) {
    if (element.attributes["href"] == "" ||
        element.attributes.containsKey('ng-click')) {
      element.onClick.listen((event) {
        if (element.attributes["href"] == "") {
          event.preventDefault();
        }
      });
    }
  }
}
