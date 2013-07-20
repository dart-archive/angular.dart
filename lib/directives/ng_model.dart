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
class InputDirective {
  static String $selector = 'input[ng-model]';

  dom.InputElement inputElement;
  NgModel ngModel;
  Scope scope;

  InputDirective(dom.Element this.inputElement, NgModel this.ngModel, Scope this.scope) {
    var type = inputElement.attributes['type'];

    // NOTE(vojta):
    // I think this will perform better than having multiple directives (eg. InputCheckbox) with different selectors,
    // especially because the selector for the default input would be pretty weird.
    // Also, why can't I use inputElement is dom.CheckboxInputElement ?
    if (type == 'checkbox') {
      ngModel.render = this.renderCheckbox;
      inputElement.onChange.listen(this.onCheckboxChange);
    } else {
      ngModel.render = this.render;
      inputElement.onChange.listen(_relaxFnArgs(processValue));
      inputElement.onKeyDown.listen((e) => new async.Timer(Duration.ZERO, processValue));
    }
  }

  onCheckboxChange(value) {
    scope.$apply(() => ngModel.viewValue = inputElement.checked);
  }

  renderCheckbox(value) {
    inputElement.checked = value == null ? false : toBool(value);
  }

  processValue() {
    var value = inputElement.value;
    if (value != ngModel.viewValue) {
      scope.$apply(() => ngModel.viewValue = value);
    }
  }

  render(value) {
    inputElement.value = value == null ? '' : value;
  }
}
