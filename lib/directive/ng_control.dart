part of angular.directive;

abstract class NgControl {
  static const NG_VALID_CLASS    = "ng-valid";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_PRISTINE_CLASS = "ng-pristine";
  static const NG_DIRTY_CLASS    = "ng-dirty";

  String _name;
  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;

  get element => null;

  get name => _name;
  set name(name) => _name = name;

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

}
