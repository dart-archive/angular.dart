part of angular.directive;

/**
 * The [NgBindTemplate] specifies that the element text content should
 * be replaced with the interpolation of the template in the ngBindTemplate
 * attribute. Unlike ngBind, the ngBindTemplate can contain multiple {{ }}
 * expressions.
 */
@Decorator(
    selector: '[ng-bind-template]',
    map: const {'ng-bind-template': '@bind'})
class NgBindTemplate {
  final dom.Element element;

  NgBindTemplate(this.element);

  void set bind(value) {
    element.text = value;
  }
}
