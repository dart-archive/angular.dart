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
class NgModel extends NgControl implements NgAttachAware {
  BoundGetter getter = ([_]) => null;
  BoundSetter setter = (_, [__]) => null;

  var _lastValue; 
  String _exp;
  final _validators = <NgValidatable>[];

  bool _watchCollection;
  Function _removeWatch = () => null;
  Function render = (value) => null;

  NgModel(Scope scope, NodeAttrs attrs, dom.Element element, Injector injector) :
    super(scope, element, injector) {
    _exp = 'ng-model=${attrs["ng-model"]}';
  }


  attach() {
    watchCollection = false;
    _scope.$on('resetNgModel', reset);
  }

  reset() {
    modelValue = _lastValue;
  }

  @NgAttr('name')
  get name => _name;
  set name(value) {
    _name = value;
    _parentControl.addControl(this);
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

    _scope.$evalAsync((value) {
      _lastValue = modelValue;
    });
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
    if (validators.isNotEmpty) {
      validators.forEach((validator) {
        setValidity(validator.name, validator.isValid(viewValue));
      });
    } else {
      valid = true;
    }
  }

  setValidity(String name, bool valid) {
    this.updateControlValidity(this, name, valid);
  }

  /**
   * Registers a validator into the model to consider when running validate().
   */
  addValidator(NgValidatable v) {
    validators.add(v);
    validate();
  }

  /**
   * De-registers a validator from the model.
   */
  removeValidator(NgValidatable v) {
    validators.remove(v);
    validate();
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
 */
@NgDirective(selector: 'input[type=checkbox][ng-model]')
class InputCheckboxDirective {
  final dom.InputElement inputElement;
  final NgModel ngModel;
  final NgTrueValue ngTrueValue;
  final NgFalseValue ngFalseValue;
  final Scope scope;

  InputCheckboxDirective(dom.Element this.inputElement, this.ngModel,
                         this.scope, this.ngTrueValue, this.ngFalseValue) {
    ngModel.render = (value) {
      inputElement.checked = ngTrueValue.isValue(inputElement, value);
    };
    inputElement.onChange.listen((value) {
      scope.$apply(() {
        ngModel.viewValue = inputElement.checked
            ? ngTrueValue.readValue(inputElement)
            : ngFalseValue.readValue(inputElement);
      });
    });
  }
}

/**
 * Usage:
 *
 *     <input type="text|url|password|email" ng-model="myModel">
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
        ..onInput.listen((e) {
          processValue();
        });
  }

  processValue() {
    var value = typedValue;
    if (value != ngModel.viewValue) {
      ngModel.dirty = true;
      scope.$apply(() => ngModel.viewValue = value);
    }
    ngModel.validate();
  }
}

/**
 * Usage:
 *
 *     <input type="number|range" ng-model="myModel">
 *
 * This creates a two-way binding between a number-based input element
 * so long as the ng-model attribute is present on the input element. Whenever
 * the value of the input element changes then the matching model property on the
 * scope will be updated as well as the other way around (when the scope property
 * is updated).
 *
 */
@NgDirective(selector: 'input[type=number][ng-model]')
@NgDirective(selector: 'input[type=range][ng-model]')
class InputNumberLikeDirective {
  final dom.InputElement inputElement;
  final NgModel ngModel;
  final Scope scope;

  InputNumberLikeDirective(dom.Element this.inputElement, this.ngModel, this.scope) {
    ngModel.render = (value) {
      inputElement.value = value == null ? '' : value.toString();
    };
    inputElement
        ..onChange.listen(relaxFnArgs(processValue))
        ..onInput.listen(relaxFnArgs(processValue));
  }

  processValue() {
    var value = num.parse(inputElement.value, (_) => null);
    if (value != ngModel.viewValue) {
      ngModel.dirty = true;
      scope.$apply(() => ngModel.viewValue = value);
    }
    ngModel.validate();
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
 * Use `ng-value` directive with `<input type="radio">` or `<option>` to
 * allow binding to values other then strings. This is needed since the
 * `value` attribute on DOM element `<input type="radio" value="foo">` can
 * only be a string. With `ng-value` one can bind to any object.
 */
@NgDirective(selector: '[ng-value]')
class NgValue {
  final dom.Element element;
  @NgOneWay('ng-value')
  var value;

  NgValue(this.element);

  readValue(dom.Element element) {
    assert(this.element == null || element == this.element);
    return this.element == null ? (element as dynamic).value : value;
  }
}

/**
 * `ng-true-value` allows you to select any expression to be set to
 * `ng-model` when checkbox is selected on `<input type="checkbox">`.
 */
@NgDirective(selector: '[ng-true-value]')
class NgTrueValue {
  final dom.Element element;
  @NgOneWay('ng-true-value')
  var value;

  NgTrueValue(this.element);

  readValue(dom.Element element) {
    assert(this.element == null || element == this.element);
    return this.element == null ? true : value;
  }

  isValue(dom.Element element, value) {
    assert(this.element == null || element == this.element);
    return this.element == null ? toBool(value) : value == this.value;
  }
}

/**
 * `ng-false-value` allows you to select any expression to be set to
 * `ng-model` when checkbox is deselected<input type="checkbox">`.
 */
@NgDirective(selector: '[ng-false-value]')
class NgFalseValue {
  final dom.Element element;
  @NgOneWay('ng-false-value')
  var value;

  NgFalseValue(this.element);

  readValue(dom.Element element) {
    assert(this.element == null || element == this.element);
    return this.element == null ? false : value;
  }
}

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
  final NgValue ngValue;
  final Scope scope;

  InputRadioDirective(dom.Element this.radioButtonElement, this.ngModel,
                      this.scope, this.ngValue, NodeAttrs attrs) {
    // If there's no "name" set, we'll set a unique name.  This ensures
    // less surprising behavior about which radio buttons are grouped together.
    if (attrs['name'] == '' || attrs['name'] == null) {
      attrs["name"] = _uidCounter.next();
    }
    ngModel.render = (value) {
      radioButtonElement.checked = (value == ngValue.readValue(radioButtonElement));
    };
    radioButtonElement.onClick.listen((_) {
      if (radioButtonElement.checked) {
        scope.$apply(() => ngModel.viewValue = ngValue.readValue(radioButtonElement));
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
