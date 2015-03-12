part of angular.directive;

/**
 * Modifies the behavior of the HTML `<select>` element to perform data binding between the
 * `option.value` attribute and the model. `Selector: select[ng-model]`
 *
 * An empty `option.value` is treated as null. If the model specifies a value which does not map
 * to an existing option,  a new unknown option is inserted into the list. Once the model again
 * points to an existing option, the unknown option is removed.
 *
 * # Example
 *     <select ng-model="robot">
 *       <option value="Marvin" selected>Marvin</option>
 *       <option value="Speedy">Speedy</option>
 *       <option value="Tik-Tok">Tik-Tok</option>
 *     </select>
 *
 * Note: The `option.value` attribute for the `<select>` element is defined as a string. To bind to
 * an object for `option.value`, see the [OptionValue] directive.
 */
@Decorator(
    selector: 'select[ng-model]',
    visibility: Visibility.CHILDREN)
class InputSelect implements AttachAware {
  final options = new Expando<OptionValue>();
  final dom.SelectElement _selectElement;
  final NodeAttrs _attrs;
  final NgModel _model;
  final Scope _scope;

  dom.OptionElement _nullOption;

  _SelectMode _mode = new _SelectMode(null, null, null);
  bool _dirty = false;

  InputSelect(dom.Element this._selectElement, this._attrs, this._model, this._scope) {
    _nullOption = _selectElement
        .querySelectorAll('option')
        .firstWhere((o) => o.value == '', orElse: () => null);
  }

  void attach() {
    _attrs.observe('multiple', (value) {
      _mode.destroy();
      if (value == null) {
        _model.watchCollection = false;
        _mode = new _SingleSelectMode(options, _selectElement, _model, _nullOption);
      } else {
        _model.watchCollection = true;
        _mode = new _MultipleSelectionMode(options, _selectElement, _model);
      }
      _scope.rootScope.domRead(() {
        _mode.onModelChange(_model.viewValue);
      });
    });

    _selectElement.onChange.listen((event) => _mode.onViewChange(event));
    _model.render = (value) {
      // TODO(misko): this hack need to delay the rendering until after domRead
      // because the modelChange reads from the DOM. We should be able to render
      // without DOM changes.
      _scope.rootScope.domRead(() {
        _scope.rootScope.domWrite(() => _mode.onModelChange(value));
      });
    };
  }

  /**
   * This method invalidates the current state of the selector and forces a
   * re-rendering of the options using the [Scope.evalAsync].
   */
  void dirty() {
    if (!_dirty) {
      _dirty = true;
      // TODO(misko): this hack need to delay the rendering until after domRead
      // because the modelChange reads from the DOM. We should be able to render
      // without DOM changes.
      _scope.rootScope.domRead(() {
        _scope.rootScope.domWrite(() {
          _dirty = false;
          _mode.onModelChange(_model.viewValue);
        });
      });
    }
  }
}

/**
 * Modifies the behavior of the HTML `<option>` element to perform data binding between an
 * expression for the `option.value` attribute and the model. `Selector: option[ng-value]`
 *
 * # Example
 *
 *     <select ng-model="robot">
 *       <option ng-repeat "r in robots" ng-value="r">{{r.name}}</option>
 *     </select>
 *
 * Note: See [InputSelect] for the simpler case where `option.value` is a string.
 */
@Decorator(selector: 'option', module: NgValue.module)
class OptionValue implements AttachAware, DetachAware {
  final InputSelect _inputSelectDirective;
  final dom.Element _element;
  final NgValue _ngValue;

  OptionValue(this._element, this._inputSelectDirective, this._ngValue) {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.options[_element] = this;
    }
  }

  void attach() {
    if (_inputSelectDirective != null) _inputSelectDirective.dirty();
  }

  void detach() {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.dirty();
      _inputSelectDirective.options[_element] = null;
    }
  }

  dynamic get ngValue => _ngValue.value;
}

class _SelectMode {
  final Expando<OptionValue> options;
  final dom.SelectElement select;
  final NgModel model;

  _SelectMode(this.options, this.select, this.model);

  void onViewChange(event) {}

  void onModelChange(value) {}

  void destroy() {}

  dom.ElementList get _options => select.querySelectorAll('option');

  /// Executes the `callback` on all the options
  void _forEachOption(Function callback) {
    for (var i = 0; i < _options.length; i++) {
      callback(_options[i], i);
    }
  }

  /// Executes the `callback` and returns the result of the first one which does not return `null`
  dynamic _firstOptionWhere(Function callback) {
    for (var i = 0; i < _options.length; i++) {
      var retValue = callback(_options[i], i);
      if (retValue != null) return retValue;
    }
    return null;
  }
}

class _SingleSelectMode extends _SelectMode {
  final dom.OptionElement _unknownOption;
  final dom.OptionElement _nullOption;
  bool _unknownOptionActive = false;

  _SingleSelectMode(Expando<OptionValue> options,
                    dom.SelectElement select,
                    NgModel model,
                    this._nullOption)
      : _unknownOption = new dom.OptionElement(value: '?', selected: true),
        super(options, select, model);

  void onViewChange(_) {
    model.viewValue = _firstOptionWhere((option, _) {
      if (option.selected) {
        if (option == _nullOption) return null;
        assert(options[option] != null);
        return options[option].ngValue;
      }
    });
  }

  void onModelChange(value) {
    bool anySelected = false;
    var optionsToUnselect =[];
    _forEachOption((option, i) {
      if (identical(option, _unknownOption)) return;
      var selected;
      if (value == null) {
        selected = identical(option, _nullOption);
      } else {
        OptionValue optionValue = options[option];
        selected = optionValue == null ? false : optionValue.ngValue == value;
      }
      anySelected = anySelected || selected;
      option.selected = selected;
      if (!selected) optionsToUnselect.add(option);
    });

    if (anySelected) {
      if (_unknownOptionActive == true) {
        _unknownOption.remove();
        _unknownOptionActive = false;
      }
    } else {
      if (_unknownOptionActive == false) {
        _unknownOptionActive = true;
        select.insertBefore(_unknownOption, select.firstChild);
      }
      // It seems that IE do not allow having no option selected. It could then happen that an
      // option remains selected after the previous loop. Also IE does not enforce that only one
      // option is selected so we un-select options again to end up with a single selection.
      _unknownOption.selected = true;
      for (var option in optionsToUnselect) option.selected = false;
    }
  }
}

class _MultipleSelectionMode extends _SelectMode {
  _MultipleSelectionMode(Expando<OptionValue> options,
                         dom.SelectElement select,
                         NgModel model)
      : super(options, select, model);

  void onViewChange(_) {
    var selected = [];

    _forEachOption((o, _) {
      if (o.selected) selected.add(options[o].ngValue);
    });
    model.viewValue = selected;
  }

  void onModelChange(List selectedValues) {
    Function fn = (o, _) => o.selected = null;

    if (selectedValues is List) {
      fn = (o, i) {
        var selected = options[o];
        return selected == null ?
            false :
            o.selected = selectedValues.contains(selected.ngValue);
      };
    }

    _forEachOption(fn);
  }
}
