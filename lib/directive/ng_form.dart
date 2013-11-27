part of angular.directive;

@NgDirective(
  selector: 'form',
  visibility: NgDirective.CHILDREN_VISIBILITY
)
@NgDirective(
  selector: '[ng-form]',
  visibility: NgDirective.CHILDREN_VISIBILITY
)
@NgDirective(
  selector: '.ng-form',
  visibility: NgDirective.CHILDREN_VISIBILITY
)
class NgForm {
  static const NG_DIRTY_CLASS    = "ng-dirty";
  static const NG_PRISTINE_CLASS = "ng-prisine";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_VALID_CLASS    = "ng-valid";

  Getter getter = ([_]) => null;
  Setter setter = (_, [__]) => null;

  final dom.Element _element;
  String _name;
  final Scope _scope;

  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;

  final List<NgModel> _controls = new List<NgModel>();
  final Map<String, NgModel> _controlByName = new Map<String, NgModel>();

  @NgAttr('name')
  get name => _name;
  set name(name) {
    _name = name;
    _scope[name] = this;
  }

  NgForm(Scope this._scope, dom.Element this._element) {
    //we can't setup a form if an action has been defined on
    //the element
    if(_element.attributes.containsKey('action')) {
      var listener = element.onSubmit.listen((event) {
        event.stopPropagation();
        event.preventDefault();
      });
    }

    pristine = true;
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
    _element.classes.remove((isValid ? NG_INVALID_CLASS : NG_VALID_CLASS) + suffix);
    _element.classes.add((isValid ? NG_VALID_CLASS : NG_INVALID_CLASS) + suffix);
  }

  get pristine => _pristine;
  set pristine(value) {
    _element.classes.remove(NG_DIRTY_CLASS);
    _element.classes.add(NG_PRISTINE_CLASS);

    _pristine = true;
    _dirty = false;

    _controls.forEach((control) {
      control.pristine = true;
    });

    return true;
  }

  get dirty => _dirty;
  set dirty(value) {
    _element.classes.remove(NG_PRISTINE_CLASS);
    _element.classes.add(NG_DIRTY_CLASS);

    _dirty = true;
    _pristine = false;

    _controls.forEach((control) {
      control.dirty = true;
    });
  }

  get valid           => _valid;
  set valid(value)    => _valid = value;

  get invalid         => _invalid;
  set invalid(value)  => _invalid = value;

  addControl(NgModel control) {
    _controls.add(control);
      print(control.name);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(control) {

  }
}
