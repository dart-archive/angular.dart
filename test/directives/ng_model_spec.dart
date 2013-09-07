library ng_model_spec;

import "../_specs.dart";
import "../_test_bed.dart";
import 'dart:html' as dom;

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  describe('type="text"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="text" ng-model="model">');
      _.rootScope.$digest();

      expect(_.rootElement.prop('value')).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect(_.rootElement.prop('value')).toEqual('misko');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="text" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      var input = probe.directive(InputTextDirective);

      probe.element.value = 'abc';
      input.processValue();
      expect(_.rootScope.model).toEqual('abc');
    }));

    it('should write to input only if value is different', inject(() {
      var scope = _.rootScope;
      var model = new NgModel(scope);
      var element = new dom.InputElement();
      dom.query('body').append(element);
      var input = new InputTextDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);
    }));
  });


  describe('type="checkbox"', () {
    it('should update input value from model', inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      scope.$apply(() {
        scope['model'] = true;
      });
      expect(element[0].checked).toBe(true);

      scope.$apply(() {
        scope['model'] = false;
      });
      expect(element[0].checked).toBe(false);
    }));


    it('should allow non boolean values like null, 0, 1', inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      scope.$apply(() {
        scope['model'] = 0;
      });
      expect(element[0].checked).toBe(false);

      scope.$apply(() {
        scope['model'] = 1;
      });
      expect(element[0].checked).toBe(true);

      scope.$apply(() {
        scope['model'] = null;
      });
      expect(element[0].checked).toBe(false);
    }));


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
