library ng_model_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  describe('type="text"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="text" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect((_.rootElement as dom.InputElement).value).toEqual('misko');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="text" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="text" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = 'abc';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('abc');

      inputElement.value = 'def';
      var input = probe.directive(InputTextDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');

    }));

    it('should write to input only if value is different', inject(() {
      var scope = _.rootScope;
      var model = new NgModel(scope, new NodeAttrs(new DivElement()));
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

  describe('type="password"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="password" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect((_.rootElement as dom.InputElement).value).toEqual('misko');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="password" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="password" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = 'abc';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('abc');

      inputElement.value = 'def';
      var input = probe.directive(InputPasswordDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');

    }));

    it('should write to input only if value is different', inject(() {
      var scope = _.rootScope;
      var model = new NgModel(scope, new NodeAttrs(new DivElement()));
      var element = new dom.InputElement();
      dom.query('body').append(element);
      var input = new InputPasswordDirective(element, model, scope);

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
      expect(element.checked).toBe(true);

      scope.$apply(() {
        scope['model'] = false;
      });
      expect(element.checked).toBe(false);
    }));


    it('should allow non boolean values like null, 0, 1', inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      scope.$apply(() {
        scope['model'] = 0;
      });
      expect(element.checked).toBe(false);

      scope.$apply(() {
        scope['model'] = 1;
      });
      expect(element.checked).toBe(true);

      scope.$apply(() {
        scope['model'] = null;
      });
      expect(element.checked).toBe(false);
    }));


    it('should update model from the input value', inject((Scope scope) {
      var element = _.compile('<input type="checkbox" ng-model="model">');

      element.checked = true;
      _.triggerEvent(element, 'change');
      expect(scope['model']).toBe(true);

      element.checked = false;
      _.triggerEvent(element, 'change');
      expect(scope['model']).toBe(false);
    }));

  });

  describe('type="textarea"', () {
    it('should update textarea value from model', inject(() {
      _.compile('<textarea ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.TextAreaElement).value).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect((_.rootElement as dom.TextAreaElement).value).toEqual('misko');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<textarea ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.TextAreaElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.TextAreaElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<textarea ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      TextAreaElement element = probe.element;

      element.value = 'abc';
      _.triggerEvent(element, 'change');
      expect(_.rootScope.model).toEqual('abc');

      element.value = 'def';
      var textarea = probe.directive(TextAreaDirective);
      textarea.processValue();
      expect(_.rootScope.model).toEqual('def');

    }));

    it('should write to input only if value is different', inject(() {
      var scope = _.rootScope;
      var model = new NgModel(scope, new NodeAttrs(new DivElement()));
      var element = new dom.TextAreaElement();
      dom.query('body').append(element);
      var input = new TextAreaDirective(element, model, scope);

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

  describe('type="number"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="number" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Invalid number
      _.rootScope.$apply('model = "foo"');
      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Valid number
      _.rootScope.$apply('model = 1234');
      expect((_.rootElement as dom.InputElement).value).toEqual('1234');
    }));

    it('should not render null or NaN values', inject(() {
      _.compile('<input type="number" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope['model'] = 0/0;
      _.rootScope.$digest();
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="number" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      // Valid value
      inputElement.value = '12345';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual(12345);

      // Invalid value
      inputElement.value = 'foo';
      var input = probe.directive(InputNumberDirective);
      input.processValue();
      expect(_.rootScope.model.isNaN).toBe(true);
    }));
  });

  describe('type="email"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="email" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Invalid e-mail
      _.rootScope.$apply('model = "foo"');
      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Valid e-mail
      _.rootScope.$apply('model = "foo@example.com"');
      expect((_.rootElement as dom.InputElement).value).toEqual('foo@example.com');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="email" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="email" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      // Valid value
      inputElement.value = 'foo@example.com';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('foo@example.com');

      // Invalid value
      inputElement.value = 'foo';
      var input = probe.directive(InputEmailDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual(null);
    }));
  });

  describe('type="url"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="url" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Invalid e-mail
      _.rootScope.$apply('model = "foo"');
      expect((_.rootElement as dom.InputElement).value).toEqual('');

      // Valid e-mail
      _.rootScope.$apply('model = "http://www.google.com"');
      expect((_.rootElement as dom.InputElement).value).toEqual(
          'http://www.google.com');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="url" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="url" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      // Valid value
      inputElement.value = 'http://www.google.com';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('http://www.google.com');

      // Invalid value
      inputElement.value = 'foo';
      var input = probe.directive(InputUrlDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual(null);
    }));
  });

  describe('type="radio"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="radio" name="color" value="red" ng-model="color" probe="r">' +
                '<input type="radio" name="color" value="green" ng-model="color" probe="g">' +
                '<input type="radio" name="color" value="blue" ng-model="color" probe="b">');
      _.rootScope.$digest();

      RadioButtonInputElement redBtn = _.rootScope.r.element;
      RadioButtonInputElement greenBtn = _.rootScope.g.element;
      RadioButtonInputElement blueBtn = _.rootScope.b.element;

      expect(redBtn.checked).toBe(false);
      expect(greenBtn.checked).toBe(false);
      expect(blueBtn.checked).toBe(false);
      
      // Should change correct element to checked.
      _.rootScope.$apply('color = "green"');

      expect(redBtn.checked).toBe(false);
      expect(greenBtn.checked).toBe(true);
      expect(blueBtn.checked).toBe(false);
      
      // Non-existing element.
      _.rootScope.$apply('color = "unknown"');

      expect(redBtn.checked).toBe(false);
      expect(greenBtn.checked).toBe(false);
      expect(blueBtn.checked).toBe(false);
      
      // Should update model with value of checked element.
      _.triggerEvent(redBtn, 'click');

      expect(_.rootScope['color']).toEqual('red');
      expect(redBtn.checked).toBe(true);
      expect(greenBtn.checked).toBe(false);
      expect(blueBtn.checked).toBe(false);

      _.triggerEvent(greenBtn, 'click');
      expect(_.rootScope['color']).toEqual('green');
      expect(redBtn.checked).toBe(false);
      expect(greenBtn.checked).toBe(true);
      expect(blueBtn.checked).toBe(false);
    }));
  });

});
