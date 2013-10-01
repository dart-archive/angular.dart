part of angular.directive;

@NgDirective(
    selector: '[ng-disabled]',
    map: const {'ng-disabled': '=.disabled'})
class NgDisabledDirective {
  dom.Element element;

  NgDisabledDirective(dom.Element this.element);

  // TODO: should be if (understands(element, #disabled)) ...
  set disabled(value) => (element as dynamic).disabled = toBool(value);
}
