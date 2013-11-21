part of angular.directive;

@NgDirective(
    selector: 'form',
    visibility: NgDirective.CHILDREN_VISIBILITY
)
class NgForm {
  static const NG_DIRTY_CLASS    = "ng-dirty";
  static const NG_PRISTINE_CLASS = "ng-prisine";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_VALID_CLASS    = "ng-valid";

  dom.Element element;
  String name;
  bool dirty;
  bool pristine;
  bool valid;
  bool invalid;

  List<NgModel> controls;
  Map<String, NgModel> _controlByName;

  NgForm(Scope scope, dom.Element elm, NodeAttrs attrs) {
    name = attrs['name'];
    scope[name] = this;
    element = elm;
    controls = new List<NgModel>();
    _controlByName = new Map<String, NgModel>();

    //we can't setup a form if an action has been defined on
    //the element
    if(element.attributes.containsKey('action')) {
      var listener = element.onSubmit.listen((event) {
        event.stopPropagation();
        event.preventDefault();
      });

      whenDestroy() {
        listener.cancel();
      }
    }

    this.setAsPristine();
  }

  operator[](name) {
    return _controlByName[name];
  }

  setValidity(String token, bool isValid, NgModel control) {
    if(isValid) {
      this.valid = true;
      this.invalid = false;
    }
    else {
      this.valid = false;
      this.invalid = true;
    }
    toggleValidCssClasses(token, isValid);
  }

  toggleValidCssClasses(String token, bool isValid) {
    String suffix = token != null ?
      '-' + snakecase(token, '-') : '';
    element.classes.remove((isValid ? NG_INVALID_CLASS : NG_VALID_CLASS) + suffix);
    element.classes.add((isValid ? NG_VALID_CLASS : NG_INVALID_CLASS) + suffix);
  }

  setAsPristine() {
    element.classes.remove(NG_DIRTY_CLASS);
    element.classes.add(NG_PRISTINE_CLASS);
    dirty = false;
    pristine = true;
    controls.forEach((control) {
      control.setAsPristine();
    });
    return true;
  }

  setAsDirty() {
    element.classes.remove(NG_PRISTINE_CLASS);
    element.classes.add(NG_DIRTY_CLASS);
    pristine = false;
    dirty = true;
    controls.forEach((control) {
      control.setAsDirty();
    });
  }

  addControl(NgModel control) {
    controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(control) {

  }
}
