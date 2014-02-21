part of angular.directive;

abstract class NgControl implements NgDetachAware {
  static const NG_VALID_CLASS          = "ng-valid";
  static const NG_INVALID_CLASS        = "ng-invalid";
  static const NG_PRISTINE_CLASS       = "ng-pristine";
  static const NG_DIRTY_CLASS          = "ng-dirty";
  static const NG_TOUCHED_CLASS        = "ng-touched";
  static const NG_UNTOUCHED_CLASS      = "ng-untouched";
  static const NG_SUBMIT_VALID_CLASS   = "ng-submit-valid";
  static const NG_SUBMIT_INVALID_CLASS = "ng-submit-invalid";

  String _name;
  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;
  bool _touched;
  bool _untouched;
  bool _submit_valid;

  final Scope _scope;
  final NgControl _parentControl;
  dom.Element _element;

  final Map<String, List<NgControl>> errors   = new Map<String, List<NgControl>>();
  final List<NgControl> _controls             = new List<NgControl>();
  final Map<String, NgControl> _controlByName = new Map<String, NgControl>();

  NgControl(Scope this._scope, dom.Element this._element, Injector injector)
      : _parentControl = injector.parent.get(NgControl)
  {
    pristine = true;
    untouched = true;

    _scope.on('submitNgControl').listen((e) => _onSubmit(e.data));
  }

  detach() {
    for (int i = _controls.length - 1; i >= 0; --i) {
      removeControl(_controls[i]);
    }
  }

  reset() {
    _scope.broadcast('resetNgModel');
    untouched = true;
  }

  _onSubmit(bool valid) {
    if (valid) {
      _submit_valid = true;
      element.classes..add(NG_SUBMIT_VALID_CLASS)..remove(NG_SUBMIT_INVALID_CLASS);
    } else {
      _submit_valid = false;
      element.classes..add(NG_SUBMIT_INVALID_CLASS)..remove(NG_SUBMIT_VALID_CLASS);
    }
  }

  get submitted => _submit_valid != null;
  get valid_submit => _submit_valid == true;
  get invalid_submit => _submit_valid == false;

  get name => _name;
  set name(value) {
    _name = value;
    _parentControl.addControl(this);
  }

  get element => _element;

  get pristine => _pristine;
  set pristine(value) {
    _pristine = true;
    _dirty = false;

    element.classes..remove(NG_DIRTY_CLASS)..add(NG_PRISTINE_CLASS);
  }

  get dirty => _dirty;
  set dirty(value) {
    _dirty = true;
    _pristine = false;

    element.classes..remove(NG_PRISTINE_CLASS)..add(NG_DIRTY_CLASS);

    //as soon as one of the controls/models is modified
    //then all of the parent controls are dirty as well
    _parentControl.dirty = true;
  }

  get valid => _valid;
  set valid(value) {
    _invalid = false;
    _valid = true;

    element.classes..remove(NG_INVALID_CLASS)..add(NG_VALID_CLASS);
  }

  get invalid => _invalid;
  set invalid(value) {
    _valid = false;
    _invalid = true;

    element.classes..remove(NG_VALID_CLASS)..add(NG_INVALID_CLASS);
  }

  get touched => _touched;
  set touched(value) {
    _touched = true;
    _untouched = false;

    element.classes..remove(NG_UNTOUCHED_CLASS)..add(NG_TOUCHED_CLASS);

    //as soon as one of the controls/models is touched
    //then all of the parent controls are touched as well
    _parentControl.touched = true;
  }

  get untouched => _untouched;
  set untouched(value) {
    _touched = false;
    _untouched = true;
    element.classes..remove(NG_TOUCHED_CLASS)..add(NG_UNTOUCHED_CLASS);
  }

  /**
   * Registers a form control into the form for validation.
   *
   * * [control] - The form control which will be registered (see [ngControl]).
   */
  addControl(NgControl control) {
    _controls.add(control);
    if (control.name != null) {
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
    if (control.name != null) {
      _controlByName.remove(control.name);
    }
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
  updateControlValidity(NgControl control, String errorType, bool isValid) {
    List queue = errors[errorType];

    if (isValid) {
      if (queue != null) {
        queue.remove(control);
        if (queue.isEmpty) {
          errors.remove(errorType);
          _parentControl.updateControlValidity(this, errorType, true);
        }
      }
      if (errors.isEmpty) {
        valid = true;
      }
    } else {
      if (queue == null) {
        queue = new List<NgControl>();
        errors[errorType] = queue;
        _parentControl.updateControlValidity(this, errorType, false);
      } else if (queue.contains(control)) return;

      queue.add(control);
      invalid = true;
    }
  }
}

class NgNullControl implements NgControl {
  var _name, _dirty, _valid, _invalid, _submit_valid, _pristine, _element;
  var _touched, _untouched;
  var _controls, _scope, _parentControl, _controlName;
  var errors, _controlByName;
  dom.Element element;

  NgNullControl() {}
  _onSubmit(bool valid) {}

  addControl(control) {}
  removeControl(control) {}
  updateControlValidity(NgControl control, String errorType, bool isValid) {}

  get name => null;
  set name(name) {}

  get submitted => null;
  get valid_submit => null;
  get invalid_submit => null;

  get pristine => null;
  set pristine(value) {}

  get dirty => null;
  set dirty(value) {}

  get valid => null;
  set valid(value) {}

  get invalid => null;
  set invalid(value) {}

  get touched => null;
  set touched(value) {}

  get untouched => null;
  set untouched(value) {}

  reset() => null;
  detach() => null;

}
