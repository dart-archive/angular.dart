import "../_specs.dart";
import "../_test_bed.dart";

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  describe('type="text"', () {
    it('should update input value from model', async(inject(() {
      _.compile('<input ng-model="model">');
      _.rootScope.$digest();

      expect(_.rootElement.prop('value')).toEqual('');

      _.rootScope.$apply('model = "misko"');
      nextTurn(true);

      expect(_.rootElement.prop('value')).toEqual('misko');
    })));

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


  describe('type="checkbox"', () {
    it('should update input value from model', async(inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      scope.$apply(() {
        scope['model'] = true;
      });
      nextTurn(true);

      expect(element[0].checked).toBe(true);

      scope.$apply(() {
        scope['model'] = false;
      });
      nextTurn(true);

      expect(element[0].checked).toBe(false);
    })));


    it('should allow non boolean values like null, 0, 1', async(inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      scope.$apply(() {
        scope['model'] = 0;
      });
      nextTurn(true);

      expect(element[0].checked).toBe(false);

      scope.$apply(() {
        scope['model'] = 1;
      });
      nextTurn(true);

      expect(element[0].checked).toBe(true);

      scope.$apply(() {
        scope['model'] = null;
      });
      nextTurn(true);

      expect(element[0].checked).toBe(false);
    })));


    it('should update model from the input value', inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      element[0].checked = true;
      _.triggerEvent(element, 'change');
      expect(scope['model']).toBe(true);

      element[0].checked = false;
      _.triggerEvent(element, 'change');
      expect(scope['model']).toBe(false);
    }));
  });
});
