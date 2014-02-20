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
class NgForm extends NgControl implements Map<String, NgControl> {
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
  NgForm(Scope scope, dom.Element element, Injector injector) :
    super(scope, element, injector) {

    if (!element.attributes.containsKey('action')) {
      element.onSubmit.listen((event) {
        event.preventDefault();
        _scope.broadcast('submitNgControl', valid == null ? false : valid);
        reset();
      });
    }
  }

  @NgAttr('name')
  get name => _name;
  set name(value) {
    super.name = value;
    _scope.context[name] = this;
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator []=(String key, value) {
    if (key == 'name') {
      name = value;
    } else {
      _controlByName[key] = value;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator[](name) {
    if (name == 'valid') {
      return valid;
    } else if (name == 'invalid') {
      return invalid;
    } else {
      return _controlByName[name];
    }
  }

  bool get isEmpty => false;
  bool get isNotEmpty => !isEmpty;
  get values => null;
  get keys => null;
  get length => null;
  clear() => null;
  remove(_) => null;
  containsKey(_) => false;
  containsValue(_) => false;
  addAll(_) => null;
  forEach(_) => null;
  putIfAbsent(_, __) => null;
}

class NgNullForm extends NgNullControl implements NgForm {
  NgNullForm() {}

  operator[](name) {}
  operator []=(String name, value) {}

  bool get isEmpty => false;
  bool get isNotEmpty => true;
  get values => null;
  get keys => null;
  get length => null;
  clear() => null;
  remove(_) => null;
  containsKey(_) => false;
  containsValue(_) => false;
  addAll(_) => null;
  forEach(_) => null;
  putIfAbsent(_, __) => null;
}
