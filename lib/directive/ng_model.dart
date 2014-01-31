part of angular.directive;

/**
 * Ng-model directive is responsible for reading/writing to the model.
 * The directive itself is headless. (It does not know how to render or what
 * events to listen for.) It is meant to be used with other directives which
 * provide the rendering and listening capabilities. The directive itself
 * knows how to convert the view-value into model-value and vice versa by
 * allowing others to register converters (To be implemented). It also
 * knows how to (in)validate the model and the form in which it is declared
 * (to be implemented)
 */
@NgDirective(selector: '[ng-model]')
class NgModel extends NgControl {
  final NgForm _form;
  final dom.Element _element;
  final Scope _scope;

  Getter getter = ([_]) => null;
  Setter setter = (_, [__]) => null;

  String _exp;
  String _name;

  final List<_NgModelValidator> _validators = new List<_NgModelValidator>();
  final Map<String, bool> currentErrors = new Map<String, bool>();

  Function _removeWatch = () => null;
  bool _watchCollection;

  Function render = (value) => null;

  NgModel(this._scope, NodeAttrs attrs, [dom.Element this._element,
      NgForm this._form]) {
    _exp = 'ng-model=${attrs["ng-model"]}';
    watchCollection = false;

    _form.addControl(this);
    pristine = true;
  }

  get element => _element;

  @NgAttr('name')
  get name => _name;
  set name(value) {
    _name = value;
    _form.addControl(this);
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

  @NgCallback('ng-model')
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

  get validators => _validators;

  /**
   * Executes a validation on the form against each of the validation present on the model.
   */
  validate() {
    if(validators.isNotEmpty) {
      validators.forEach((validator) {
        setValidity(validator.name, validator.isValid());
      });
    } else {
      valid = true;
    }
  }

  /**
   * Sets the validity status of the given errorType on the model. Depending on if
   * valid or invalid, the matching CSS classes will be added/removed on the input
   * element associated with the model. If any errors exist on the model then invalid
   * will be set to true otherwise valid will be set to true.
   *
   * * [errorType] - The name of the error (e.g. required, url, number, etc...).
   * * [isValid] - Whether or not the given error is valid or not (false would mean the error is real).
   */
  setValidity(String errorType, bool isValid) {
    if(isValid) {
      if(currentErrors.containsKey(errorType)) {
        currentErrors.remove(errorType);
      }
      if(valid != true && currentErrors.isEmpty) {
        valid = true;
      }
    } else if(!currentErrors.containsKey(errorType)) {
      currentErrors[errorType] = true;
      invalid = true;
    }

    if(_form != null) {
      _form.setValidity(this, errorType, isValid);
    }
  }

  /**
   * Registers a validator into the model to consider when running validate().
   */
  addValidator(_NgModelValidator v) {
    validators.add(v);
    validate();
  }

  /**
   * De-registers a validator from the model.
   */
  removeValidator(_NgModelValidator v) {
    validators.remove(v);
    validate();
  }

  /**
   * Removes the model from the control/form.
   */
  destroy() {
    _form.removeControl(this);
  }
}

/**
 * Usage:
 *
 *     <input type="checkbox" ng-model="flag">
 *
 * This creates a two way databinding between the boolean expression specified
 * in ng-model and the checkbox input element in the DOM.  If the ng-model value
 * is falsy (i.e. one of `false`, `null`, and `0`), then the checkbox is
 * unchecked. Otherwise, it is checked.  Likewise, when the checkbox is checked,
 * the model value is set to true.  When unchecked, it is set to false.
 *
 * The AngularJS style ng-true-value / ng-false-value is not supported.
 */
@NgDirective(selector: 'input[type=checkbox][ng-model]')
class InputCheckboxDirective {
  final dom.InputElement inputElement;
  final NgModel ngModel;
  final Scope scope;

  InputCheckboxDirective(dom.Element this.inputElement, this.ngModel,
                         this.scope) {
    ngModel.render = (value) {
      inputElement.checked = value == null ? false : toBool(value);
    };
    inputElement.onChange.listen((value) {
      scope.$apply(() => ngModel.viewValue = inputElement.checked);
    });
  }
}

/**
 * Usage:
 *
 *     <input type="text|number|url|password|email" ng-model="myModel">
 *     <textarea ng-model="myModel"></textarea>
 *
 * This creates a two-way binding between any string-based input element
 * (both <input> and <textarea>) so long as the ng-model attribute is
 * present on the input element. Whenever the value of the input element
 * changes then the matching model property on the scope will be updated
 * as well as the other way around (when the scope property is updated).
 *
 */
@NgDirective(selector: 'textarea[ng-model]')
@NgDirective(selector: 'input[type=text][ng-model]')
@NgDirective(selector: 'input[type=password][ng-model]')
@NgDirective(selector: 'input[type=url][ng-model]')
@NgDirective(selector: 'input[type=email][ng-model]')
@NgDirective(selector: 'input[type=number][ng-model]')
@NgDirective(selector: 'input[type=search][ng-model]')
class InputTextLikeDirective {
  final dom.Element inputElement;
  final NgModel ngModel;
  final Scope scope;
  String _inputType;

  get typedValue => (inputElement as dynamic).value;
  set typedValue(value) => (inputElement as dynamic).value = (value == null) ?
      '' :
      value.toString();

  InputTextLikeDirective(this.inputElement, this.ngModel, this.scope) {
    ngModel.render = (value) {
      if (value == null) value = '';

      var currentValue = typedValue;
      if (value != currentValue && !(value is num && currentValue is num &&
          value.isNaN && currentValue.isNaN)) {
        typedValue =  value;
      }
    };
    inputElement
        ..onChange.listen(relaxFnArgs(processValue))
        ..onKeyDown.listen((e) {
          new async.Timer(Duration.ZERO, processValue);
          scope.$skipAutoDigest();
        });
  }

  processValue() {
    ngModel.validate();
    var value = typedValue;
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
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
    for (int i = charCodes.length - 1; i >= 0; i--) {
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
  final dom.RadioButtonInputElement radioButtonElement;
  final NgModel ngModel;
  final Scope scope;

  InputRadioDirective(dom.Element this.radioButtonElement, this.ngModel,
                      this.scope, NodeAttrs attrs) {
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

/**
 * Usage (span could be replaced with any element which supports text content, such as `p`):
 *
 *     <span contenteditable= ng-model="name">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the html element in the DOM.  If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@NgDirective(selector: '[contenteditable][ng-model]')
class ContentEditableDirective extends InputTextLikeDirective {
  ContentEditableDirective(dom.Element inputElement, NgModel ngModel,
                           Scope scope)
      : super(inputElement, ngModel, scope);

  // The implementation is identical to InputTextLikeDirective but use innerHtml instead of value
  get typedValue => (inputElement as dynamic).innerHtml;
  set typedValue(String value) =>
      (inputElement as dynamic).innerHtml = (value == null) ? '' : value;
}
