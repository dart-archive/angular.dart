library angular.directive.select;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'ng_model.dart';
import '../dom/directive.dart';
import '../scope.dart';
import '../utils.dart';

/**
 * HTML `SELECT` element with angular data-binding.
 */
@NgDirective(selector: 'select[ng-model]')
class SelectDirective {
  factory SelectDirective(
      dom.Element selectElement, NgModel ngModel, Scope scope) {

    if ((selectElement as dom.SelectElement).multiple) {
      throw new StateError("select[multiple] is not yet supported.");
    } else {
      return new _SingleSelectDirective(selectElement, ngModel, scope);
    }
  }
}

class _SingleSelectDirective implements SelectDirective {
  dom.SelectElement selectElement;
  NgModel ngModel;
  Scope scope;
  dom.OptionElement unknownOption = new dom.OptionElement();

  Function options = () => null;

  _SingleSelectDirective(
      dom.SelectElement this.selectElement,
      NgModel this.ngModel,
      Scope this.scope) {

    options = _options;
    ngModel.render = render;
    selectElement.onChange.listen(relaxFnArgs(processValue));
    var observer = new dom.MutationObserver((_, __) => updateOptions());
    observer.observe(
        selectElement,
        childList: true,
        attributes: true,
        attributeFilter: ['value'],
        characterData: true,
        subtree: true);
  }

  void updateOptions() {
    if ((unknownOption.parent != null && options().contains(ngModel.viewValue)) ||
        (unknownOption.parent == null && !options().contains(ngModel.viewValue))) {
      render(ngModel.viewValue);
    }
  }

  List<String> _options() =>
      optionElements.map((option) => option.value).toList(growable: false);

  List<dom.OptionElement> get optionElements =>
      selectElement.queryAll('option');

  void render(value) {
    if (unknownOption.parent != null) {
      unknownOption.remove();
    }
    int index = _options().indexOf(value);
    if (index < 0 && value == null) {
      index = _options().indexOf('');
    }
    if (index < 0) {
      unknownOption.text = '? ${value.runtimeType}:${value} ?';
      selectElement.children.insert(0, unknownOption);
      unknownOption.selected = true;
    } else {
      selectElement.selectedIndex = index;
    }
  }

  void processValue() {
    if (unknownOption.parent != null) {
      if (unknownOption.selected) {
        int index = options().indexOf(ngModel.viewValue);
        if (index >= 0) {
          unknownOption.remove();
          selectElement.selectedIndex = index;
        }
        return;
      } else {
        unknownOption.remove();
      }
    }
    if (selectElement.selectedIndex >= 0) {
      var value = options()[selectElement.selectedIndex];
      if (value != ngModel.viewValue) {
        scope.$apply(() => ngModel.viewValue = value);
      }
    }
  }
}