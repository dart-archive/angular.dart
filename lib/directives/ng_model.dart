part of angular;

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
@NgDirective(selector: '[ng-model]')
class NgModel {
  Scope scope;
  ParsedFn getter;
  ParsedAssignFn setter;

  Function render = (value) => null;

  NgModel(NodeAttrs attrs, Parser parser, Scope this.scope) {
    getter = parser(attrs[this]);
    setter = getter.assign;

    scope.$watch(getter, (value) => render(value) );
  }

  // TODO(misko): right now viewValue and modelValue are the same,
  // but this needs to be changed to support converters and form validation
  get viewValue        => modelValue;
  set viewValue(value) => modelValue = value;

  get modelValue        => getter(scope);
  set modelValue(value) => setter(scope, value);
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
      inputElement.value = value == null ? '' : value;
    };
    inputElement.onChange.listen(_relaxFnArgs(processValue));
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
