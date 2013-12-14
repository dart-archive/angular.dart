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
class NgForm {
  static const NG_VALID_CLASS    = "ng-valid";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_PRISTINE_CLASS = "ng-pristine";
  static const NG_DIRTY_CLASS    = "ng-dirty";

  NgForm _parentForm;
  final dom.Element _element;
  final Scope _scope;

  String _name;

  final Map currentErrors = new Map();
  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;

  final List _controls = new List();
  final Map _controlByName = new Map();

  NgForm(Scope this._scope, dom.Element this._element, Injector injector) {
    _parentForm = injector.parent.get(NgForm);
    if(!this._element.attributes.containsKey('action')) {
      this._element.onSubmit.listen((event) {
        event.preventDefault();
      });
    }

    _scope.$on(r'$destroy', () {
      for (int i = _controls.length - 1; i >= 0; --i) {
        removeControl(_controls[i]);
      }
    });

    this.pristine = true;

    //this will most likely change once all the controls are added + evaluated
    this.valid = true;
  }

  @NgAttr('name')
  get name => _name;
  set name(name) {
    _name = name;
    _scope[name] = this;
  }

  get pristine => _pristine;
  set pristine(value) {
    _pristine = true;
    _dirty = false;

    _element.classes.remove(NG_DIRTY_CLASS);
    _element.classes.add(NG_PRISTINE_CLASS);
  }

  get dirty => _dirty;
  set dirty(value) {
    _dirty = true;
    _pristine = false;

    _element.classes.remove(NG_PRISTINE_CLASS);
    _element.classes.add(NG_DIRTY_CLASS);
  }

  get valid => _valid;
  set valid(value) {
    _invalid = false;
    _valid = true;

    _element.classes.remove(NG_INVALID_CLASS);
    _element.classes.add(NG_VALID_CLASS);
  }

  get invalid => _invalid;
  set invalid(value) {
    _valid = false;
    _invalid = true;

    _element.classes.remove(NG_VALID_CLASS);
    _element.classes.add(NG_INVALID_CLASS);
  }

  setValidity(control, String errorType, bool isValid) {
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
        queue = new List();
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

  addControl(control) {
    _controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(control) {
    _controls.remove(control);
    if(control.name != null) {
      _controlByName.remove(control.name);
    }
  }
}
