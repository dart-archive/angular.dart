part of angular.directive;

/**
 * The form directive listens on submission requests and, depending,
 * on if an action is set, the form will automatically either allow
 * or prevent the default browser submission from occurring.
 */
@NgDirective(
    selector: 'form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: 'fieldset',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '.ng-form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '[ng-form]',
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm extends NgControl implements Map<String, NgControl> {
  NgForm _parentForm;
  final dom.Element _element;
  final Scope _scope;

  String _name;

  final Map<String, List<NgControl>> currentErrors = new Map<String, List<NgControl>>();

  final List<NgControl> _controls = new List<NgControl>();
  final Map<NgControl> _controlByName = new Map<NgControl>();

  NgForm(this._scope, dom.Element this._element, Injector injector) {
    _parentForm = injector.parent.get(NgForm);
    if(!this._element.attributes.containsKey('action')) {
      this._element.onSubmit.listen((event) {
        event.preventDefault();
      });
    }

    _scope.$on(r'$destroy', () {
      for (int i = _controls.length - 1; i >= 0; --i) {
        removeControl(_controls[i]);
      }
    });

    this.pristine = true;
  }

  @NgAttr('name')
  get name => _name;
  set name(name) {
    _name = name;
    _scope[name] = this;
  }

  setValidity(NgControl control, String errorType, bool isValid) {
    List<NgControl> queue = currentErrors[errorType];

    if(isValid) {
      if(queue != null) {
        queue.remove(control);
        if(queue.isEmpty) {
          currentErrors.remove(errorType);
          if(currentErrors.isEmpty) {
            valid = true;
          }
          if(_parentForm != null) {
            _parentForm.setValidity(this, errorType, true);
          }
        }
      }
    } else {
      if(queue == null) {
        queue = new List();
        currentErrors[errorType] = queue;
        if(_parentForm != null) {
          _parentForm.setValidity(this, errorType, false);
        }
      } else if(queue.contains(control)) {
        return;
      }

      queue.add(control);
      invalid = true;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator []=(String name, value) {
    if(name == 'name'){
      this.name = value;
    } else {
      _controlByName[name] = value;
    }
  }

  //FIXME: fix this reflection bug that shows up when Map is implemented
  operator[](name) {
    if(name == 'valid') {
      return valid;
    } else if(name == 'invalid') {
      return invalid;
    } else {
      return _controlByName[name];
    }
  }

  addControl(NgControl control) {
    _controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(NgControl control) {
    _controls.remove(control);
    if(control.name != null) {
      _controlByName.remove(control.name);
    }
  }
}
