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
class NgForm extends NgControl implements NgDetachAware {
  NgForm _parentForm;
  final dom.Element _element;
  final Scope _scope;

  final Map<String, List<NgControl>> currentErrors = new Map<String, List<NgControl>>();

  final List<NgControl> _controls = new List<NgControl>();
  final Map<String, NgControl> _controlByName = new Map<String, NgControl>();

  NgForm(this._scope, dom.Element this._element, Injector injector) {
    _parentForm = injector.parent.get(NgForm);
    if(!this._element.attributes.containsKey('action')) {
      this._element.onSubmit.listen((event) {
        event.preventDefault();
      });
    }

    this.pristine = true;
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

  setValidity(NgControl control, String errorType, bool isValid) {
    List queue = currentErrors[errorType];

    if(isValid) {
      if(queue != null) {
        queue.remove(control);
        if(queue.isEmpty) {
          currentErrors.remove(errorType);
          if(currentErrors.isEmpty) {
            valid = true;
          }
          if(_parentForm != null) {
            _parentForm.setValidity(this, errorType, true);
          }
        }
      }
    } else {
      if(queue == null) {
        queue = new List<NgControl>();
        currentErrors[errorType] = queue;
        if(_parentForm != null) {
          _parentForm.setValidity(this, errorType, false);
        }
      } else if(queue.contains(control)) {
        return;
      }

      queue.add(control);
      invalid = true;
    }
  }

  operator[](name) {
    return _controlByName[name];
  }

  addControl(NgControl control) {
    _controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(NgControl control) {
    _controls.remove(control);
    if(control.name != null) {
      _controlByName.remove(control.name);
    }
  }
}

class NgNullForm implements NgForm {
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
}
