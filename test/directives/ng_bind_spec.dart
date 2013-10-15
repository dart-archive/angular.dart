library ng_bind_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('BindDirective', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should set.text', inject((Scope scope, Injector injector, Compiler compiler) {
      var element = $('<div ng-bind="a"></div>');
      compiler(element)(injector, element);
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
