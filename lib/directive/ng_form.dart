part of angular.directive;

/**
 * The form directive listens on submission requests and, depending,
 * on if an action is set, the form will automatically either allow
 * or prevent the default browser submission from occurring.
 */
@NgDirective(
    selector: 'form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: 'fieldset',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '.ng-form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '[ng-form]',
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm extends NgControl implements NgDetachAware, Map<String, NgModel> {
  final NgForm _parentForm;
  final dom.Element _element;
  final Scope _scope;

  final Map<String, List<NgControl>> currentErrors =
      new Map<String, List<NgControl>>();

  final List<NgControl> _controls = new List<NgControl>();
  final Map<String, NgControl> _controlByName = new Map<String, NgControl>();

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
  NgForm(this._scope, dom.Element this._element, Injector injector):
    _parentForm = injector.parent.get(NgForm)
  {
    if(!_element.attributes.containsKey('action')) {
      _element.onSubmit.listen((event) {
        event.preventDefault();
      });
    }

    pristine = true;
  }

  detach() {
    for (int i = _controls.length - 1; i >= 0; --i) {
      removeControl(_controls[i]);
    }
  }

  get element => _element;

  @NgAttr('name')
  get name => _name;
  set name(name) {
    _name = name;
    _scope[name] = this;
  }

  /**
   * Sets the validity status of the given control/errorType pair within
   * the list of controls registered on the form. Depending on the validation
   * state of the existing controls, this will either change valid to true
   * or invalid to true depending on if all controls are valid or if one
   * or more of them is invalid.
   *
   * * [control] - The registered control object (see [ngControl]).
   * * [errorType] - The error associated with the control (e.g. required, url,
   * number, etc...).
   * * [isValid] - Whether the given error is valid or not (false would mean the
   * error is real).
   */
  setValidity(NgControl control, String errorType, bool isValid) {
    List queue = currentErrors[errorType];

    if(isValid) {
      if(queue != null) {
        queue.remove(control);
        if(queue.isEmpty) {
          currentErrors.remove(errorType);
          if(currentErrors.isEmpty) valid = true;
          _parentForm.setValidity(this, errorType, true);
        }
      }
    } else {
      if(queue == null) {
        queue = new List<NgControl>();
        currentErrors[errorType] = queue;
        _parentForm.setValidity(this, errorType, false);
      } else if(queue.contains(control)) return;

      queue.add(control);
      invalid = true;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator []=(String key, value) {
    if(key == 'name'){
      name = value;
    } else {
      _controlByName[key] = value;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator[](name) {
    if(name == 'valid') {
      return valid;
    } else if(name == 'invalid') {
      return invalid;
    } else {
      return _controlByName[name];
    }
  }

  /**
   * Registers a form control into the form for validation.
   *
   * * [control] - The form control which will be registered (see [ngControl]).
   */
  addControl(NgControl control) {
    _controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  /**
   * De-registers a form control from the list of controls associated with the
   * form.
   *
   * * [control] - The form control which will be de-registered (see
   * [ngControl]).
   */
  removeControl(NgControl control) {
    _controls.remove(control);
    if(control.name != null) {
      _controlByName.remove(control.name);
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

class NgNullForm implements NgForm {
  var _name, _dirty, _valid, _invalid, _pristine, _element;
  var _controls, _scope, _parentForm, _controlName;
  var currentErrors, _controlByName;
  dom.Element element;
  NgNullForm() {}
  operator[](name) {}
  operator []=(String name, value) {}
  addControl(control) {}
  removeControl(control) {}
  setValidity(control, String errorType, bool isValid) {}

  get name => null;
  set name(name) {}

  get pristine => null;
  set pristine(value) {}

  get dirty => null;
  set dirty(value) {}

  get valid => null;
  set valid(value) {}

  get invalid => null;
  set invalid(value) {}

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

  detach() => null;
}
