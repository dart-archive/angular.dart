part of angular.directive;

abstract class _NgModelValidator {
  final dom.Element inputElement;
  final NgModel ngModel;
  final Scope scope;
  bool _listening = false;

  _NgModelValidator(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    this.listen();
  }

  bool listen() {
    if(!_listening) {
      _listening = true;
      this.ngModel.validators.add(this);
    }
  }

  bool unlisten() {
    if(_listening) {
      _listening = false;
      this.ngModel.validators.remove(this);
    }
  }

  //override in subclass
  bool isValid();
}

@NgDirective(selector: '[ng-model][required]')
@NgDirective(selector: '[ng-model][ng-required]', map: const {'ng-required': '=>required'})
class NgModelRequiredValidator extends _NgModelValidator {
  bool _required;
  get name => 'required';

  NgModelRequiredValidator(dom.Element inputElement, NgModel ngModel, Scope scope, NodeAttrs attrs):
    super(inputElement, ngModel, scope) {
      print("here");
      _required = attrs['required'] != null;
    }

  bool isValid() {
    String value = ngModel.viewValue;
    return !required || (value != null && value.length > 0);
  }

  get required => _required;
  set required(value) {
    _required = value;
    value ? listen() : unlisten();
  }
}

@NgDirective(selector: 'input[type=url][ng-model]')
class NgModelUrlValidator extends _NgModelValidator {
  static final URL_REGEXP = new RegExp(
      r'^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?' +
      r'(\/|\/([\w#!:.?+=&%@!\-\/]))?$');

  get name => 'url';

  NgModelUrlValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope);

  bool isValid() {
    String value = ngModel.viewValue;
    if(value != null && value.length > 0) { 
      return URL_REGEXP.hasMatch(value);
    }

    //remember, only required validates for the input being empty
    return true;
  }
}

@NgDirective(selector: 'input[type=email][ng-model]')
class NgModelEmailValidator extends _NgModelValidator {
  static final EMAIL_REGEXP = new RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$');

  get name => 'email';

  NgModelEmailValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope);

  bool isValid() {
    String value = ngModel.viewValue;
    if(value != null && value.length > 0) { 
      return EMAIL_REGEXP.hasMatch(value);
    }

    //remember, only required validates for the input being empty
    return true;
  }
}

@NgDirective(selector: 'input[type=number][ng-model]')
class NgModelNumberValidator extends _NgModelValidator {
  get name => 'number';

  NgModelNumberValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope);

  bool isValid() {
    var value = ngModel.viewValue;

    //remember, only required validates for the input being empty
    if(value == null) {
      return true;
    }

    if(value is num) {
      num number = value as num;
      return !number.isNaN;
    }
    return false;
  }
}

@NgDirective(selector: 'input[ng-model][pattern]')
@NgDirective(selector: 'input[ng-model][ng-pattern]', map: const {'ng-pattern': '=>pattern'})
class NgModelPatternValidator extends _NgModelValidator {
  RegExp _pattern;

  get name => 'pattern';

  NgModelPatternValidator(dom.Element inputElement, NgModel ngModel, Scope scope, NodeAttrs attrs):
    super(inputElement, ngModel, scope) {
      if(attrs['pattern'] != null) {
        pattern = attrs['pattern'];
      }
    }

  bool isValid() {
    if(_pattern != null && value != null && value.length > 0) {
      return _pattern.hasMatch(ngModel.viewValue);
    }

    //remember, only required validates for the input being empty
    return true;
  }

  set pattern(value) {
    if(value != null && value.length > 0) {
      _pattern = new RegExp(value);
      listen();
    } else {
      _pattern = null;
      unlisten();
    }
  }
}

@NgDirective(selector: 'input[ng-model][minlength]')
@NgDirective(selector: 'input[ng-model][ng-minlength]', map: const {'ng-minlength': '=>minlength'})
class NgModelMinLengthValidator extends _NgModelValidator {
  int _minlength;

  get name => 'minlength';

  NgModelMinLengthValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      minlength = attrs['minlength'];
    }

  bool isValid() {
    String value = ngModel.viewValue;

    //remember, only required validates for the input being empty
    if(_minlength == 0 || value == null || value.length == 0) {
      return true;
    }
    return value.length >= _minlength;
  }

  set minlength(value) {
    _minlength = value == null ? 0 : int.parse(value);
  }
}

@NgDirective(selector: 'input[ng-model][maxlength]')
@NgDirective(selector: 'input[ng-model][ng-maxlength]', map: const {'ng-maxlength': '=>maxlength'})
class NgModelMaxLengthValidator extends _NgModelValidator {
  int _maxlength;

  get name => 'maxlength';

  NgModelMaxLengthValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      maxlength = attrs['maxlength'];
    }

  bool isValid() {
    String value = ngModel.viewValue;
    return _maxlength == 0 || (value == null ? 0 : value.length) <= _maxlength;
  }

  set maxlength(value) {
    _maxlength = value == null ? 0 : int.parse(value);
  }
}
