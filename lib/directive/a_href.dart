part of angular.directive;

/**
 * Modifies the default behavior of the HTML `<a>` element to allow for data binding.
 *
 * When an `href` tag is empty, or when used with `ng-click`, this directive intercepts and
 * modifies  the default behavior of the `<a>` element. This change permits the easy
 * creation of action links with the [OnClick] directive, without changing the location or causing
 * a page reload.
 *
* Example:
 *
 *     <a href="" ng-click="model.save()">Save</a>
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
