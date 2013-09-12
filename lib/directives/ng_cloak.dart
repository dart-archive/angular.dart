part of angular;


@NgDirective(
    selector: '[ng-cloak]'
)
class NgCloakAttrDirective {
  NgCloakAttrDirective(dom.Element element) {
    element.attributes.remove('ng-cloak');
  }
}
