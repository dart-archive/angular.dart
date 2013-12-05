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
    selector: '.ng-form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
@NgDirective(
    selector: '[ng-form]',
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm {
  static const NG_VALID_CLASS    = "ng-valid";
  static const NG_INVALID_CLASS  = "ng-invalid";
  static const NG_PRISTINE_CLASS = "ng-pristine";
  static const NG_DIRTY_CLASS    = "ng-dirty";

  final dom.Element _element;
  final Scope _scope;

  String _name;

  bool _dirty;
  bool _pristine;
  bool _valid;
  bool _invalid;

  final List<NgModel> _controls = new List<NgModel>();
  final Map<String, NgModel> _controlByName = new Map<String, NgModel>();

  NgForm(Scope this._scope, dom.Element this._element) {
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

  get pristine => _pristine;
  set pristine(value) {
    _pristine = true;
    _dirty = false;

    _element.classes.remove(NG_DIRTY_CLASS);
    _element.classes.add(NG_PRISTINE_CLASS);
  }

  get dirty => _dirty;
  set dirty(value) {
    _dirty = true;
    _pristine = false;

    _element.classes.remove(NG_PRISTINE_CLASS);
    _element.classes.add(NG_DIRTY_CLASS);
  }

  get valid => _valid;
  set valid(value) {
    _invalid = false;
    _valid = true;

    _element.classes.remove(NG_INVALID_CLASS);
    _element.classes.add(NG_VALID_CLASS);
  }

  get invalid => _invalid;
  set invalid(value) {
    _valid = false;
    _invalid = true;

    _element.classes.remove(NG_VALID_CLASS);
    _element.classes.add(NG_INVALID_CLASS);
  }

  operator[](name) {
    return _controlByName[name];
  }

  addControl(NgModel control) {
    _controls.add(control);
    if(control.name != null) {
      _controlByName[control.name] = control;
    }
  }

  removeControl(NgModel control) {
    _controls.remove(control);
    if(control.name != null) {
      _controlByName.remove(control.name);
    }
  }
}
