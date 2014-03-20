library ng_bind_spec;

import '../_specs.dart';

main() {
  describe('BindDirective', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should set.text', (Scope scope, Injector injector, Compiler compiler, DirectiveMap directives) {
      var element = e('<div ng-bind="a"></div>');
      compiler([element], directives)(injector, [element]);
      scope.context['a'] = "abc123";
      scope.apply();
      expect(element.text).toEqual('abc123');
    });


    it('should bind to non string values', (Scope scope) {
      var element = _.compile('<div ng-bind="value"></div>');

      scope.apply(() {
        scope.context['value'] = null;
      });
      expect(element.text).toEqual('');

      scope.apply(() {
        scope.context['value'] = true;
      });
      expect(element.text).toEqual('true');

      scope.apply(() {
        scope.context['value'] = 1;
      });
      expect(element.text).toEqual('1');
    });
  });
}
