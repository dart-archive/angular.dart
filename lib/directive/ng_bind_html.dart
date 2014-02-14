part of angular.directive;

/**
 * Creates a binding that will innerHTML the result of evaluating the
 * `expression` bound to `ng-bind-html` into the current element in a secure
 * way.  This expression must evaluate to a string.  The innerHTML-ed content
 * will be sanitized using a default [NodeValidator] constructed as `new
 * dom.NodeValidatorBuilder.common()`.  In a future version, when Strict
 * Contextual Escaping support has been added to Angular.dart, this directive
 * will allow one to bypass the sanitizaton and innerHTML arbitrary trusted
 * HTML.
 *
 * Example:
 *
 *     <div ng-bind-html="htmlVar"></div>
 */
@NgDirective(
  selector: '[ng-bind-html]',
  map: const {'ng-bind-html': '=>value'})
class NgBindHtmlDirective {
  final dom.Element element;
  final dom.NodeValidator validator;
  
  NgBindHtmlDirective(this.element, dom.NodeValidator this.validator);

  /**
   * Parsed expression from the `ng-bind-html` attribute.  The result of this
   * expression is innerHTML'd according to the rules specified in this class'
   * documentation.
   */
  set value(value) => element.setInnerHtml(value == null ? '' : value.toString(),
                                           validator: validator);
}
