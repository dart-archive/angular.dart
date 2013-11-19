part of angular.directive;

/**
 * Ng-model directive is responsible for reading/writing to the model.
 * The directive itself is headless. (It does not know how to render or what
 * events to listen for.) It is meant to be used with other directives which
 * provide the rendering and listening capabilities. The directive itself
 * knows how to convert the view-value into model-value and vice versa by
 * allowing others to register converters (To be implemented). It also
 * knwos how to (in)validate the model and the form in which it is declared
 * (to be implemented)
 */
@NgDirective(
    selector: '[ng-model]',
    map: const {'ng-model': '&model'})
class NgModel {
  final Scope _scope;

  Getter getter = ([_]) => null;
  Setter setter = (_, [__]) => null;
  String _exp;


  Function _removeWatch = () => null;
  bool _watchCollection;

  Function render = (value) => null;

  NgModel(Scope this._scope, NodeAttrs attrs) {
    _exp = 'ng-model=${attrs["ng-model"]}';
    watchCollection = false;
  }

  get watchCollection => _watchCollection;
  set watchCollection(value) {
    if (_watchCollection == value) return;
    _watchCollection = value;
    _removeWatch();
    if (_watchCollection) {
      _removeWatch = _scope.$watchCollection((s) => getter(), (value) => render(value), _exp);
    } else {
      _removeWatch = _scope.$watch((s) => getter(), (value) => render(value), _exp);
    }
  }

  set model(BoundExpression boundExpression) {
    getter = boundExpression;
    setter = boundExpression.assign;
  }

  // TODO(misko): right now viewValue and modelValue are the same,
  // but this needs to be changed to support converters and form validation
  get viewValue        => modelValue;
  set viewValue(value) => modelValue = value;

  get modelValue        => getter();
  set modelValue(value) => setter(value);
}

/**
 * Usage:
 *
 *     <input type="checkbox" ng-model="flag">
 *
 * This creates a two way databinding between the boolean expression specified in
 * ng-model and the checkbox input element in the DOM.  If the ng-model value is
 * falsy (i.e. one of `false`, `null`, and `0`), then the checkbox is unchecked.
 * Otherwise, it is checked.  Likewise, when the checkbox is checked, the model
 * value is set to true.  When unchecked, it is set to false.
 *
 * The AngularJS style ng-true-value / ng-false-value is not supported.
 */
@NgDirective(selector: 'input[type=checkbox][ng-model]')
class InputCheckboxDirective {
  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;

  InputCheckboxDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      inputElement.checked = value == null ? false : toBool(value);
    };
    inputElement.onChange.listen((value) {
      scope.$apply(() => ngModel.viewValue = inputElement.checked);
    });
  }
}


abstract class _InputTextlikeDirective {
  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;

  // override in subclass
  get typedValue;
  set typedValue(value);

  _InputTextlikeDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      if (value == null) value = '';

      var currentValue = typedValue;
      if (value == currentValue || (value is num && currentValue is num && value.isNaN && currentValue.isNaN)) return;
      var start = inputElement.selectionStart;
      var end = inputElement.selectionEnd;
      typedValue =  value;
      inputElement.selectionStart = start;
      inputElement.selectionEnd = end;
    };
    inputElement.onChange.listen(relaxFnArgs(processValue));
    inputElement.onKeyDown.listen((e) {
      new async.Timer(Duration.ZERO, processValue);
      scope.$skipAutoDigest();
    });
  }

  processValue() {
    var value = typedValue;
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}

/**
 * Usage:
 *
 *     <input type="text" ng-model="name">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the text input element in the DOM.  If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@NgDirective(selector: 'input[type=text][ng-model]')
class InputTextDirective extends _InputTextlikeDirective {
  InputTextDirective(dom.Element inputElement, NgModel ngModel, Scope scope):
      super(inputElement, ngModel, scope);

  String get typedValue => inputElement.value;
  set typedValue(String value) {
    inputElement.value = (value == null) ? '' : value;
  }
}

/**
 * Usage:
 *
 *     <textarea ng-model="text">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the textarea element in the DOM.  If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@NgDirective(selector: 'textarea[ng-model]')
class TextAreaDirective {
  dom.TextAreaElement textAreaElement;
  NgModel ngModel;
  Scope scope;

  TextAreaDirective(dom.Element this.textAreaElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      if (value == null) value = '';

      var currentValue = textAreaElement.value;
      if (value == currentValue) return;
      var start = textAreaElement.selectionStart;
      var end = textAreaElement.selectionEnd;
      textAreaElement.value =  value;
      textAreaElement.selectionStart = start;
      textAreaElement.selectionEnd = end;
    };
    textAreaElement.onChange.listen(relaxFnArgs(processValue));
    textAreaElement.onKeyDown.listen((e) => new async.Timer(Duration.ZERO, processValue));
  }

  processValue() {
    var value = textAreaElement.value;
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}

/**
 * Usage:
 *
 *     <input type="number" ng-model="name">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the number input element in the DOM.  If the ng-model value is
 * `null` or `NaN`, the DOM element is not updated.  If the value in the DOM
 * element is an invalid number, then the expression specified by the `ng-model`
 * is set to null.,
 */
@NgDirective(selector: 'input[type=number][ng-model]')
class InputNumberDirective extends _InputTextlikeDirective {
  InputNumberDirective(dom.Element inputElement, NgModel ngModel, Scope scope):
      super(inputElement, ngModel, scope);

  num get typedValue => inputElement.valueAsNumber;

  set typedValue(var value) {
    if (value != null && value is num) {
      num number = value as num;
      if (!value.isNaN) {
        inputElement.valueAsNumber = value;
      }
    }
  }
}

/**
 * Usage:
 *
 *     <input type="email" ng-model="emailAddress">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the email input element in the DOM.  If the ng-model value is
 * `null`, the DOM element is not updated.  If the value in the DOM element is
 * an invalid e-mail address, then the expression specified by the `ng-model` is
 * set to null.,
 */
@NgDirective(selector: 'input[type=email][ng-model]')
class InputEmailDirective extends _InputTextlikeDirective {
  static final EMAIL_REGEXP = new RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$');
  InputEmailDirective(dom.Element inputElement, NgModel ngModel, Scope scope):
      super(inputElement, ngModel, scope);

  String get typedValue {
    String value = inputElement.value;
    return EMAIL_REGEXP.hasMatch(value) ? value : null;
  }

  set typedValue(String value) {
    if (value != null && EMAIL_REGEXP.hasMatch(value)) {
      inputElement.value = value;
    }
  }
}


/**
 * Usage:
 *
 *     <input type="url" ng-model="website">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the `url` input element in the DOM.  If the ng-model value is
 * `null`, the DOM element is not updated.  If the value in the DOM element is
 * an invalid URL, then the expression specified by the `ng-model` is set to
 * null.,
 */
@NgDirective(selector: 'input[type=url][ng-model]')
class InputUrlDirective extends _InputTextlikeDirective {
  static final URL_REGEXP = new RegExp(
      r'^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?' +
      r'(\/|\/([\w#!:.?+=&%@!\-\/]))?$');
  InputUrlDirective(dom.Element inputElement, NgModel ngModel, Scope scope):
      super(inputElement, ngModel, scope);

  String get typedValue {
    String value = inputElement.value;
    return URL_REGEXP.hasMatch(value) ? value : null;
  }

  set typedValue(String value) {
    if (value != null && URL_REGEXP.hasMatch(value)) {
      inputElement.value = value;
    }
  }
}

class _UidCounter {
  static final int CHAR_0 = "0".codeUnitAt(0);
  static final int CHAR_9 = "9".codeUnitAt(0);
  static final int CHAR_A = "A".codeUnitAt(0);
  static final int CHAR_Z = "Z".codeUnitAt(0);
  List charCodes = [CHAR_0, CHAR_0, CHAR_0];

  String next() {
    for (int i = charCodes.length-1; i >= 0; i--) {
      int code = charCodes[i];
      if (code == CHAR_9) {
        charCodes[i] = CHAR_A;
        return new String.fromCharCodes(charCodes);
      } else if (code == CHAR_Z) {
        charCodes[i] = CHAR_0;
      } else {
        charCodes[i] = code + 1;
        return new String.fromCharCodes(charCodes);
      }
    }
    charCodes.insert(0, CHAR_0);
    return new String.fromCharCodes(charCodes);
  }
}

final _uidCounter = new _UidCounter();


/**
 * Usage:
 *
 *     <input type="radio" ng-model="category">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the range input elements in the DOM.  If the ng-model value is
 * set to a value not corresponding to one of the radio elements, then none of
 * the radio elements will be check.  Otherwise, only the corresponding input
 * element in the group is checked.  Likewise, when a radio button element is
 * checked, the model is updated with its value.  Radio buttons that have a
 * `name` attribute are left alone.  Those that are missing the attribute will
 * have a unique `name` assigned to them.  This sequence goes `001`,  `001`, ...
 * `009`, `00A`, `00Z`, `010`, … and so on using more than 3 characters for the
 * name when the counter overflows.
 */
@NgDirective(selector: 'input[type=radio][ng-model]')
class InputRadioDirective {
  dom.RadioButtonInputElement radioButtonElement;
  NgModel ngModel;
  Scope scope;

  InputRadioDirective(dom.Element this.radioButtonElement, NgModel this.ngModel,
                      Scope this.scope, NodeAttrs attrs) {
    // If there's no "name" set, we'll set a unique name.  This ensures
    // less surprising behavior about which radio buttons are grouped together.
    if (attrs['name'] == '' || attrs['name'] == null) {
      attrs["name"] = _uidCounter.next();
    }
    ngModel.render = (String value) {
      radioButtonElement.checked = (value == radioButtonElement.value);
    };
    radioButtonElement.onClick.listen((_) {
      if (radioButtonElement.checked) {
        scope.$apply(() => ngModel.viewValue = radioButtonElement.value);
      }
    });
  }
}
