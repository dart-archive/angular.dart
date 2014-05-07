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
  final NgElement ngElement;

  AHref(this.ngElement, VmTurnZone zone) {
    if (ngElement.node.attributes["href"] == "") {
      zone.runOutsideAngular(() {
        ngElement.addEventListener('click', (event) {
          if (ngElement.node.attributes["href"] == "") {
            event.preventDefault();
          }
        });
      });
    }
  }
}
