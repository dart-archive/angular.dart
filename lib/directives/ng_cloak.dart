part of angular;


class NgCloakAttrDirective {
  NgCloakAttrDirective(dom.Node node) {
    node.attributes.remove('ng-cloak');
  }
}
