part of angular.directive;

/**
 * HTML `SELECT` element with angular data-binding.
 */
@NgDirective(selector: 'select[ng-model]')
abstract class SelectDirective {

  final dom.SelectElement selectElement;
  final NgModel ngModel;
  final Scope scope;

  final Map<String, Object> _viewValueToModelValue = {};
  final Map<Object, String> _modelValueToViewValue = {};

  final Map<dom.OptionElement, Object> _unknownElementsToValue = {};

  factory SelectDirective(
      dom.Element selectElement, NgModel ngModel, Scope scope) {

    if ((selectElement as dom.SelectElement).multiple) {
      return new _MultipleSelectDirective(selectElement, ngModel, scope);
    } else {
      return new _SingleSelectDirective(selectElement, ngModel, scope);
    }
  }

  SelectDirective._(
      dom.SelectElement this.selectElement,
      NgModel this.ngModel,
      Scope this.scope) {
    ngModel.render = render;
    selectElement.onChange.listen(relaxFnArgs(processValue));
    var observer = new dom.MutationObserver(relaxFnArgs(updateDom));
    observer.observe(
        selectElement,
        childList: true,
        attributes: true,
        attributeFilter: ['value'],
        characterData: true,
        subtree: true);
  }

  List<dom.OptionElement> get optionElements =>
      selectElement.queryAll('option');

  void render(value);

  void processValue();

  void updateDom() => render(ngModel.viewValue);

  void addMappedValue(String viewValue, Object modelValue) {
    _viewValueToModelValue[viewValue] = modelValue;
    _modelValueToViewValue[modelValue] = viewValue;
  }

  void resetModelMap() {
    _viewValueToModelValue.clear();
    _modelValueToViewValue.clear();
  }

  Object getModelValue(String viewValue) {
    if (_viewValueToModelValue.containsKey(viewValue)) {
      return _viewValueToModelValue[viewValue];
    }
    return viewValue;
  }

  String getViewValue(Object modelValue) {
    if (_modelValueToViewValue.containsKey(modelValue)) {
      return _modelValueToViewValue[modelValue];
    }
    if (modelValue == null) {
      return '';
    }
    return modelValue as String;
  }

  void removeAllUnknownOptions() {
    _unknownElementsToValue.keys.forEach((element) => element.remove());
    _unknownElementsToValue.clear();
  }

  void setSelectedValues(Iterable<Object> modelValues) {
    Set<Object> unknownModelValues;
    if (modelValues == null) {
      unknownModelValues = new Set();
    } else {
      unknownModelValues = new Set.from(modelValues);
    }

    for (dom.OptionElement element in optionElements) {
      if (_unknownElementsToValue.containsKey(element)) {
        continue;
      }
      var modelValue = getModelValue(element.value);
      if (unknownModelValues.contains(modelValue)) {
        element.selected = true;
        unknownModelValues.remove(modelValue);
      } else if (element.value == '' && unknownModelValues.contains(null)) {
        element.selected = true;
        unknownModelValues.remove(null);
      } else {
        element.selected = false;
      }
    }

    Map unknownElements = {};

    _unknownElementsToValue.forEach((element, value) {
      if (unknownModelValues.contains(value)) {
        unknownModelValues.remove(value);
        unknownElements[element] = value;
        element.selected = true;
      } else {
        element.remove();
      }
    });

    _unknownElementsToValue.clear();
    _unknownElementsToValue.addAll(unknownElements);

    for (var modelValue in unknownModelValues) {
      dom.OptionElement element = new dom.OptionElement();
      element.text = '';
      element.value = '?';
      _unknownElementsToValue[element] = modelValue;
      selectElement.children.insert(0, element);
      element.selected = true;
    }
  }

  Set<Object> getSelectedValues() {
    Set values = new LinkedHashSet<Object>();

    for (dom.OptionElement element in optionElements) {
      if (element.selected) {
        if (_unknownElementsToValue.containsKey(element)) {
          values.add(_unknownElementsToValue[element]);
        } else {
          values.add(getModelValue(element.value));
        }
      }
    }

    setSelectedValues(values);
    return values;
  }
}

class _SingleSelectDirective extends SelectDirective {

  _SingleSelectDirective(
      dom.SelectElement selectElement,
      NgModel ngModel,
      Scope scope) : super._(selectElement, ngModel, scope);

  void render(value) => setSelectedValues([value]);

  void processValue() {
    Set values = getSelectedValues();
    if (values.length == 1) {
      if (ngModel.viewValue != values.first) {
        scope.$apply(() {
          ngModel.viewValue = values.first;
        });
      }
    } else {
      throw new StateError('Incorrect number of selected values: ${values}');
    }
  }

  void updateDom() => setSelectedValues([ngModel.viewValue]);
}

class _MultipleSelectDirective extends SelectDirective {
  _MultipleSelectDirective(
      dom.SelectElement selectElement,
      NgModel ngModel,
      Scope scope) : super._(selectElement, ngModel, scope) {
    scope.$watchCollection(ngModel.getter, (value) => ngModel.render(value));
  }

  void processValue() {
    var prevSelectedOptions;
    if (ngModel.viewValue is Iterable) {
      prevSelectedOptions = new Set.from(ngModel.viewValue);
    } else if (ngModel.viewValue == null) {
      prevSelectedOptions = new Set();
    } else {
      throw new StateError('Model for select[multiple] must be an Iterable');
    }

    var selectedOptions = getSelectedValues();

    if (selectedOptions.length != prevSelectedOptions.length ||
        !selectedOptions.containsAll(prevSelectedOptions)) {
      scope.$apply(() => ngModel.viewValue = selectedOptions.toList());
    }
  }

  void render(value) => setSelectedValues(value);

  void updateDom() => setSelectedValues(ngModel.viewValue);
}

@NgDirective(
    selector: 'select[ng-model][ng-options]',
    map: const {'ng-options': '@.optionsExpression'})
class NgOptionsDirective {

  static final RegExp SYNTAX =
      new RegExp(r'^\s*(.+)\s+for\s+(\w+)\s+in\s+(.+)\s*$');

  final SelectDirective selectDirective;
  final Scope scope;

  String _options;
  String _labelExpression;
  String _valueIdentifier;
  String _listExpr;

  Function _removeWatch = () => null;

  final List<dom.OptionElement> addedOptions = [];

  NgOptionsDirective(SelectDirective this.selectDirective, Scope this.scope);

  List options() {
    var options = scope.$eval(_listExpr);
    if (options == null) {
      return [];
    } else if (options is Iterable){
      return new List.from(options);
    } else {
      throw new StateError('Bound value $options for ng-options is not a list');
    }
  }

  set optionsExpression(exp) {
    this._options = exp;
    _removeWatch();
    Match match = SYNTAX.firstMatch(_options);
    if (match == null) {
      throw new StateError("expected ng-options expression in form "
            "of '_label_ for _item_ in _collection_' but got '$_options'");
    }

    _labelExpression = match.group(1);
    _valueIdentifier = match.group(2);
    _listExpr = match.group(3);

    _removeWatch = scope.$watchCollection(_listExpr, onCollectionChange);
    onCollectionChange(scope.$eval(_listExpr));
  }

  void onCollectionChange(List collection) {

    if (collection == null) {
      collection = [];
    }

    addedOptions.forEach((option) => option.remove());
    addedOptions.clear();

    selectDirective.resetModelMap();

    int index = 0;
    for (var item in collection) {
      selectDirective.addMappedValue(index.toString(), item);
      dom.OptionElement option = new dom.OptionElement();
      addedOptions.add(option);
      var locals = {};
      locals[_valueIdentifier] = item;
      option.text =
          scope.$eval(_labelExpression, locals).toString();
      option.value = index.toString();
      selectDirective.selectElement.append(option);
      index++;
    }
    selectDirective.updateDom();
  }
}
