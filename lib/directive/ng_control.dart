part of angular.directive;

abstract class NgControl implements NgAttachAware, NgDetachAware {
  static const NG_VALID          = "ng-valid";
  static const NG_INVALID        = "ng-invalid";
  static const NG_PRISTINE       = "ng-pristine";
  static const NG_DIRTY          = "ng-dirty";
  static const NG_TOUCHED        = "ng-touched";
  static const NG_UNTOUCHED      = "ng-untouched";
  static const NG_SUBMIT_VALID   = "ng-submit-valid";
  static const NG_SUBMIT_INVALID = "ng-submit-invalid";

  String _name;
  bool _dirty;
  bool _touched;
  bool _valid;
  bool _submit_valid;

  final NgControl _parentControl;
  final NgAnimate _animate;
  NgElement _element;

  final _controls = new List<NgControl>();
  final _controlByName = new Map<String, List<NgControl>>();

  final errorStates = new Map<String, Set<NgControl>>();
  final infoStates = new Map<String, Set<NgControl>>();

  NgControl(NgElement this._element, Injector injector,
      NgAnimate this._animate)
      : _parentControl = injector.parent.get(NgControl);

  @override
  attach() => _parentControl.addControl(this);

  @override
  detach() {
    _parentControl.removeStates(this);
    _parentControl.removeControl(this);
  }

  reset() {
    _controls.forEach((control) {
      control.reset();
    });
  }

  onSubmit(bool valid) {
    if (valid) {
      _submit_valid = true;
      element..addClass(NG_SUBMIT_VALID)..removeClass(NG_SUBMIT_INVALID);
    } else {
      _submit_valid = false;
      element..addClass(NG_SUBMIT_INVALID)..removeClass(NG_SUBMIT_VALID);
    }
    _controls.forEach((control) {
      control.onSubmit(valid);
    });
  }

  get parentControl => _parentControl;

  get submitted => _submit_valid != null;
  get valid_submit => _submit_valid == true;
  get invalid_submit => _submit_valid == false;

  get name => _name;
  set name(value) {
    _name = value;
  }

  get element => _element;

  get valid              => !invalid;
  get invalid            => errorStates.isNotEmpty;

  get pristine           => !dirty;
  get dirty              => infoStates.containsKey(NG_DIRTY);

  get untouched          => !touched;
  get touched            => infoStates.containsKey(NG_TOUCHED);

  /**
   * Registers a form control into the form for validation.
   *
   * * [control] - The form control which will be registered (see [ngControl]).
   */
  addControl(NgControl control) {
    _controls.add(control);
    if (control.name != null) {
      _controlByName.putIfAbsent(control.name, () => new List<NgControl>()).add(control);
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
    String key = control.name;
    if (key != null && _controlByName.containsKey(key)) {
      _controlByName[key].remove(control);
      if (_controlByName[key].isEmpty) {
        _controlByName.remove(key);
      }
    }
  }

  removeStates(NgControl control) {
    bool hasRemovals = false;
    errorStates.keys.toList().forEach((state) {
      Set matchingControls = errorStates[state];
      matchingControls.remove(control);
      if (matchingControls.isEmpty) {
        errorStates.remove(state);
        hasRemovals = true;
      }
    });

    infoStates.keys.toList().forEach((state) {
      Set matchingControls = infoStates[state];
      matchingControls.remove(control);
      if (matchingControls.isEmpty) {
        infoStates.remove(state);
        hasRemovals = true;
      }
    });

    if (hasRemovals) {
      _parentControl.removeStates(this);
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
  bool hasErrorState(String key) => errorStates.containsKey(key);

  addErrorState(NgControl control, String state) {
    element..addClass(state + '-invalid')..removeClass(state + '-valid');
    errorStates.putIfAbsent(state, () => new Set()).add(control);
    _parentControl.addErrorState(this, state);
  }

  removeErrorState(NgControl control, String state) {
    if (!errorStates.containsKey(state)) return;

    bool hasState = _controls.isEmpty ||
                    _controls.every((control) {
                      return !control.hasErrorState(state);
                    });
    if (hasState) {
      errorStates.remove(state);
      _parentControl.removeErrorState(this, state);
      element..removeClass(state + '-invalid')..addClass(state + '-valid');
    }
  }

  _getOppositeInfoState(String state) {
    switch(state) {
      case NG_DIRTY:
        return NG_PRISTINE;
        break;
      case NG_TOUCHED:
        return NG_UNTOUCHED;
        break;
      default:
        //not all info states have an opposite value
        return null;
    }
  }

  addInfoState(NgControl control, String state) {
    String oppositeState = _getOppositeInfoState(state);
    if (oppositeState != null) {
      element.removeClass(oppositeState);
    }
    element.addClass(state);
    infoStates.putIfAbsent(state, () => new Set()).add(control);
    _parentControl.addInfoState(this, state);
  }

  removeInfoState(NgControl control, String state) {
    String oppositeState = _getOppositeInfoState(state);
    if (infoStates.containsKey(state)) {
      bool hasState = _controls.isEmpty ||
                      _controls.every((control) {
                        return !control.infoStates.containsKey(state);
                      });
      if (hasState) {
        if (oppositeState != null) {
          element.addClass(oppositeState);
        }
        element.removeClass(state);
        infoStates.remove(state);
        _parentControl.removeInfoState(this, state);
      }
    } else if (oppositeState != null) {
      NgControl parent = this;
      do {
        parent.element..addClass(oppositeState)..removeClass(state);
        parent = parent.parentControl;
      }
      while(parent != null && !(parent is NgNullControl));
    }
  }
}

class NgNullControl implements NgControl {
  var _name, _dirty, _valid, _submit_valid, _pristine, _element, _touched;
  var _controls, _parentControl, _controlName, _animate, infoStates, errorStates;
  var errors, _controlByName;
  NgElement element;

  NgNullControl() {}
  onSubmit(bool valid) {}

  addControl(control) {}
  removeControl(control) {}
  updateControlValidity(NgControl control, String errorType, bool isValid) {}

  get name => null;
  set name(name) {}

  bool get submitted => false;
  bool get valid_submit => true;
  bool get invalid_submit => false;
  bool get pristine => true;
  bool get dirty => false;
  bool get valid => true;
  bool get invalid => false;
  bool get touched => false;
  bool get untouched => true;

  get parentControl => null;

  _getOppositeInfoState(String state) {}
  addErrorState(NgControl control, String state) {}
  removeErrorState(NgControl control, String state) {}
  addInfoState(NgControl control, String state) {}
  removeInfoState(NgControl control, String state) {}

  reset() => null;
  attach() => null;
  detach() => null;

  bool hasErrorState(String key) => false;
  removeStates(NgControl control) {}
}
