part of angular.mock;

/*
 * Use Probe directive to capture the Scope, Injector and Element from any DOM
 * location into root-scope. This is useful for testing to get a hold of
 * any directive.
 *
 *    <div some-directive probe="myProbe">..</div>
 *
 *    rootScope.myProbe.directive(SomeAttrDirective);
 */
@NgDirective(selector: '[probe]')
class Probe {
  final Scope scope;
  final Injector injector;
  final Element element;

  Probe(Scope this.scope, Injector this.injector, Element this.element, NodeAttrs attrs) {
    scope.$root[attrs['probe']] = this;
  }

  directive(Type type) => injector.get(type);
}

