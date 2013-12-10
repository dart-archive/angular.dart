part of angular.directive;

abstract class _NgModelValidator {
  final dom.Element inputElement;
  final NgModel ngModel;
  final Scope scope;
  bool _listening = false;

  _NgModelValidator(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope);

  bool listen() {
    if(!_listening) {
      _listening = true;
      this.ngModel.addValidator(this);
    }
  }

  get value => ngModel.viewValue;

  bool unlisten() {
    if(_listening) {
      _listening = false;
      this.ngModel.removeValidator(this);
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
      if(attrs['required'] != null) {
        required = true;
      }
    }

  bool isValid() {
    return !required || (value != null && value.length > 0);
  }

  @NgAttr('required')
  get required => _required;
  set required(value) {
    if(value is String) return;
    (_required = value) == true ? listen() : unlisten();
  }
}

@NgDirective(selector: 'input[type=url][ng-model]')
class NgModelUrlValidator extends _NgModelValidator {
  static final URL_REGEXP = new RegExp(
      r'^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?' +
      r'(\/|\/([\w#!:.?+=&%@!\-\/]))?$');

  get name => 'url';

  NgModelUrlValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    return value == null || value.length == 0 || URL_REGEXP.hasMatch(value);
  }
}

@NgDirective(selector: 'input[type=email][ng-model]')
class NgModelEmailValidator extends _NgModelValidator {
  static final EMAIL_REGEXP = new RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$');

  get name => 'email';

  NgModelEmailValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    return value == null || value.length == 0 || EMAIL_REGEXP.hasMatch(value);
  }
}

@NgDirective(selector: 'input[type=number][ng-model]')
class NgModelNumberValidator extends _NgModelValidator {
  get name => 'number';

  NgModelNumberValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    if(value != null) {
      try {
        num val = double.parse(value.toString());
      } catch(exception, stackTrace) {
        return false;
      }
    }
    return true;
  }
}

@NgDirective(selector: '[ng-model][pattern]')
@NgDirective(selector: '[ng-model][ng-pattern]', map: const {'ng-pattern': '=>pattern'})
class NgModelPatternValidator extends _NgModelValidator {
  RegExp _pattern;

  get name => 'pattern';

  NgModelPatternValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    if(_pattern != null && value != null && value.length > 0) {
      return _pattern.hasMatch(ngModel.viewValue);
    }

    //remember, only required validates for the input being empty
    return true;
  }

  @NgAttr('pattern')
  get pattern => _pattern;
  set pattern(val) {
    if(val != null && val.length > 0) {
      _pattern = new RegExp(val);
      listen();
    } else {
      _pattern = null;
      unlisten();
    }
  }
}

@NgDirective(selector: '[ng-model][minlength]')
@NgDirective(selector: '[ng-model][ng-minlength]', map: const {'ng-minlength': '=>minlength'})
class NgModelMinLengthValidator extends _NgModelValidator {
  int _minlength;

  get name => 'minlength';

  NgModelMinLengthValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    //remember, only required validates for the input being empty
    if(_minlength == 0 || value == null || value.length == 0) {
      return true;
    }
    return value.length >= _minlength;
  }

  @NgAttr('minlength')
  get minlength => _minlength;
  set minlength(value) {
    _minlength = value == null ? 0 : int.parse(value.toString());
  }
}

@NgDirective(selector: '[ng-model][maxlength]')
@NgDirective(selector: '[ng-model][ng-maxlength]', map: const {'ng-maxlength': '=>maxlength'})
class NgModelMaxLengthValidator extends _NgModelValidator {
  int _maxlength = 0;

  get name => 'maxlength';

  NgModelMaxLengthValidator(dom.Element inputElement, NgModel ngModel, Scope scope):
    super(inputElement, ngModel, scope) {
      listen();
    }

  bool isValid() {
    return _maxlength == 0 || (value == null ? 0 : value.length) <= _maxlength;
  }

  @NgAttr('maxlength')
  get maxlength => _maxlength;
  set maxlength(value) {
    int length = value == null ? 0 : int.parse(value.toString());
    if(length != maxlength) {
      _maxlength = length;
    }
  }
}
