part of angular;

@NgDirective(
    selector: '[ng-disabled]',
    map: const {'ng-disabled': '=.disabled'})
class NgDisabledAttrDirective {
  dom.Node node;

  NgDisabledAttrDirective(dom.Node this.node);

  set disabled(value) => node.disabled = toBool(value);
}
