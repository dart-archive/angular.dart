part of angular.directive;

abstract class NgValidatable {
  String get name;
  bool isValid(value); 
}

/**
 * Validates the model depending if required or ng-required is present on the element.
 */
@NgDirective(
    selector: '[ng-model][required]')
@NgDirective(
    selector: '[ng-model][ng-required]',
    map: const {'ng-required': '=>required'})
class NgModelRequiredValidator implements NgValidatable {
  bool _required = true;

  String get name => 'required';

  NgModelRequiredValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) {
    // Any element which isn't required is always valid.
    if (!_required) return true;
    // Null is not a value, therefore not valid.
    if (value == null) return false;
    // Empty lists and/or strings are not valid.
    // NOTE: This is an excellent use case for structural typing.
    //   We really want anything object that has a 'isEmpty' property.
    return !((value is List || value is String) && value.isEmpty);
  }

  set required(value) {
    _required = value == null ? false : value;
  }
}

/**
 * Validates the model to see if its contents match a valid URL pattern.
 */
@NgDirective(selector: 'input[type=url][ng-model]')
class NgModelUrlValidator implements NgValidatable {
  static final URL_REGEXP = new RegExp(
      r'^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?' +
      r'(\/|\/([\w#!:.?+=&%@!\-\/]))?$');

  String get name => 'url';

  NgModelUrlValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) =>
      value == null || value.isEmpty || URL_REGEXP.hasMatch(value);
}

/**
 * Validates the model to see if its contents match a valid email pattern.
 */
@NgDirective(selector: 'input[type=email][ng-model]')
class NgModelEmailValidator implements NgValidatable {
  static final EMAIL_REGEXP = new RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$');

  String get name => 'email';

  NgModelEmailValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) =>
      value == null || value.isEmpty || EMAIL_REGEXP.hasMatch(value);
}

/**
 * Validates the model to see if its contents match a valid number.
 */
@NgDirective(selector: 'input[type=number][ng-model]')
class NgModelNumberValidator implements NgValidatable {
  String get name => 'number';

  NgModelNumberValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) {
    if (value != null) {
      try {
        num val = double.parse(value.toString());
      } catch(exception, stackTrace) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Validates the model to see if its contents match the given pattern present on either the
 * HTML pattern or ng-pattern attributes present on the input element.
 */
@NgDirective(selector: '[ng-model][pattern]')
@NgDirective(
    selector: '[ng-model][ng-pattern]',
    map: const {'ng-pattern': '=>pattern'})
class NgModelPatternValidator implements NgValidatable {
  RegExp _pattern;

  String get name => 'pattern';

  NgModelPatternValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) {
    //remember, only required validates for the input being empty
    return _pattern == null || value == null || value.length == 0 ||
           _pattern.hasMatch(value);
  }

  @NgAttr('pattern')
  set pattern(val) =>
      _pattern = val != null && val.length > 0 ? new RegExp(val) : null;
}

/**
 * Validates the model to see if the length of its contents are greater than or
 * equal to the minimum length set in place by the HTML minlength or
 * ng-minlength attributes present on the input element.
 */
@NgDirective(selector: '[ng-model][minlength]')
@NgDirective(
    selector: '[ng-model][ng-minlength]',
    map: const {'ng-minlength': '=>minlength'})
class NgModelMinLengthValidator implements NgValidatable {
  int _minlength;

  String get name => 'minlength';

  NgModelMinLengthValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) {
    //remember, only required validates for the input being empty
    return _minlength == 0 || value == null || value.length == 0 ||
           value.length >= _minlength;
  }

  @NgAttr('minlength')
  set minlength(value) =>
      _minlength = value == null ? 0 : int.parse(value.toString());
}

/**
 * Validates the model to see if the length of its contents are less than or
 * equal to the maximum length set in place by the HTML maxlength or
 * ng-maxlength attributes present on the input element.
 */
@NgDirective(selector: '[ng-model][maxlength]')
@NgDirective(
    selector: '[ng-model][ng-maxlength]',
    map: const {'ng-maxlength': '=>maxlength'})
class NgModelMaxLengthValidator implements NgValidatable {
  int _maxlength = 0;

  String get name => 'maxlength';

  NgModelMaxLengthValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(value) =>
      _maxlength == 0 || (value == null ? 0 : value.length) <= _maxlength;

  @NgAttr('maxlength')
  set maxlength(value) =>
      _maxlength = value == null ? 0 : int.parse(value.toString());
}
