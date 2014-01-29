part of angular.directive;

typedef dynamic ItemEval(dynamic item, num index);

/**
 * HTML [SELECT] element with angular data-binding if used with
 * [NgModelDirective].
 *
 * The [NgModelDirective] will receive the currently selected item. The binding
 * is performed on the [OPTION].[value] property. An empty [OPTION].[value] is
 * treated as null.
 *
 * If you the model contains value which does not map to any [OPTION] then a new
 * unknown [OPTION] is inserted into the list. Once the model points to an
 * existing [OPTION] the unknown [OPTION] is removed.
 *
 * Becouse [OPTION].[value] attribute is a string, the model is bound to a
 * string. If there is need to bind to an object then [OptionValueDirective]
 * should be used.
 *
 */
@NgDirective(
    selector: 'select[ng-model]',
    visibility: NgDirective.CHILDREN_VISIBILITY)
class InputSelectDirective implements NgAttachAware {
  final Expando<OptionValueDirective> expando =
      new Expando<OptionValueDirective>();
  final dom.SelectElement _selectElement;
  final NodeAttrs _attrs;
  final NgModel _model;
  final Scope _scope;

  final dom.OptionElement _unknownOption = new dom.OptionElement();
  dom.OptionElement _nullOption;

  _SelectMode _mode = new _SelectMode(null, null, null);
  bool _dirty = false;

  InputSelectDirective(dom.Element this._selectElement, this._attrs, this._model,
                       this._scope) {
    _unknownOption.value = '?';
    _unknownOption.text = ''; // Explicit due to dartbug.com/14407
    _selectElement.querySelectorAll('option').forEach((o) {
      if (_nullOption == null && o.value == '') {
        _nullOption = o;
      }
    });
  }

  attach() {
    _attrs.observe('multiple', (value) {
      _mode.destroy();
      if (value == null) {
        _model.watchCollection = false;
        _mode = new _SingleSelectMode(expando, _selectElement, _model, _nullOption, _unknownOption);
      } else {
        _model.watchCollection = true;
        _mode = new _MultipleSelectionMode(expando, _selectElement, _model);
      }
      _mode.onModelChange(_model.viewValue);
    });

    _selectElement.onChange.listen((event) => _mode.onViewChange(event));
    _model.render = (value) => _mode.onModelChange(value);
  }

  /**
   * This method invalidates the current state of the selector and forces a
   * re-rendering of the options using the [Scope.$evalAsync].
   */
  dirty() {
    if (!_dirty) {
      _dirty = true;
      _scope.$evalAsync(() {
        _dirty = false;
        _mode.onModelChange(_model.viewValue);
      });
    }
  }
}

/**
 * Since the [value] attirbute of the [OPTION] can only be a string, Angular
 * provides [ng-value] which allows binding to any expression.
 *
 */
@NgDirective(
    selector: 'option',
    publishTypes: const [TextChangeListener],
    map: const {'ng-value': '&ngValue'})
class OptionValueDirective implements TextChangeListener, NgAttachAware,
    NgDetachAware {
  final InputSelectDirective _inputSelectDirective;
  final NodeAttrs _attrs;

  Getter _ngValue;

  OptionValueDirective(this._attrs, this._inputSelectDirective) {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.expando[_attrs.element] = this;
    }
  }

  attach() {
    if (_inputSelectDirective != null) {
      this._attrs.observe('value', (_) => _inputSelectDirective.dirty());
    }
  }

  call(String text) {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.dirty();
    }
  }

  detach() {
    if (_inputSelectDirective != null) {
      _inputSelectDirective.dirty();
      _inputSelectDirective.expando[_attrs.element] = null;
    }
  }

  set ngValue(Getter value) => _ngValue = value;
  get ngValue => _attrs['ng-value'] is String ?
        _ngValue() :
        (_attrs.element as dom.OptionElement).value;
}

class _SelectMode {
  final Expando<OptionValueDirective> expando;
  final dom.SelectElement select;
  final NgModel model;

  _SelectMode(this.expando, this.select, this.model);

  onViewChange(event) {}
  onModelChange(value) {}
  destroy() {}

  get _options => select.querySelectorAll('option');
  _forEachOption(fn, [quiteOnReturn = false]) {
    for(var os = _options, i = 0, ii = os.length; i < ii; i++) {
      var retValue = fn(os[i], i);
      if (quiteOnReturn && retValue != null) return retValue;
    }
    return null;
  }
}

class _SingleSelectMode extends _SelectMode {
  final dom.OptionElement _unknownOption;
  final dom.OptionElement _nullOption;

  bool _unknownOptionActive = false;

  _SingleSelectMode(Expando<OptionValueDirective> expando,
                    dom.SelectElement select,
                    NgModel model,
                    this._nullOption,
                    this._unknownOption
                    ): super(expando, select, model) {
  }

  onViewChange(event) {
    var i = 0;
    model.viewValue = _forEachOption((option, _) {
      if (option.selected) {
        return option == _nullOption ? null : expando[option].ngValue;
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
        OptionValueDirective optionValueDirective = expando[option];
        selected = optionValueDirective == null ? false : optionValueDirective.ngValue == value;
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
  _MultipleSelectionMode(Expando<OptionValueDirective> expando,
                         dom.SelectElement select,
                         NgModel model
                         ): super(expando, select, model);

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
      fn = (o, i) => o.selected = selectedValues.contains(expando[o].ngValue);
    }

    _forEachOption(fn);
  }
}
