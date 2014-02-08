part of angular.directive;

/**
 * The [NgBindTemplateDirective] specifies that the element text content should
 * be replaced with the interpolation of the template in the ngBindTemplate
 * attribute. Unlike ngBind, the ngBindTemplate can contain multiple {{ }}
 * expressions.
 */
@NgDirective(
  selector: '[ng-bind-template]',
  map: const {'ng-bind-template': '@bind'})
class NgBindTemplateDirective {
  final dom.Element element;

  NgBindTemplateDirective(this.element);

  set bind(value) {
    element.text = value;
  }
}
