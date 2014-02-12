library ng_model_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(module((Module module) {
    module
      ..type(ControllerWithNoLove);
  }));

  beforeEach(inject((TestBed tb) => _ = tb));

  describe('type="text" like', () {
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
      var input = probe.directive(InputTextLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');
    }));

    it('should update model from the input value for type=number', inject(() {
      _.compile('<input type="number" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '12';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual(12);

      inputElement.value = '14';
      var input = probe.directive(InputNumberLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual(14);
    }));

    it('should update input type=number to blank when model is null', inject(() {
      _.compile('<input type="number" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '12';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual(12);

      _.rootScope.model = null;
      _.rootScope.$apply();
      expect(inputElement.value).toEqual('');
    }));

    it('should write to input only if value is different', inject((Injector i) {
      var scope = _.rootScope;
      var element = new dom.InputElement();
      var model = new NgModel(scope, new NodeAttrs(new DivElement()), element, i.createChild([new Module()]));
      dom.querySelector('body').append(element);
      var input = new InputTextLikeDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      // No update.  selectionStart/End is unchanged.
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      // Value updated.  selectionStart/End changed.
      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(3);
      expect(element.selectionEnd).toEqual(3);
    }));
  });

  describe('type="number" like', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="number" ng-model="model">');
      _.rootScope.$digest();

      _.rootScope.$apply('model = 42');
      expect((_.rootElement as dom.InputElement).value).toEqual('42');
    }));

    it('should update input value from model for range inputs', inject(() {
      _.compile('<input type="range" ng-model="model">');
      _.rootScope.$digest();

      _.rootScope.$apply('model = 42');
      expect((_.rootElement as dom.InputElement).value).toEqual('42');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="number" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '42';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual(42);

      inputElement.value = '43';
      var input = probe.directive(InputNumberLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual(43);
    }));

    it('should update model to null from a blank input value', inject(() {
      _.compile('<input type="number" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toBeNull();
    }));

    it('should update model from the input value for range inputs', inject(() {
      _.compile('<input type="range" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '42';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual(42);

      inputElement.value = '43';
      var input = probe.directive(InputNumberLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual(43);
    }));

    it('should update model to a native default value from a blank range input value', inject(() {
      _.compile('<input type="range" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = '';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toBeDefined();
    }));

    it('should render null as blank', inject(() {
      _.compile('<input type="number" ng-model="model">');
      _.rootScope.$digest();

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
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
      var input = probe.directive(InputTextLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');

    }));

    it('should write to input only if value is different', inject((Injector i) {
      var scope = _.rootScope;
      var element = new dom.InputElement();
      var model = new NgModel(scope, new NodeAttrs(new DivElement()), element, i.createChild([new Module()]));
      dom.querySelector('body').append(element);
      var input = new InputTextLikeDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(3);
      expect(element.selectionEnd).toEqual(3);
    }));
  });
  
  describe('type="search"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="search" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect((_.rootElement as dom.InputElement).value).toEqual('misko');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="search" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="search" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = 'abc';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('abc');

      inputElement.value = 'def';
      var input = probe.directive(InputTextLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');
    }));

    it('should write to input only if value is different', inject((Injector i) {
      var scope = _.rootScope;
      var element = new dom.InputElement();
      var model = new NgModel(scope, new NodeAttrs(new DivElement()), element, i.createChild([new Module()]));
      dom.querySelector('body').append(element);
      var input = new InputTextLikeDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      // No update.  selectionStart/End is unchanged.
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      // Value updated.  selectionStart/End changed.
      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(3);
      expect(element.selectionEnd).toEqual(3);
    }));
  });

  describe('no type attribute', () {
    it('should be set "text" as default value for "type" attribute', inject(() {
      _.compile('<input ng-model="model">');
      _.rootScope.$digest();
      expect((_.rootElement as dom.InputElement).attributes['type']).toEqual('text');
    }));

    it('should update input value from model', inject(() {
      _.compile('<input ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect((_.rootElement as dom.InputElement).value).toEqual('misko');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = 'abc';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('abc');

      inputElement.value = 'def';
      var input = probe.directive(InputTextLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');
    }));

    it('should write to input only if value is different', inject((Injector i) {
      var scope = _.rootScope;
      var element = new dom.InputElement();
      var model = new NgModel(scope, new NodeAttrs(new DivElement()), element, i.createChild([new Module()]));
      dom.querySelector('body').append(element);
      var input = new InputTextLikeDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(3);
      expect(element.selectionEnd).toEqual(3);
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

  describe('textarea', () {
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
      var textarea = probe.directive(InputTextLikeDirective);
      textarea.processValue();
      expect(_.rootScope.model).toEqual('def');

    }));

    // NOTE(deboer): This test passes on Dartium, but fails in the content_shell.
    // The Dart team is looking into this bug.
    xit('should write to input only if value is different', inject((Injector i) {
      var scope = _.rootScope;
      var element = new dom.TextAreaElement();
      var model = new NgModel(scope, new NodeAttrs(new DivElement()), element, i.createChild([new Module()]));
      dom.querySelector('body').append(element);
      var input = new InputTextLikeDirective(element, model, scope);

      element.value = 'abc';
      element.selectionStart = 1;
      element.selectionEnd = 2;

      model.render('abc');

      expect(element.value).toEqual('abc');
      expect(element.selectionStart).toEqual(1);
      expect(element.selectionEnd).toEqual(2);

      model.render('xyz');

      // Setting the value on a textarea doesn't update the selection the way it
      // does on input elements.  This stays unchanged.
      expect(element.value).toEqual('xyz');
      expect(element.selectionStart).toEqual(0);
      expect(element.selectionEnd).toEqual(0);
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

  describe('type="search"', () {
    it('should update input value from model', inject(() {
      _.compile('<input type="search" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = "matias"');
      expect((_.rootElement as dom.InputElement).value).toEqual('matias');
    }));

    it('should render null as the empty string', inject(() {
      _.compile('<input type="search" ng-model="model">');
      _.rootScope.$digest();

      expect((_.rootElement as dom.InputElement).value).toEqual('');

      _.rootScope.$apply('model = null');
      expect((_.rootElement as dom.InputElement).value).toEqual('');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<input type="search" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      var ngModel = probe.directive(NgModel);
      InputElement inputElement = probe.element;

      inputElement.value = 'xzy';
      _.triggerEvent(inputElement, 'change');
      expect(_.rootScope.model).toEqual('xzy');

      inputElement.value = '123';
      var input = probe.directive(InputTextLikeDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('123');
    }));
  });
  
  describe('contenteditable', () {
    it('should update content from model', inject(() {
      _.compile('<p contenteditable ng-model="model">');
      _.rootScope.$digest();

      expect(_.rootElement.text).toEqual('');

      _.rootScope.$apply('model = "misko"');
      expect(_.rootElement.text).toEqual('misko');
    }));

    it('should update model from the input value', inject(() {
      _.compile('<p contenteditable ng-model="model">');
      Element element = _.rootElement;

      element.innerHtml = 'abc';
      _.triggerEvent(element, 'change');
      expect(_.rootScope.model).toEqual('abc');

      element.innerHtml = 'def';
      var input = ngInjector(element).get(ContentEditableDirective);
      input.processValue();
      expect(_.rootScope.model).toEqual('def');
    }));
  });

  describe('pristine / dirty', () {
    it('should be set to pristine by default', inject((Scope scope) {
      _.compile('<input type="text" ng-model="my_model" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      expect(model.pristine).toEqual(true);
      expect(model.dirty).toEqual(false);
    }));

    it('should add and remove the correct CSS classes when set to dirty and to pristine', inject((Scope scope) {
      _.compile('<input type="text" ng-model="my_model" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);
      InputElement element = probe.element;

      model.dirty = true;
      expect(model.pristine).toEqual(false);
      expect(model.dirty).toEqual(true);
      expect(element.classes.contains('ng-pristine')).toBe(false);
      expect(element.classes.contains('ng-dirty')).toBe(true);

      model.pristine = true;
      expect(model.pristine).toEqual(true);
      expect(model.dirty).toEqual(false);
      expect(element.classes.contains('ng-pristine')).toBe(true);
      expect(element.classes.contains('ng-dirty')).toBe(false);
    }));

    it('should render the parent form/fieldset as dirty but not the other models', inject((Scope scope) {
      _.compile('<form name="myForm">' + 
                '  <fieldset name="myFieldset">' + 
                '    <input type="text" ng-model="my_model1" probe="myModel1" />' +
                '    <input type="text" ng-model="my_model2" probe="myModel2" />' +
                '   </fieldset>' +
                '</form>');

      var inputElement1    = _.rootScope.myModel1.element;
      var inputElement2    = _.rootScope.myModel2.element;
      var formElement      = _.rootScope.myForm.element;
      var fieldsetElement  = _.rootScope.myFieldset.element;

      expect(formElement.classes.contains('ng-pristine')).toBe(true);
      expect(formElement.classes.contains('ng-dirty')).toBe(false);

      expect(fieldsetElement.classes.contains('ng-pristine')).toBe(true);
      expect(fieldsetElement.classes.contains('ng-dirty')).toBe(false);

      expect(inputElement1.classes.contains('ng-pristine')).toBe(true);
      expect(inputElement1.classes.contains('ng-dirty')).toBe(false);

      expect(inputElement2.classes.contains('ng-pristine')).toBe(true);
      expect(inputElement2.classes.contains('ng-dirty')).toBe(false);

      inputElement1.value = '...hi...';
      _.triggerEvent(inputElement1, 'change');

      expect(formElement.classes.contains('ng-pristine')).toBe(false);
      expect(formElement.classes.contains('ng-dirty')).toBe(true);

      expect(fieldsetElement.classes.contains('ng-pristine')).toBe(false);
      expect(fieldsetElement.classes.contains('ng-dirty')).toBe(true);

      expect(inputElement1.classes.contains('ng-pristine')).toBe(false);
      expect(inputElement1.classes.contains('ng-dirty')).toBe(true);

      expect(inputElement2.classes.contains('ng-pristine')).toBe(true);
      expect(inputElement2.classes.contains('ng-dirty')).toBe(false);
    }));
  });

  describe('valid / invalid', () {
    it('should add and remove the correct flags when set to valid and to invalid', inject((Scope scope) {
      _.compile('<input type="text" ng-model="my_model" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);
      InputElement element = probe.element;

      model.invalid = true;
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);
      expect(element.classes.contains('ng-valid')).toBe(false);
      expect(element.classes.contains('ng-invalid')).toBe(true);

      model.valid = true;
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
      expect(element.classes.contains('ng-invalid')).toBe(false);
      expect(element.classes.contains('ng-valid')).toBe(true);
    }));

    it('should set the validity with respect to all existing validations when setValidity() is used', inject((Scope scope) {
      _.compile('<input type="text" ng-model="my_model" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.setValidity("required", false);
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      model.setValidity("format", false);
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      model.setValidity("format", true);
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      model.setValidity("required", true);
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));

    it('should register each error only once when invalid', inject((Scope scope) {
      _.compile('<input type="text" ng-model="my_model" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.setValidity("distinct-error", false);
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      model.setValidity("distinct-error", false);
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      model.setValidity("distinct-error", true);
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));
  });

  describe('text-like events', () {
    it('should update the binding on the "input" event', inject(() {
      _.compile('<input type="text" ng-model="model" probe="p">');
      Probe probe = _.rootScope.p;
      InputElement inputElement = probe.element;

      inputElement.value = 'waaaah';

      expect(_.rootScope.model).not.toEqual('waaaah');

      _.triggerEvent(inputElement, 'input');

      expect(_.rootScope.model).toEqual('waaaah');
    }));
  });

  describe('error messages', () {
    it('should produce a useful error for bad ng-model expressions', () {
      expect(async(() {
        _.compile('<div no-love><textarea ng-model=ctrl.love probe="loveProbe"></textarea></div');
        Probe probe = _.rootScope['loveProbe'];
        TextAreaElement inputElement = probe.element;

        inputElement.value = 'xzy';
        _.triggerEvent(inputElement, 'change');
        _.rootScope.$digest();
      })).toThrow('love');

    });
  });

  describe('reset()', () {
    it('should reset the model value to its original state', () {
      _.compile('<input type="text" ng-model="myModel" probe="i" />');
      _.rootScope.$apply('myModel = "animal"');

      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      expect(_.rootScope.myModel).toEqual('animal');
      expect(model.modelValue).toEqual('animal');
      expect(model.viewValue).toEqual('animal');

      _.rootScope.$apply('myModel = "man"');

      expect(_.rootScope.myModel).toEqual('man');
      expect(model.modelValue).toEqual('man');
      expect(model.viewValue).toEqual('man');

      model.reset();

      expect(_.rootScope.myModel).toEqual('animal');
      expect(model.modelValue).toEqual('animal');
      expect(model.viewValue).toEqual('animal');
    });
  });
});

@NgController(
    selector: '[no-love]',
    publishAs: 'ctrl')
class ControllerWithNoLove {
  var apathy = null;
}
