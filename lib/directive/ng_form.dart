part of angular.directive;

/**
 * Listens on form submission requests and if an action is set, either allows or
 * prevents the default browser form submission action from occurring. `Selector: [ng-form]` or
 * `.ng-form` or `form` or `fieldset`
 */
@Decorator(
    selector: 'form',
    module: NgForm.module)
@Decorator(
    selector: 'fieldset',
    module: NgForm.module)
@Decorator(
    selector: '.ng-form',
    module: NgForm.module)
@Decorator(
    selector: '[ng-form]',
    module: NgForm.module,
    map: const { 'ng-form': '&name' })
class NgForm extends NgControl {
  static module(DirectiveBinder binder) =>
      binder.bind(NgControl, toInstanceOf: NG_FORM_KEY, visibility: Visibility.CHILDREN);

  final Scope _scope;

  /**
   * Instantiates a new instance of NgForm. Upon creation, the instance of the
   * class will be bound to the formName property on the scope (where formName
   * refers to the name value acquired from the name attribute present on the
   * form DOM element).
   *
   * * [scope] - The scope to bind the form instance to.
   * * [element] - The form DOM element.
   * * [injector] - An instance of Injector.
   */
  NgForm(this._scope, NgElement element, DirectiveInjector injector, Animate animate) :
    super(element, injector, animate) {

    if (!element.node.attributes.containsKey('action')) {
      element.node.onSubmit.listen((event) {
        event.preventDefault();
        onSubmit(valid == true);
        if (valid == true) {
          reset();
        }
      });
    }
  }

  /**
    * The name of the control. This is usually fetched via the name attribute that is
    * present on the element that the control is bound to.
    */
  @NgCallback('name')
  String get name => super.name;
  void set name(exp) {
    // The type could not be added on the parameter as the base setter takes a String
    assert(exp is BoundExpression);
    var name = exp.expression.toString();
    if (name != null && name.isNotEmpty) {
      super.name = name;
      try {
        exp.assign(this);
      } catch (e) {
        throw 'There must be a "$name" field on your component to store the form instance.';
      }
     }
   }

  /**
    * The list of associated child controls.
    */
  Map<String, List<NgControl>> get controls => _controlByName;

  /**
    * Returns the child control that is associated with the given name. If multiple
    * child controls contain the same name then the first instance will be returned.
    */
  NgControl operator[](String name) =>
      controls.containsKey(name) ? controls[name][0] : null;
}
/**
 * Creates a top-level dummy NgForm to hold Form controls that aren't located inside a form.
 */
class NgNullForm extends NgNullControl implements NgForm {
  var _scope;

  NgNullForm() {}
  operator []=(String key, value) {}
  operator[](name) {}

  get controls => null;
}
