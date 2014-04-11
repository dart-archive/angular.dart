part of angular.directive;

/**
 * @ngdoc directive
 * @name ng.directive:a
 * @restrict E
 *
 * @description
 * Modifies the default behavior of the html A tag so that the default action is
 * prevented when the a href is empty or it contains `ng-click` directive.
 *
 * This change permits the easy creation of action links with the `ngClick`
 * directive without changing the location or causing page reloads, e.g.:
 * `<a href="" ng-click="model.save()">Save</a>`
 */
@Decorator(selector: 'a[href]')
class AHref {
  final dom.Element element;

  AHref(this.element, VmTurnZone zone) {
    if (element.attributes["href"] == "") {
      zone.runOutsideAngular(() {
        element.onClick.listen((event) {
          if (element.attributes["href"] == "") {
            event.preventDefault();
          }
        });
      });
    }
  }
}
