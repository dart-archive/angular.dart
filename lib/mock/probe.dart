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
class Probe implements NgDetachAware {
  final Scope scope;
  final Injector injector;
  final Element element;
  final NodeAttrs _attrs;

  Probe(this.scope, this.injector, this.element, this._attrs) {
    scope.$root[_attrs['probe']] = this;
  }

  detach() => scope.$root[_attrs['probe']] = null;

  /**
   * Retrieve a Directive at the current element.
   */
  directive(Type type) => injector.get(type);
}

