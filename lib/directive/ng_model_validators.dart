part of angular.directive;

abstract class NgValidator {
  final String name;
  bool isValid(modelValue);
}

/**
 * Validates the model depending if required or ng-required is present on the element.
 */
@NgDirective(
    selector: '[ng-model][required]')
@NgDirective(
    selector: '[ng-model][ng-required]',
    map: const {'ng-required': '=>required'})
class NgModelRequiredValidator implements NgValidator {
  bool _required = true;

  final String name = 'ng-required';

  NgModelRequiredValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) {
    // Any element which isn't required is always valid.
    if (!_required) return true;
    // Null is not a value, therefore not valid.
    if (modelValue == null) return false;
    // Empty lists and/or strings are not valid.
    // NOTE: This is an excellent use case for structural typing.
    //   We really want anything object that has a 'isEmpty' property.
    return !((modelValue is List || modelValue is String) && modelValue.isEmpty);
  }

  set required(value) {
    _required = value == null ? false : value;
  }
}

/**
 * Validates the model to see if its contents match a valid URL pattern.
 */
@NgDirective(selector: 'input[type=url][ng-model]')
class NgModelUrlValidator implements NgValidator {
  static final URL_REGEXP = new RegExp(
      r'^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?' +
      r'(\/|\/([\w#!:.?+=&%@!\-\/]))?$');

  final String name = 'ng-url';

  NgModelUrlValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) =>
      modelValue == null || modelValue.isEmpty || URL_REGEXP.hasMatch(modelValue);
}

/**
 * Validates the model to see if its contents match a valid email pattern.
 */
@NgDirective(selector: 'input[type=email][ng-model]')
class NgModelEmailValidator implements NgValidator {
  static final EMAIL_REGEXP = new RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$');

  final String name = 'ng-email';

  NgModelEmailValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) =>
      modelValue == null || modelValue.isEmpty || EMAIL_REGEXP.hasMatch(modelValue);
}

/**
 * Validates the model to see if its contents match a valid number.
 */
@NgDirective(selector: 'input[type=number][ng-model]')
@NgDirective(selector: 'input[type=range][ng-model]')
class NgModelNumberValidator implements NgValidator {
  final String name = 'ng-number';

  NgModelNumberValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) {
    if (modelValue != null) {
      try {
        num val = double.parse(modelValue.toString());
        if (val.isNaN) {
          return false;
        }
      } catch(exception, stackTrace) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Validates the model to see if the numeric value than or equal to the max value.
 */
@NgDirective(selector: 'input[type=number][ng-model][max]')
@NgDirective(selector: 'input[type=range][ng-model][max]')
@NgDirective(
    selector: 'input[type=number][ng-model][ng-max]',
    map: const {'ng-max': '=>max'})
@NgDirective(
    selector: 'input[type=range][ng-model][ng-max]',
    map: const {'ng-max': '=>max'})
class NgModelMaxNumberValidator implements NgValidator {

  double _max;
  final String name = 'ng-max';

  NgModelMaxNumberValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  @NgAttr('max')
  get max => _max;
  set max(value) {
    try {
      num parsedValue = double.parse(value);
      _max = parsedValue.isNaN ? _max : parsedValue;
    } catch(e) {};
  }

  bool isValid(modelValue) {
    if (modelValue == null || max == null) return true;

    try {
      num parsedValue = double.parse(modelValue.toString());
      if (!parsedValue.isNaN) {
        return parsedValue <= max;
      }
    } catch(exception, stackTrace) {}

    //this validator doesn't care if the type conversation fails or the value
    //is not a number (NaN) because NgModelNumberValidator will handle the
    //number-based validation either way.
    return true;
  }
}

/**
 * Validates the model to see if the numeric value is greater than or equal to the min value.
 */
@NgDirective(selector: 'input[type=number][ng-model][min]')
@NgDirective(selector: 'input[type=range][ng-model][min]')
@NgDirective(
    selector: 'input[type=number][ng-model][ng-min]',
    map: const {'ng-min': '=>min'})
@NgDirective(
    selector: 'input[type=range][ng-model][ng-min]',
    map: const {'ng-min': '=>min'})
class NgModelMinNumberValidator implements NgValidator {

  double _min;
  final String name = 'ng-min';

  NgModelMinNumberValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  @NgAttr('min')
  get min => _min;
  set min(value) {
    try {
      num parsedValue = double.parse(value);
      _min = parsedValue.isNaN ? _min : parsedValue;
    } catch(e) {};
  }

  bool isValid(modelValue) {
    if (modelValue == null || min == null) return true;

    try {
      num parsedValue = double.parse(modelValue.toString());
      if (!parsedValue.isNaN) {
        return parsedValue >= min;
      }
    } catch(exception, stackTrace) {}

    //this validator doesn't care if the type conversation fails or the value
    //is not a number (NaN) because NgModelNumberValidator will handle the
    //number-based validation either way.
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
class NgModelPatternValidator implements NgValidator {
  RegExp _pattern;

  final String name = 'ng-pattern';

  NgModelPatternValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) {
    //remember, only required validates for the input being empty
    return _pattern == null || modelValue == null || modelValue.length == 0 ||
           _pattern.hasMatch(modelValue);
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
class NgModelMinLengthValidator implements NgValidator {
  int _minlength;

  final String name = 'ng-minlength';

  NgModelMinLengthValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) {
    //remember, only required validates for the input being empty
    return _minlength == 0 || modelValue == null || modelValue.length == 0 ||
           modelValue.length >= _minlength;
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
class NgModelMaxLengthValidator implements NgValidator {
  int _maxlength = 0;

  final String name = 'ng-maxlength';

  NgModelMaxLengthValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(modelValue) =>
      _maxlength == 0 || (modelValue == null ? 0 : modelValue.length) <= _maxlength;

  @NgAttr('maxlength')
  set maxlength(value) =>
      _maxlength = value == null ? 0 : int.parse(value.toString());
}
