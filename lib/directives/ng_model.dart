library angular.directive.ng_model;

import 'dart:html' as dom;
import 'dart:async' as async;
import '../dom/directive.dart';
import '../scope.dart';
import '../parser/parser_library.dart';
import '../utils.dart';

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
    map: const {'ng-model': '&.model'})
class NgModel {
  Getter getter = ([_]) => null;
  Setter setter = (_, [__]) => null;

  Function render = (value) => null;

  NgModel(Scope scope) {
    scope.$watch(() => getter(), (value) => render(value) );
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
 * The UI portion of the ng-model directive. This directive registers the UI
 * events and provides a rendering function for the ng-model directive.
 */
@NgDirective(selector: 'input[type=text][ng-model]')
class InputTextDirective {
  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;

  InputTextDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    ngModel.render = (value) {
      if (value == null) value = '';

      var currentValue = inputElement.value;
      if (value == currentValue) return;

      var start = inputElement.selectionStart;
      var end = inputElement.selectionEnd;
      inputElement.value = value;
      inputElement.selectionStart = start;
      inputElement.selectionEnd = end;
    };
    inputElement.onChange.listen(relaxFnArgs(processValue));
    inputElement.onKeyDown.listen((e) => new async.Timer(Duration.ZERO, processValue));
  }

  processValue() {
    var value = inputElement.value;
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}

/**
 * The UI portion of the ng-model directive. This directive registers the UI
 * events and provides a rendering function for the ng-model directive.
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

/**
 * The UI portion of the ng-model directive. This directive registers the UI
 * events and provides a rendering function for the ng-model directive.
 */
@NgDirective(selector: 'select[ng-model]')
class SelectDirective {
  dom.SelectElement selectElement;
  NgModel ngModel;
  Scope scope;

  Function options = () => null;

  SelectDirective(dom.Element this.selectElement, NgModel this.ngModel, Scope this.scope) {
    options = _options;
    ngModel.render = render;
    selectElement.onChange.listen(relaxFnArgs(processValue));
    processValue();
  }

  List<String> _options() =>
      optionElements.map((option) => option.value).toList(growable: false);

  List<dom.OptionElement> get optionElements =>
      selectElement.queryAll('option');

  void render(value) {

    if (selectElement.multiple) {
      if (value is! List) {
        value = [value];
      }

      var actualValue = [];

      for (int i = 0; i < optionElements.length; i++) {
        if (value.contains(options()[i])) {
          optionElements[i].selected = true;
          actualValue.add(options()[i]);
        } else {
          optionElements[i].selected = false;
        }
      }
      var updateModel = false;
      if (ngModel.viewValue is List &&
          ngModel.viewValue.length == actualValue.length) {
        for (int i = 0; i < actualValue.length; i++) {
          if (ngModel.viewValue[i] != actualValue[i]) {
            updateModel = true;
          }
        }
      } else {
        updateModel = true;
      }
      if (updateModel) {
        ngModel.viewValue = actualValue;
      }
    } else {
      var selectedIndex = options().indexOf(value);
      selectElement.selectedIndex = selectedIndex;
      var actualValue;
      if (selectedIndex >= 0) {
        actualValue = value;
      }
      if (actualValue != ngModel.viewValue) {
        ngModel.viewValue = actualValue;
      }
    }
  }

  void processValue() {
    var value;
    if (selectElement.multiple) {
      value = [];
      for (int i = 0; i < optionElements.length; i++) {
        if (optionElements[i].selected) {
          value.add(options()[i]);
        }
      }
    } else {
      if (selectElement.selectedIndex >= 0) {
        value = options()[selectElement.selectedIndex];
      }
    }

    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }
}