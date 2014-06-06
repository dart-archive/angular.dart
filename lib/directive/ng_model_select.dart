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
  final expando = new Expando<OptionValue>();
  final dom.SelectElement _selectElement;
  final NodeAttrs _attrs;
  final NgModel _model;
  final Scope _scope;

  final dom.OptionElement _unknownOption = new dom.OptionElement();
  dom.OptionElement _nullOption;

  _SelectMode _mode = new _SelectMode(null, null, null);
  bool _dirty = false;

  InputSelect(dom.Element this._selectElement, this._attrs, this._model,
              this._scope) {
    _unknownOption.value = '?';
    _nullOption = _selectElement.querySelectorAll('option')
        .firstWhere((o) => o.value == '', orElse: () => null);
  }

  attach() {
    _attrs.observe('multiple', (value) {
      _mode.destroy();
      if (value == null) {
        _model.watchCollection = false;
        _mode = new _SingleSelectMode(expando, _selectElement, _model,
            _nullOption, _unknownOption);
      } else {
        _model.watchCollection = true;
        _mode = new _MultipleSelectionMode(expando, _selectElement, _model);
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
  dirty() {
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
 *     <select ng-model="robot">
 *       <option ng-repeat "r in robots" ng-value="r">{{r.name}}</option>
 *     </select>
 *
 * Note: See [InputSelect] for the simpler case where `option.value` is a string.
 */
@Decorator(selector: 'option', module: NgValue.module)
class OptionValue implements AttachAware,
    DetachAware {
  final InputSelect _inputSelectDirective;
  final dom.Element _element;

  NgValue _ngValue;

  OptionValue(this._element, this._inputSelectDirective, this._ngValue) {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.expando[_element] = this;
    }
  }

  attach() {
    if (_inputSelectDirective != null) _inputSelectDirective.dirty();
  }

  detach() {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.dirty();
      _inputSelectDirective.expando[_element] = null;
    }
  }

  get ngValue => _ngValue.value;
}

class _SelectMode {
  final Expando<OptionValue> expando;
  final dom.SelectElement select;
  final NgModel model;

  _SelectMode(this.expando, this.select, this.model);

  onViewChange(event) {}
  onModelChange(value) {}
  destroy() {}

  get _options => select.querySelectorAll('option');
  _forEachOption(fn, [quitOnReturn = false]) {
    for (var i = 0; i < _options.length; i++) {
      var retValue = fn(_options[i], i);
      if (quitOnReturn && retValue != null) return retValue;
    }
    return null;
  }
}

class _SingleSelectMode extends _SelectMode {
  final dom.OptionElement _unknownOption;
  final dom.OptionElement _nullOption;

  bool _unknownOptionActive = false;

  _SingleSelectMode(Expando<OptionValue> expando,
                    dom.SelectElement select,
                    NgModel model,
                    this._nullOption,
                    this._unknownOption)
      : super(expando, select, model) {
  }

  onViewChange(event) {
    var i = 0;
    model.viewValue = _forEachOption((option, _) {
      if (option.selected) {
        if (option == _nullOption) return null;
        assert(expando[option] != null);
        return expando[option].ngValue;
      }
      if (option != _unknownOption && option != _nullOption) i++;
    }, true);
  }

  onModelChange(value) {
    var found = false;
    _forEachOption((option, i) {
      if (option == _unknownOption) return;
      var selected;
      if (value == null) {
        selected = option == _nullOption;
      } else {
        OptionValue optionValueDirective = expando[option];
        selected = optionValueDirective == null ?
            false :
            optionValueDirective.ngValue == value;
      }
      found = found || selected;
      option.selected = selected;
    });

    if (!found) {
      if (!_unknownOptionActive) {
        select.insertBefore(_unknownOption, select.firstChild);
        _unknownOption.selected = true;
        _unknownOptionActive = true;
      }
    } else {
      if (_unknownOptionActive) {
        _unknownOption.remove();
        _unknownOptionActive = false;
      }
    }
  }
}

class _MultipleSelectionMode extends _SelectMode {
  _MultipleSelectionMode(Expando<OptionValue> expando,
                         dom.SelectElement select,
                         NgModel model)
      : super(expando, select, model);

  onViewChange(event) {
    var selected = [];

    _forEachOption((o, i) {
      if (o.selected) selected.add(expando[o].ngValue);
    });
    model.viewValue = selected;
  }

  onModelChange(List selectedValues) {
    Function fn = (o, i) => o.selected = null;

    if (selectedValues is List) {
      fn = (o, i) {
        var selected = expando[o];
        return selected == null ?
            false :
            o.selected = selectedValues.contains(selected.ngValue);
      };
    }

    _forEachOption(fn);
  }
}
