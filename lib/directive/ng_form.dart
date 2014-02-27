part of angular.directive;

/**
 * The form directive listens on submission requests and, depending,
 * on if an action is set, the form will automatically either allow
 * or prevent the default browser submission from occurring.
 */
@NgDirective(
    selector: 'form',
    publishTypes : const <Type>[NgControl],
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: 'fieldset',
    publishTypes : const <Type>[NgControl],
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '.ng-form',
    publishTypes : const <Type>[NgControl],
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '[ng-form]',
    publishTypes : const <Type>[NgControl],
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm extends NgControl {
  /**
   * Instantiates a new instance of NgForm. Upon creation, the instance of the
   * class will be bound to the formName property on the scope (where formName
   * refers to the name value acquired from the name attribute present on the
   * form DOM element).
   *
   * * [scope] - The scope to bind the form instance to.
   * * [element] - The form DOM element.
   * * [injector] - An instance of Injector.
   */
  NgForm(Scope scope, dom.Element element, Injector injector,
      NgAnimate animate) :
    super(scope, element, injector, animate) {

    if (!element.attributes.containsKey('action')) {
      element.onSubmit.listen((event) {
        event.preventDefault();
        _scope.broadcast('submitNgControl', valid == true);
        if (valid == true) {
          reset();
        }
      });
    }
  }

  @NgAttr('name')
  get name => _name;
  set name(value) {
    super.name = value;
    _scope.context[name] = this;
  }

  NgControl operator[](name) => _controlByName[name];
}

class NgNullForm extends NgNullControl implements NgForm {
  NgNullForm() {}
  operator[](name) {}
}
