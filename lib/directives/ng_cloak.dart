part of angular;


class NgCloakAttrDirective {
  dom.Element node;

  NgCloakAttrDirective(dom.Node this.node) {}

  attach(Scope scope) {
    node.attributes.remove('ng-cloak');
  }
}
