library ng_model_spec;

import '../_specs.dart';
import '../_test_bed.dart';
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

  describe('select single', () {
    it('should update input value from model', inject(() {
      _.compile(
          '''<select ng-model="model">
             <option value="a">a</option>
             <option value="b">b</option>
             <option value="c">c</option>
             <option value="d">d</option>
             </select>''');
      _.rootScope.$digest();

      _.rootScope.$apply('model = "d"');
      expect(_.rootElement.prop('value')).toEqual('d');
      expect(_.rootScope['model']).toEqual('d');
      _.rootScope.$apply('model = "e"');
      expect(_.rootElement.prop('value')).toEqual('');
      expect(_.rootScope['model']).toEqual(null);
    }));

    it('should update model from the input value', inject(() {
      _.compile(
          '''<select ng-model="model" probe="p">
             <option value="a">a</option>
             <option value="b">b</option>
             <option value="c">c</option>
             <option value="d">d</option>
             </select>''');
      Probe probe = _.rootScope['p'];
      var select = probe.directive(SelectDirective);

      (probe.element as SelectElement).selectedIndex = 3;
      select.processValue();
      expect(_.rootScope['model']).toEqual('d');
    }));
  });

  describe('select multiple', () {
    it('should update input value from model', inject(() {
      _.compile(
          '''<select ng-model="model" multiple>
             <option value="a">a</option>
             <option value="b">b</option>
             <option value="c">c</option>
             <option value="d">d</option>
             </select>''');
      _.rootScope.$digest();

      _.rootScope.$apply('model = ["d"]');
      expect(_.rootElement.prop('value')).toEqual('d');
      expect(_.rootScope['model']).toEqual(['d']);
      _.rootScope.$apply('model = ["d", "a"]');

      var options = _.rootElement.find('option');
      expect(options[0].selected).toEqual(true);
      expect(options[1].selected).toEqual(false);
      expect(options[2].selected).toEqual(false);
      expect(options[3].selected).toEqual(true);

      expect(_.rootScope['model']).toEqual(['a', 'd']);

    }));

    it('should update model from the input value', inject(() {
      _.compile(
          '''<select ng-model="model" probe="p" multiple>
             <option value="a">a</option>
             <option value="b">b</option>
             <option value="c">c</option>
             <option value="d">d</option>
             </select>''');
      Probe probe = _.rootScope['p'];
      var select = probe.directive(SelectDirective);


      (probe.element as SelectElement).selectedIndex = 2;
      select.processValue();
      expect(_.rootScope['model']).toEqual(['c']);
      var options = probe.element.queryAll('option');
      options[0].selected = true;
      options[1].selected = false;
      options[2].selected = false;
      options[3].selected = true;
      select.processValue();
      expect(_.rootScope['model']).toEqual(['a', 'd']);
    }));
  });
});
