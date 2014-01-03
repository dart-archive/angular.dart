part of angular.directive;

abstract class NgControl {
  static const NG_VALID_CLASS    = "ng-valid";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_PRISTINE_CLASS = "ng-pristine";
  static const NG_DIRTY_CLASS    = "ng-dirty";

  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;

  get pristine => _pristine;
  set pristine(value) {
    _pristine = true;
    _dirty = false;

    if(_element != null) {
      _element.classes.remove(NgControl.NG_DIRTY_CLASS);
      _element.classes.add(NgControl.NG_PRISTINE_CLASS);
    }
  }

  get dirty => _dirty;
  set dirty(value) {
    _dirty = true;
    _pristine = false;

    if(_element != null) {
      _element.classes.remove(NgControl.NG_PRISTINE_CLASS);
      _element.classes.add(NgControl.NG_DIRTY_CLASS);
    }
  }

  get valid => _valid;
  set valid(value) {
    _invalid = false;
    _valid = true;

    if(_element != null) {
      _element.classes.remove(NgControl.NG_INVALID_CLASS);
      _element.classes.add(NgControl.NG_VALID_CLASS);
    }
  }

  get invalid => _invalid;
  set invalid(value) {
    _valid = false;
    _invalid = true;

    if(_element != null) {
      _element.classes.remove(NgControl.NG_VALID_CLASS);
      _element.classes.add(NgControl.NG_INVALID_CLASS);
    }
  }
}
