library introspection_spec;

import '_specs.dart';

main() => describe('introspection', () {
  it('should retrieve ElementProbe', inject((TestBed _) {
    _.compile('<div ng-bind="true"></div>');
    ElementProbe probe = ngProbe(_.rootElement);
    expect(probe.injector.parent).toBe(_.injector);
    expect(ngInjector(_.rootElement).parent).toBe(_.injector);
    expect(probe.directives[0] is NgBindDirective).toBe(true);
    expect(ngDirectives(_.rootElement)[0] is NgBindDirective).toBe(true);
    expect(probe.scope).toBe(_.rootScope);
    expect(ngScope(_.rootElement)).toBe(_.rootScope);
  }));
});
