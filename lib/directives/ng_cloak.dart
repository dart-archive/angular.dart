part of angular;


@NgDirective(
    selector: '[ng-cloak]'
)
class NgCloakAttrDirective {
  NgCloakAttrDirective(dom.Node node) {
    node.attributes.remove('ng-cloak');
  }
}
