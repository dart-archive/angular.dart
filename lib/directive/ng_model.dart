part of angular.directive;

/**
 * NgModelConverter is the class interface for performing transformations on
 * the viewValue and modelValue properties on a model. A new converter can be created
 * by implementing the NgModelConverter class and then attaching to a model via the
 * provided setter.
 */
abstract class NgModelConverter {
  String get name;
  parse(value) => value;
  format(value) => value;
}

class _NoopModelConverter extends NgModelConverter {
  final name = 'ng-noop';
}

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
@Decorator(selector: '[ng-model]')
class NgModel extends NgControl implements AttachAware {
  final Scope _scope;

  BoundSetter setter = (_, [__]) => null;

  String _expression;
  var _originalValue, _viewValue, _modelValue;
  bool _alwaysProcessViewValue;
  bool _toBeValidated = false;
  Function render = (value) => null;

  final _validators = <NgValidator>[];
  NgModelConverter _converter;
  Watch _watch;
  bool _watchCollection;

  NgModel(this._scope, NgElement element, Injector injector, NodeAttrs attrs,
          Animate animate)
      : super(element, injector, animate)
  {
    _expression = attrs["ng-model"];
    watchCollection = false;

    //Since the user will never be editing the value of a select element then
    //there is no reason to guard the formatter from changing the DOM value.
    _alwaysProcessViewValue = element.node.tagName == 'SELECT';
    converter = new _NoopModelConverter();
    markAsUntouched();
    markAsPristine();
  }

  void _processViewValue(value) {
    validate();
    _viewValue = converter.format(value);
    _scope.rootScope.domWrite(() => render(_viewValue));
  }

  void attach() {
    watchCollection = false;
  }

  /**
    * Resets the model value to it's original (pristine) value. If the model has been interacted
    * with by the user at all then the model will be also reset to an "untouched" state.
    */
  void reset() {
    markAsUntouched();
    _processViewValue(_originalValue);
    modelValue = _originalValue;
  }

  void onSubmit(bool valid) {
    super.onSubmit(valid);
    if (valid) _originalValue = modelValue;
  }

  void markAsUntouched() {
    removeInfoState(this, NgControl.NG_TOUCHED);
  }

  void markAsTouched() {
    addInfoState(this, NgControl.NG_TOUCHED);
  }

  void markAsPristine() {
    removeInfoState(this, NgControl.NG_DIRTY);
  }

  void markAsDirty() {
    addInfoState(this, NgControl.NG_DIRTY);
  }

  /**
    * Flags the model to be set for validation upon the next digest. This operation is useful
    * to optimize validations incase multiple validations are triggered one after the other.
    */
  void validateLater() {
    if (_toBeValidated) return;
    _toBeValidated = true;
    _scope.rootScope.runAsync(() {
      if (_toBeValidated) {
        validate();
      }
    });
  }

  /**
    * Returns the associated converter that is used with the model.
    */
  NgModelConverter get converter => _converter;
  set converter(NgModelConverter c) {
    _converter = c;
    _processViewValue(modelValue);
  }

  @NgAttr('name')
  String get name => _name;
  void set name(value) {
    _name = value;
    _parentControl.addControl(this);
  }

  // TODO(misko): could we get rid of watch collection, and just always watch the collection?
  bool get watchCollection => _watchCollection;
  void set watchCollection(value) {
    if (_watchCollection == value) return;

    var onChange = (value, [_]) {
      if (_alwaysProcessViewValue || _modelValue != value) {
        _modelValue = value;
        _processViewValue(value);
      }
    };

    _watchCollection = value;
    if (_watch!=null) _watch.remove();
    if (_watchCollection) {
      _watch = _scope.watch(_expression, (changeRecord, _) {
            onChange(changeRecord is CollectionChangeRecord
                        ? changeRecord.iterable
                        : changeRecord);
          },
          collection: true);
    } else if (_expression != null) {
      _watch = _scope.watch(_expression, onChange);
    }
  }

  // TODO(misko): getters/setters need to go. We need AST here.
  @NgCallback('ng-model')
  void set model(BoundExpression boundExpression) {
    setter = boundExpression.assign;
    _scope.rootScope.runAsync(() {
      _modelValue = boundExpression();
      _originalValue = modelValue;
      _processViewValue(_modelValue);
    });
  }

  /**
    * Applies the given [error] to the model.
    */
  void addError(String error) {
    this.addErrorState(this, error);
  }

  /**
    * Removes the given [error] from the model.
    */
  void removeError(String error) {
    this.removeErrorState(this, error);
  }

  /**
    * Adds the given [info] state to the model.
    */
  void addInfo(String info) {
    this.addInfoState(this, info);
  }

  /**
    * Removes the given [info] state from the model.
    */
  void removeInfo(String info) {
    this.removeInfoState(this, info);
  }

  get viewValue => _viewValue;
  void set viewValue(value) {
    _viewValue = value;
    modelValue = value;
  }

  get modelValue => _modelValue;
  void set modelValue(value) {
    try {
      value = converter.parse(value);
    } catch(e) {
      value = null;
    }
    _modelValue = value;
    setter(value);

    if (modelValue == _originalValue) {
      markAsPristine();
    } else {
      markAsDirty();
    }
  }

  /**
    * Returns the list of validators that are registered on the model.
    */
  List<NgValidator> get validators => _validators;

  /**
   * Executes a validation on the model against each of the validators present on the model.
   * Once complete, the model will either be set as valid or invalid.
   */
  void validate() {
    _toBeValidated = false;
    if (validators.isNotEmpty) {
      validators.forEach((validator) {
        if (validator.isValid(modelValue)) {
          removeError(validator.name);
        } else {
          addError(validator.name);
        }
      });
    }

    if (invalid) {
      addInfo(NgControl.NG_INVALID);
    } else {
      removeInfo(NgControl.NG_INVALID);
    }
  }

  /**
   * Registers a validator into the model to consider when running validate().
   */
  void addValidator(NgValidator v) {
    validators.add(v);
    validateLater();
  }

  /**
   * De-registers a validator from the model.
   */
  void removeValidator(NgValidator v) {
    validators.remove(v);
    validateLater();
  }
}

/**
 * Usage:
 *
 *     <input type="checkbox"
 *            ng-model="expr"
 *            [ng-true-value="t_expr"]
 *            [ng-false-value="f_expr"]
 *            >
 *
 * This creates a two way databinding between the `ng-model` expression
 * and the checkbox input element state.
 *
 * If the optional `ng-true-value` is absent then: if the model expression
 * evaluates to true or to a nonzero [:num:], then the checkbox is checked;
 * otherwise, it is unchecked.
 *
 * If `ng-true-value="t_expr"` is present, then: if the model expression
 * evaluates to the same value as `t_expr` then the checkbox is checked;
 * otherwise, it is unchecked.
 *
 * When the checkbox is checked, the model is set to the value of `t_expr` if
 * present, true otherwise. When unchecked, it is set to the value of
 * `f_expr` if present, false otherwise.
 *
 * Also see [NgTrueValue] and [NgFalseValue].
 */
@Decorator(selector: 'input[type=checkbox][ng-model]')
class InputCheckbox {
  final dom.CheckboxInputElement inputElement;
  final NgModel ngModel;
  final NgTrueValue ngTrueValue;
  final NgFalseValue ngFalseValue;
  final Scope scope;

  InputCheckbox(dom.Element this.inputElement, this.ngModel,
                this.scope, this.ngTrueValue, this.ngFalseValue) {
    ngModel.render = (value) {
      scope.rootScope.domWrite(() {
        inputElement.checked = ngTrueValue.isValue(value);
      });
    };
    inputElement
        ..onChange.listen((_) {
          ngModel.viewValue = inputElement.checked
              ? ngTrueValue.value : ngFalseValue.value;
        })
        ..onBlur.listen((e) {
          ngModel.markAsTouched();
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
 * (both `<input>` and `<textarea>`) so long as the ng-model attribute is
 * present on the input element. Whenever the value of the input element
 * changes then the matching model property on the scope will be updated
 * as well as the other way around (when the scope property is updated).
 *
 */
@Decorator(selector: 'textarea[ng-model]')
@Decorator(selector: 'input[type=text][ng-model]')
@Decorator(selector: 'input[type=password][ng-model]')
@Decorator(selector: 'input[type=url][ng-model]')
@Decorator(selector: 'input[type=email][ng-model]')
@Decorator(selector: 'input[type=search][ng-model]')
class InputTextLike {
  final dom.Element inputElement;
  final NgModel ngModel;
  final Scope scope;
  String _inputType;

  get typedValue => (inputElement as dynamic).value;
  void set typedValue(value) {
    (inputElement as dynamic).value = (value == null) ? '' : value.toString();
  }

  InputTextLike(this.inputElement, this.ngModel, this.scope) {
    ngModel.render = (value) {
      scope.rootScope.domWrite(() {
        if (value == null) value = '';

        var currentValue = typedValue;
        if (value != currentValue && !(value is num && currentValue is num &&
            value.isNaN && currentValue.isNaN)) {
          typedValue =  value;
        }
      });
    };
    inputElement
        ..onChange.listen(processValue)
        ..onInput.listen(processValue)
        ..onBlur.listen((e) {
          ngModel.markAsTouched();
        });
  }

  void processValue([_]) {
    var value = typedValue;
    if (value != ngModel.viewValue) ngModel.viewValue = value;
    ngModel.validate();
  }
}

/**
 * Usage:
 *
 *     <input type="number|range" ng-model="myModel">
 *
 * Model:
 *
 *     num myModel;
 *
 * This creates a two-way binding between the input and the named model property
 * (e.g., myModel in the example above). When processing the input, its value is
 * read as a [:num:], via the [dom.InputElement.valueAsNumber] field. If the
 * input text does not represent a number, then the model is appropriately set
 * to [double.NAN]. Setting the model property to [null] will clear the input.
 * Setting the model to [double.NAN] will have no effect (input will be left
 * unchanged).
 */
@Decorator(selector: 'input[type=number][ng-model]')
@Decorator(selector: 'input[type=range][ng-model]')
class InputNumberLike {
  final dom.InputElement inputElement;
  final NgModel ngModel;
  final Scope scope;


  // We can't use [inputElement.valueAsNumber] due to http://dartbug.com/15788
  num get typedValue => num.parse(inputElement.value, (v) => double.NAN);

  void set typedValue(num value) {
    // [chalin, 2014-02-16] This post
    // http://lists.whatwg.org/pipermail/whatwg-whatwg.org/2010-January/024829.html
    // suggests that setting `valueAsNumber` to null should clear the field, but
    // it does not. [TODO: put BUG/ISSUE number here].  We implement a
    // workaround by setting `value`. Clean-up once the bug is fixed.
    if (value == null) {
      inputElement.value = null;
    } else {
      // We can't use inputElement.valueAsNumber due to http://dartbug.com/15788
      inputElement.value = "$value";
    }
  }

  InputNumberLike(dom.Element this.inputElement, this.ngModel, this.scope) {
    ngModel.render = (value) {
      scope.rootScope.domWrite(() {
        if (value != typedValue
            && (value == null || value is num && !value.isNaN)) {
          typedValue = value;
        }
      });
    };
    inputElement
        ..onChange.listen(relaxFnArgs(processValue))
        ..onInput.listen(relaxFnArgs(processValue))
        ..onBlur.listen((e) {
          ngModel.markAsTouched();
        });
  }

  void processValue() {
    num value = typedValue;
    if (value != ngModel.viewValue) {
      scope.eval(() => ngModel.viewValue = value);
    }
    ngModel.validate();
  }
}

/**
 * This directive affects which IDL attribute will be used to read the value of
 * date/time related input directives. Recognized values for this directive are:
 *
 * - [DATE]: [dom.InputElement].valueAsDate will be read.
 * - [NUMBER]: [dom.InputElement].valueAsNumber will be read.
 * - [STRING]: [dom.InputElement].value will be read.
 *
 * The default is [DATE]. Use other settings, e.g., when an app needs to support
 * browsers that treat date-like inputs as text (in such a case the [STRING]
 * kind would be appropriate) or, for browsers that fail to conform to the
 * HTML5 standard in their processing of date-like inputs.
 */
@Decorator(selector: 'input[type=date][ng-model][ng-bind-type]')
@Decorator(selector: 'input[type=time][ng-model][ng-bind-type]')
@Decorator(selector: 'input[type=datetime][ng-model][ng-bind-type]')
@Decorator(selector: 'input[type=datetime-local][ng-model][ng-bind-type]')
@Decorator(selector: 'input[type=month][ng-model][ng-bind-type]')
@Decorator(selector: 'input[type=week][ng-model][ng-bind-type]')
class NgBindTypeForDateLike {
  static const DATE = 'date';
  static const NUMBER = 'number';
  static const STRING = 'string';
  static const DEFAULT = DATE;
  static const VALID_VALUES = const <String>[DATE, NUMBER, STRING];

  final dom.InputElement inputElement;
  String _idlAttrKind = DEFAULT;

  NgBindTypeForDateLike(dom.Element this.inputElement);

  @NgAttr('ng-bind-type')
  void set idlAttrKind(final String _kind) {
    String kind = _kind == null ? DEFAULT : _kind.toLowerCase();
    if (!VALID_VALUES.contains(kind))
      throw "Unsupported ng-bind-type attribute value '$_kind'; "
            "it should be one of $VALID_VALUES";
    _idlAttrKind = kind;
  }

  String get idlAttrKind => _idlAttrKind;

  dynamic get inputTypedValue {
    switch (idlAttrKind) {
      case DATE:   return inputValueAsDate;
      case NUMBER: return inputElement.valueAsNumber;
      default:     return inputElement.value;
    }
  }

  void set inputTypedValue(dynamic inputValue) {
    if (inputValue is DateTime) {
      inputValueAsDate = inputValue;
    } else if (inputValue is num) {
      inputElement.valueAsNumber = inputValue;
    } else {
      inputElement.value = inputValue;
    }
  }

  /// Input's `valueAsDate` normalized to UTC (per HTML5 std).
  DateTime get inputValueAsDate {
    DateTime dt;
    // Wrap in try-catch due to
    // https://code.google.com/p/dart/issues/detail?id=17625
    try {
      dt = inputElement.valueAsDate;
    } catch (e) {
      dt = null;
    }
    return (dt != null && !dt.isUtc) ? dt.toUtc() : dt;
  }

  /// Set input's `valueAsDate`. Argument is normalized to UTC if necessary
  /// (per HTML standard).
  void set inputValueAsDate(DateTime dt) {
    inputElement.valueAsDate = (dt != null && !dt.isUtc) ? dt.toUtc() : dt;
  }
}

/**
 * **Background: Standards and Browsers**
 *
 * According to the
 * [HTML5 Standard](http://www.w3.org/TR/html5/forms.html#the-input-element),
 * the [dom.InputElement.valueAsDate] and [dom.InputElement.valueAsNumber] IDL
 * attributes should be available for all date/time related input types,
 * except for `datetime-local` which is limited to
 * [dom.InputElement.valueNumber]. Of course, all input types support
 * [dom.InputElement.value] which yields a [String];
 * [dom.InputElement.valueAsDate] yields a [DateTime] and
 * [dom.InputElement.valueNumber] yields a [num].
 *
 * But not all browsers currently support date/time related inputs and of
 * those that do, some deviate from the standard. Hence, this directive
 * allows developers to control the IDL attribute that will be used
 * to read the value of a date/time input. This is achieved via the subordinate
 * 'ng-bind-type' directive; see [NgBindTypeForDateLike] for details.
 *
 * **Usage**:
 *
 *     <input type="date|datetime|datetime-local|month|time|week"
 *            [ng-bind-type="date"]
 *            ng-model="myModel">
 *
 * **Model**:
 *
 *     dynamic myModel; // one of DateTime | num | String
 *
 * This directive creates a two-way binding between the input and a model
 * property. The subordinate 'ng-bind-type' directive determines which input
 * IDL attribute is read (see [NgBindTypeForDateLike] for details) and
 * hence the type of the read values. The type of the model property value
 * determines which IDL attribute is written to: [DateTime] and [num] values
 * are assigned to [dom.InputElement.valueAsDate] and
 * [dom.InputElement.valueNumber], respectively; [String] and `null` values
 * are assigned to [dom.InputElement.value]. Setting the model to `null` will
 * clear the input if it is currently valid, otherwise, invalid input is left
 * untouched (so that the user has an opportunity to correct it). To clear the
 * input unconditionally, set the model property to the empty string ('').
 *
 * **Notes**:
 * - As prescribed by the HTML5 standard, [DateTime] values returned by the
 *   `valueAsDate` IDL attribute are meant to be in UTC.
 * - As of the HTML5 Editor's Draft 29 March 2014, datetime-local is no longer
 *   part of the standard. Other date related input are also at risk of being
 *   dropped.
 */

@Decorator(selector: 'input[type=date][ng-model]',
    module: InputDateLike.moduleFactory)
@Decorator(selector: 'input[type=time][ng-model]',
    module: InputDateLike.moduleFactory)
@Decorator(selector: 'input[type=datetime][ng-model]',
    module: InputDateLike.moduleFactory)
@Decorator(selector: 'input[type=datetime-local][ng-model]',
    module: InputDateLike.moduleFactory)
@Decorator(selector: 'input[type=month][ng-model]',
    module: InputDateLike.moduleFactory)
@Decorator(selector: 'input[type=week][ng-model]',
    module: InputDateLike.moduleFactory)
class InputDateLike {
  static Module moduleFactory() => new Module()..factory(NgBindTypeForDateLike,
      (Injector i) => new NgBindTypeForDateLike(i.get(dom.Element)));
  final dom.InputElement inputElement;
  final NgModel ngModel;
  final Scope scope;
  NgBindTypeForDateLike ngBindType;

  InputDateLike(dom.Element this.inputElement, this.ngModel, this.scope,
      this.ngBindType) {
    if (inputElement.type == 'datetime-local') {
      ngBindType.idlAttrKind = NgBindTypeForDateLike.NUMBER;
    }
    ngModel.render = (value) {
      scope.rootScope.domWrite(() {
        if (!eqOrNaN(value, typedValue)) typedValue = value;
      });
    };
    inputElement
        ..onChange.listen(relaxFnArgs(processValue))
        ..onInput.listen(relaxFnArgs(processValue))
        ..onBlur.listen((e) {
          ngModel.markAsTouched();
        });
  }

  dynamic get typedValue => ngBindType.inputTypedValue;

  void set typedValue(dynamic value) {
    ngBindType.inputTypedValue = value;
  }

  void processValue() {
    var value = typedValue;
    // print("processValue: value=$value, model=${ngModel.viewValue}");
    if (!eqOrNaN(value, ngModel.viewValue)) {
      scope.eval(() => ngModel.viewValue = value);
    }
    ngModel.validate();
  }
}

class _UidCounter {
  static final int CHAR_0 = "0".codeUnitAt(0);
  static final int CHAR_9 = "9".codeUnitAt(0);
  static final int CHAR_A = "A".codeUnitAt(0);
  static final int CHAR_Z = "Z".codeUnitAt(0);
  final charCodes = [CHAR_0, CHAR_0, CHAR_0];

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
 *     <input type=radio ng-model=model [ng-value=expr]>
 *
 *     <option [ng-value=expr]>...</option>
 *
 * Example:
 *
 *     <select ng-model="robot">
 *       <option ng-repeat="r in robots" ng-value="r">{{r.name}}</option>
 *     </select>
 *
 * When present, the value of this `ng-value` one-way attribute is assigned to
 * the `ng-model` property when the corresponding radio element or option is
 * selected. Note that `expr` can be not any type; i.e., it is not restricted
 * to [String].
 */
@Decorator(selector: 'input[type=radio][ng-model][ng-value]')
@Decorator(selector: 'option[ng-value]')
class NgValue {
  static Module _module = new Module()..type(NgValue);
  static Module moduleFactory() => _module;

  final dom.Element element;
  var _value;

  NgValue(this.element);

  @NgOneWay('ng-value')
  void set value(val) { this._value = val; }
  dynamic get value => _value == null ? (element as dynamic).value : _value;
}

/**
 * Usage:
 *
 *     <input type=checkbox
 *            ng-model=model
 *            [ng-true-value=expr]>
 *
 * The initial value of the expression bound to this directive is assigned to
 * the model when the input is checked. Note that the expression can be of any
 * type, not just [String]. Also see [InputCheckboxDirective], [NgFalseValue].
 */
@Decorator(selector: 'input[type=checkbox][ng-model][ng-true-value]')
class NgTrueValue {
  final dom.Element element;
  @NgOneWay('ng-true-value')
  var value = true;

  NgTrueValue([this.element]);

  bool isValue(val) => element == null ? toBool(val) : val == value;
}

/**
 * Usage:
 *
 *     <input type=checkbox
 *            ng-model=model
 *            [ng-false-value=expr]>
 *
 * The initial value of the expression bound to this directive is assigned to
 * the model when the input is unchecked. Note that the expression can be of any
 * type, not just [String]. Also see [InputCheckboxDirective], [NgTrueValue].
 */
@Decorator(selector: 'input[type=checkbox][ng-model][ng-false-value]')
class NgFalseValue {
  final dom.Element element;
  @NgOneWay('ng-false-value')
  var value = false;

  NgFalseValue([this.element]);
}

/**
 * Usage:
 *
 *     <input type="radio" ng-model="category">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the range input elements in the DOM. If the ng-model value is
 * set to a value not corresponding to one of the radio elements, then none of
 * the radio elements will be check.  Otherwise, only the corresponding input
 * element in the group is checked.  Likewise, when a radio button element is
 * checked, the model is updated with its value.  Radio buttons that have a
 * `name` attribute are left alone.  Those that are missing the attribute will
 * have a unique `name` assigned to them.  This sequence goes `001`,  `001`, ...
 * `009`, `00A`, `00Z`, `010`, and so on using more than 3 characters for the
 * name when the counter overflows.
 */
@Decorator(
    selector: 'input[type=radio][ng-model]',
    module: NgValue.moduleFactory)
class InputRadio {
  final dom.RadioButtonInputElement radioButtonElement;
  final NgModel ngModel;
  final NgValue ngValue;
  final Scope scope;

  InputRadio(dom.Element this.radioButtonElement, this.ngModel,
             this.scope, this.ngValue, NodeAttrs attrs) {
    // If there's no "name" set, we'll set a unique name.  This ensures
    // less surprising behavior about which radio buttons are grouped together.
    if (attrs['name'] == '' || attrs['name'] == null) {
      attrs["name"] = _uidCounter.next();
    }
    ngModel.render = (value) {
      scope.rootScope.domWrite(() {
        radioButtonElement.checked = (value == ngValue.value);
      });
    };
    radioButtonElement
        ..onClick.listen((_) {
          if (radioButtonElement.checked) ngModel.viewValue = ngValue.value;
        })
        ..onBlur.listen((e) {
          ngModel.markAsTouched();
        });
  }
}

/**
 * Usage (span could be replaced with any element which supports text content, such as `p`):
 *
 *     <span contenteditable= ng-model="name">
 *
 * This creates a two way databinding between the expression specified in
 * ng-model and the html element in the DOM. If the ng-model value is
 * `null`, it is treated as equivalent to the empty string for rendering
 * purposes.
 */
@Decorator(selector: '[contenteditable][ng-model]')
class ContentEditable extends InputTextLike {
  ContentEditable(dom.Element inputElement, NgModel ngModel, Scope scope)
      : super(inputElement, ngModel, scope);

  // The implementation is identical to InputTextLike but use innerHtml instead of value
  String get typedValue => (inputElement as dynamic).innerHtml;
  void set typedValue(String value) {
    (inputElement as dynamic).innerHtml = (value == null) ? '' : value;
  }
}
