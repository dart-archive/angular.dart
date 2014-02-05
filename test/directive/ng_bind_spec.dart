library ng_bind_spec;

import '../_specs.dart';

main() {
  describe('BindDirective', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should set.text', inject((Scope scope, Injector injector, Compiler compiler, DirectiveMap directives) {
      var element = $('<div ng-bind="a"></div>');
      compiler(element, directives)(injector, element);
      scope.a = "abc123";
      scope.$digest();
      expect(element.text()).toEqual('abc123');
    }));


    it('should bind to non string values', inject((Scope scope) {
      var element = _.compile('<div ng-bind="value"></div>');

      scope.$apply(() {
        scope['value'] = null;
      });
      expect(element.text).toEqual('');

      scope.$apply(() {
        scope['value'] = true;
      });
      expect(element.text).toEqual('true');

      scope.$apply(() {
        scope['value'] = 1;
      });
      expect(element.text).toEqual('1');
    }));
  });
}
