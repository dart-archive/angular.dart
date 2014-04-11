part of angular.directive;

/**
 * The ngBind attribute tells Angular to replace the text content of the
 * specified HTML element with the value of a given expression, and to update
 * the text content when the value of that expression changes.
 *
 * Typically, you don't use ngBind directly, but instead you use the double
 * curly markup like {{ expression }} which is similar but less verbose.
 *
 * It is preferrable to use ngBind instead of {{ expression }} when a template
 * is momentarily displayed by the browser in its raw state before Angular
 * compiles it. Since ngBind is an element attribute, it makes the bindings
 * invisible to the user while the page is loading.
 *
 * An alternative solution to this problem would be using the ngCloak directive.
 */
@Decorator(
  selector: '[ng-bind]',
  map: const {'ng-bind': '=>value'})
class NgBind {
  final dom.Element element;

  NgBind(this.element);

  set value(value) => element.text = value == null ? '' : value.toString();
}
