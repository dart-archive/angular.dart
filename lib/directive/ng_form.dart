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
    map: const { 'ng-form': '@name' },
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm extends NgControl {
  final Scope _scope;

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
  NgForm(this._scope, NgElement element, Injector injector, NgAnimate animate) :
    super(element, injector, animate) {

    if (!element.node.attributes.containsKey('action')) {
      element.node.onSubmit.listen((event) {
        event.preventDefault();
        onSubmit(valid == true);
        if (valid == true) {
          reset();
        }
      });
    }
  }

  @NgAttr('name')
  get name => _name;
  set name(value) {
    if (value != null) {
      super.name = value;
      _scope.context[name] = this;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator []=(String key, value) {
    if (key == 'name') {
      name = value;
    } else {
      _controlByName[key] = value;
    }
  }

  get controls => _controlByName;

  NgControl operator[](name) {
    if (controls.containsKey(name)) {
      return controls[name][0];
    }
  }
}

class NgNullForm extends NgNullControl implements NgForm {
  var _scope;

  NgNullForm() {}
  operator []=(String key, value) {}
  operator[](name) {}

  get controls => null;
}
