part of angular.directive;

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
  final Scope _scope;

  Getter getter = ([_]) => null;
  Setter setter = (_, [__]) => null;
  String _exp;


  Function _removeWatch = () => null;
  bool _watchCollection;

  Function render = (value) => null;

  NgModel(Scope this._scope, NodeAttrs attrs) {
    _exp = 'ng-model=${attrs["ng-model"]}';
    watchCollection = false;
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
