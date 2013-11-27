part of angular.directive;

/**
 * The form directive listens on submission requests and, depending,
 * on if an action is set, the form will automatically either allow
 * or prevent the default browser submission from occurring.
 */
@NgDirective(
    selector: 'form',
    visibility: NgDirective.CHILDREN_VISIBILITY)
class NgForm {
  dom.Element _element;
  Scope _scope;

  NgForm(Scope this._scope, dom.Element this._element) {
    if(!this._element.attributes.containsKey('action')) {
      this._element.onSubmit.listen((event) {
        event.preventDefault();
      });
    }
  }
}
