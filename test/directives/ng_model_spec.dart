import "../_specs.dart";
import "../_test_bed.dart";

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  describe('type="text"', () {
    it('should update input value from model', inject(() {
      _.compile('<input ng-model="model">');
      _.rootScope.$digest();

      expect(_.rootElement.prop('value')).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect(_.rootElement.prop('value')).toEqual('misko');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      var input = probe.directive(InputDirective);

      probe.element.value = 'abc';
      input.processValue();
      expect(_.rootScope.model).toEqual('abc');
    }));
  });
});
