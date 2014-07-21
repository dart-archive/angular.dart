library ng_model_spec;

import '../_specs.dart';
import 'dart:html' as dom;

//-----------------------------------------------------------------------------
// Utility functions

/* This function simulates typing the given text into the input field. The
 * text will be added wherever the insertion point happens to be. This method
 * has as side-effect to set the focus on the input (without setting the
 * focus, the text dispatch may not work).
 */
void simulateTypingText(InputElement input, String text) {
  input..focus()..dispatchEvent(new TextEvent('textInput', data: text));
}

bool simulateTypingTextWithConfirmation(InputElement input, String text,
                                        { bool shouldWorkForChrome : true }) {
  bool result;
  String val = input.value;
  try {
    simulateTypingText(input, text);
    result = input.value == val + text;
  } catch (e) {
    result = false;
  }
  if (!result && shouldWorkForChrome) expect(isBrowser('Chrome')).toBeFalsy();
  return result;
}

bool isBrowser(String pattern) => dom.window.navigator.userAgent.indexOf(pattern) > 0;

//-----------------------------------------------------------------------------

void main() {
  describe('ng-model', () {
    TestBed _;
    DirectiveInjector dirInjector;

    beforeEachModule((Module module) {
      module
          ..bind(ControllerWithNoLove)
          ..bind(MyCustomInputValidator)
          ..bind(CountingValidator);
    });

    beforeEach((TestBed tb) {
      _ = tb;
      dirInjector = new DirectiveInjector(null, _.injector, null, null, null, null, null);
    });

    describe('type="text" like', () {
      it('should update input value from model', () {
        _.compile('<input type="text" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "misko"');
        expect((_.rootElement as dom.InputElement).value).toEqual('misko');
      });

      it('should render null as the empty string', () {
        _.compile('<input type="text" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        var inputEl = _.compile('<input type="text" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);

        inputEl.value = 'abc';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        inputEl.value = 'def';
        var input = injector.get(InputTextLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('def');
      });

      it('should write to input only if the value is different',
        (Injector i, Animate animate) {

        NodeAttrs nodeAttrs = new NodeAttrs(new DivElement());

        var scope = _.rootScope;
        var element = new dom.InputElement();
        var ngElement = new NgElement(element, scope, animate);
        var ngModelOptions = new NgModelOptions();

        nodeAttrs['ng-model'] = 'model';
        var model = new NgModel(scope, ngElement, dirInjector,
            nodeAttrs, new Animate(), null);
        dom.querySelector('body').append(element);
        var input = new InputTextLike(element, model, scope, ngModelOptions);

        element
            ..value = 'abc'
            ..selectionStart = 1
            ..selectionEnd = 2;

        scope.apply(() {
          scope.context['model'] = 'abc';
        });

        expect(element.value).toEqual('abc');
        // No update.  selectionStart/End is unchanged.
        expect(element.selectionStart).toEqual(1);
        expect(element.selectionEnd).toEqual(2);

        scope.apply(() {
          scope.context['model'] = 'xyz';
        });

        // Value updated.  selectionStart/End changed.
        expect(element.value).toEqual('xyz');
        expect(element.selectionStart).toEqual(3);
        expect(element.selectionEnd).toEqual(3);
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var inputEl = _.compile('<input type="text" ng-model="model">');
        var ngModel = ngInjector(inputEl).get(NgModel);

        ngModel.render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('type="number" or type="range"', () {

      it('should update model from the input value for type=number', () {
        var inputEl = _.compile('<input type="number" ng-model="model">');
        var injector = ngInjector(inputEl);

        inputEl.value = '12';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual(12);

        inputEl.value = '14';
        var input = injector.get(InputNumberLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual(14);
      });

      it('should update input type=number to blank when model is null', () {
        var inputEl = _.compile('<input type="number" ng-model="model">');

        inputEl.value = '12';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual(12);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputEl.value).toEqual('');
      });

      it('should be invalid when the input value results in a NaN value', () {
        var inputEl = _.compile('<input type="number" ng-model="model">');
        inputEl.value = 'aa';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model'].isNaN).toBe(true);
        var injector = ngInjector(inputEl);
        var ngModel = injector.get(NgModel);
        expect(ngModel.valid).toBe(false);
      });

      it('should leave input unchanged when text does not represent a valid number', (Injector i) {
        var modelFieldName = 'modelForNumFromInvalid1';
        var element = _.compile('<input type="number" ng-model="$modelFieldName">');
        dom.querySelector('body').append(element);

        if (!simulateTypingTextWithConfirmation(element, '1')) return; // skip test.
        element.value = ''; // reset input

        // This test will progressively enter the text '1e1'
        // '1' is a valid number.
        // '1e' is not a valid number.
        // '1e1' is again a valid number (with an exponent)

        simulateTypingText(element, '1');
        _.triggerEvent(element, 'change');
        expect(element.value).toEqual('1');
        expect(_.rootScope.context[modelFieldName]).toEqual(1);

        simulateTypingText(element, 'e');
        // Because the text is not a valid number, the element value is empty.
        expect(element.value).toEqual('');
        // When the input is invalid, the model is [double.NAN]:
        _.triggerEvent(element, 'change');
        expect(_.rootScope.context[modelFieldName].isNaN).toBeTruthy();

        simulateTypingText(element, '1');
        _.triggerEvent(element, 'change');
        expect(element.value).toEqual('1e1');
        expect(_.rootScope.context[modelFieldName]).toEqual(10);
      });

      it('should not reformat user input to equivalent numeric representation', (Injector i) {
        var modelFieldName = 'modelForNumFromInvalid2';
        var element = _.compile('<input type="number" ng-model="$modelFieldName">');
        dom.querySelector('body').append(element);

        if (!simulateTypingTextWithConfirmation(element, '1')) return; // skip test.
        element.value = ''; // reset input

        simulateTypingText(element, '1e-1');
        expect(element.value).toEqual('1e-1');
        expect(_.rootScope.context[modelFieldName]).toEqual(0.1);
      });

      it('should update input value from model', () {
        _.compile('<input type="number" ng-model="model">');
        _.rootScope.apply();

        _.rootScope.apply('model = 42');
        expect((_.rootElement as dom.InputElement).value).toEqual('42');
      });

      it('should update input value from model for range inputs', () {
        _.compile('<input type="range" ng-model="model">');
        _.rootScope.apply();

        _.rootScope.apply('model = 42');
        expect((_.rootElement as dom.InputElement).value).toEqual('42');
      });

      it('should update model from the input value', () {
        var inputEl = _.compile('<input type="number" ng-model="model">');
        var injector = ngInjector(inputEl);

        inputEl.value = '42';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual(42);

        inputEl.value = '43';
        var input = injector.get(InputNumberLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual(43);
      });

      it('should update model to NaN from a blank input value', () {
        _.compile('<input type="number" ng-model="model">');
        InputElement inputEl = _.rootElement;
        inputEl.value = '';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model'].isNaN).toBeTruthy();
      });

      it('should update model from the input value for range inputs', () {
        _.compile('<input type="range" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        inputEl.value = '42';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual(42);

        inputEl.value = '43';
        var input = injector.get(InputNumberLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual(43);
      });

      it('should update model to a native default value from a blank range input value', () {
        _.compile('<input type="range" ng-model="model">');
        InputElement inputEl = _.rootElement;
        inputEl.value = '';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toBeDefined();
      });

      it('should render null as blank', () {
        _.compile('<input type="number" ng-model="model">');
        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        _.compile('<input type="number" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        injector.get(NgModel).render(123);
        scope.context['model'] = 123;
        expect(inputEl.value).not.toEqual('123');

        scope.apply();
        expect(inputEl.value).toEqual('123');
      });

    });

    describe('type="password"', () {
      it('should update input value from model', () {
        _.compile('<input type="password" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "misko"');
        expect((_.rootElement as dom.InputElement).value).toEqual('misko');
      });

      it('should render null as the empty string', () {
        _.compile('<input type="password" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        _.compile('<input type="password" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        inputEl.value = 'abc';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        inputEl.value = 'def';
        var input = injector.get(InputTextLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('def');

      });

      it('should write to input only if value is different', (Injector i, Animate animate) {

        NodeAttrs nodeAttrs = new NodeAttrs(new DivElement());

        var scope = _.rootScope;
        var element = new dom.InputElement();
        var ngElement = new NgElement(element, scope, animate);
        var ngModelOptions = new NgModelOptions();

        nodeAttrs['ng-model'] = 'model';
        var model = new NgModel(scope, ngElement, dirInjector,
            nodeAttrs, new Animate(), null);
        dom.querySelector('body').append(element);
        var input = new InputTextLike(element, model, scope, ngModelOptions);

        element
          ..value = 'abc'
          ..selectionStart = 1
          ..selectionEnd = 2;

        scope.apply(() {
          scope.context['model'] = 'abc';
        });

        expect(element.value).toEqual('abc');
        expect(element.selectionStart).toEqual(1);
        expect(element.selectionEnd).toEqual(2);

        scope.apply(() {
          scope.context['model'] = 'xyz';
        });

        expect(element.value).toEqual('xyz');
        expect(element.selectionStart).toEqual(3);
        expect(element.selectionEnd).toEqual(3);
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        _.compile('<input type="password" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('type="search"', () {
      it('should update input value from model', () {
        _.compile('<input type="search" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "misko"');
        expect((_.rootElement as dom.InputElement).value).toEqual('misko');
      });

      it('should render null as the empty string', () {
        _.compile('<input type="search" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        _.compile('<input type="search" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        inputEl.value = 'abc';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        inputEl.value = 'def';
        var input = injector.get(InputTextLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('def');
      });

      it('should write to input only if value is different',
        (Injector i, Animate animate) {

        NodeAttrs nodeAttrs = new NodeAttrs(new DivElement());

        var scope = _.rootScope;
        var element = new dom.InputElement();
        var ngElement = new NgElement(element, scope, animate);
        var ngModelOptions = new NgModelOptions();

        nodeAttrs['ng-model'] = 'model';
        var model = new NgModel(scope, ngElement, dirInjector,
            nodeAttrs, new Animate(), null);
        dom.querySelector('body').append(element);
        var input = new InputTextLike(element, model, scope, ngModelOptions);

        element
          ..value = 'abc'
          ..selectionStart = 1
          ..selectionEnd = 2;

        scope.apply(() {
          scope.context['model'] = 'abc';
        });

        expect(element.value).toEqual('abc');
        // No update.  selectionStart/End is unchanged.
        expect(element.selectionStart).toEqual(1);
        expect(element.selectionEnd).toEqual(2);

        scope.apply(() {
          scope.context['model'] = 'xyz';
        });

        // Value updated.  selectionStart/End changed.
        expect(element.value).toEqual('xyz');
        expect(element.selectionStart).toEqual(3);
        expect(element.selectionEnd).toEqual(3);
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        _.compile('<input type="search" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    // Test temporarily turned off.
    // Typeless input fields work fine (tested manually).
    // Also the test passes if ran by itself with ddescribe.
    // TODO(radokirov): Find out the reason why this test fails when ran
    // together with the whole testsuite.
    xdescribe('no type attribute', () {
      it('should be set "text" as default value for "type" attribute', () {
        _.compile('<input ng-model="model">');
        _.rootScope.apply();
        expect((_.rootElement as dom.InputElement).attributes['type']).toEqual('text');
      });

      it('should update input value from model', () {
        _.compile('<input ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "misko"');
        expect((_.rootElement as dom.InputElement).value).toEqual('misko');
      });

      it('should render null as the empty string', () {
        _.compile('<input ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        var inputEl = _.compile('<input ng-model="model">');
        var injector = ngInjector(inputEl);


        inputEl.value = 'abc';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        inputEl.value = 'def';
        var input = injector.get(InputTextLike);
        expect(_.rootScope.context['model']).toEqual('def');
      });

      it('should write to input only if value is different',  (Injector i, Animate animate) {

        NodeAttrs nodeAttrs = new NodeAttrs(new DivElement());

        var scope = _.rootScope;
        var element = new dom.InputElement();
        var ngElement = new NgElement(element, scope, animate);
        var ngModelOptions = new NgModelOptions();

        nodeAttrs['ng-model'] = 'model';
        var model = new NgModel(scope, ngElement, dirInjector,
            nodeAttrs, new Animate(), null);
        dom.querySelector('body').append(element);
        var input = new InputTextLike(element, model, scope, ngModelOptions);

        element
          ..value = 'abc'
          ..selectionStart = 1
          ..selectionEnd = 2;

        scope.apply(() {
          scope.context['model'] = 'abc';
        });

        expect(element.value).toEqual('abc');
        expect(element.selectionStart).toEqual(1);
        expect(element.selectionEnd).toEqual(2);

        scope.apply(() {
          scope.context['model'] = 'xyz';
        });

        expect(element.value).toEqual('xyz');
        expect(element.selectionStart).toEqual(3);
        expect(element.selectionEnd).toEqual(3);
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        _.compile('<input ng-model="model">');
        InputElement inputEl = probe.element;

        ngModel.render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('type="checkbox"', () {
      it('should update input value from model', (Scope scope) {
        var element = _.compile('<input type="checkbox" ng-model="model">');

        scope.apply(() {
          scope.context['model'] = true;
        });
        expect(element.checked).toBe(true);

        scope.apply(() {
          scope.context['model'] = false;
        });
        expect(element.checked).toBe(false);
      });

      it('should render as dirty when checked', (Scope scope) {
        var element = _.compile('<input type="text" ng-model="my_model" />');
        var injector = ngInjector(element);
        var model = injector.get(NgModel);

        expect(model.pristine).toEqual(true);
        expect(model.dirty).toEqual(false);

        _.triggerEvent(element, 'change');

        expect(model.pristine).toEqual(false);
        expect(model.dirty).toEqual(true);
      });

      it('should update input value from model using ng-true-value/false', (Scope scope) {
        var element = _.compile('<input type="checkbox" ng-model="model" ng-true-value="1" ng-false-value="0">');

        scope.apply(() {
          scope.context['model'] = 1;
        });
        expect(element.checked).toBe(true);

        scope.apply(() {
          scope.context['model'] = 0;
        });
        expect(element.checked).toBe(false);

        element.checked = true;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toBe(1);

        element.checked = false;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toBe(0);
      });

      it('should allow non boolean values like null, 0, 1', (Scope scope) {
        var element = _.compile('<input type="checkbox" ng-model="model">');

        scope.apply(() {
          scope.context['model'] = 0;
        });
        expect(element.checked).toBe(false);

        scope.apply(() {
          scope.context['model'] = 1;
        });
        expect(element.checked).toBe(true);

        scope.apply(() {
          scope.context['model'] = null;
        });
        expect(element.checked).toBe(false);
      });

      it('should update model from the input value', (Scope scope) {
        var element = _.compile('<input type="checkbox" ng-model="model">');

        element.checked = true;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toBe(true);

        element.checked = false;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toBe(false);
      });

      it('should update model from the input using ng-true-value/false', (Scope scope) {
        var element = _.compile('<input type="checkbox" ng-model="model" '
                                'ng-true-value="yes" ng-false-value="no">');
        scope.apply(() {
          scope.context['yes'] = 'yes sir!';
          scope.context['no'] = 'no, sorry';
        });

        element.checked = true;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toEqual('yes sir!');

        element.checked = false;
        _.triggerEvent(element, 'change');
        expect(scope.context['model']).toEqual('no, sorry');
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var inputEl = _.compile('<input type="checkbox" ng-model="model" >');
        var injector = ngInjector(inputEl);

        injector.get(NgModel).render('xyz');
        scope.context['model'] = true;
        expect(inputEl.checked).toBe(false);

        scope.apply();
        expect(inputEl.checked).toBe(true);
      });
    });

    describe('textarea', () {
      it('should update textarea value from model', () {
        _.compile('<textarea ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.TextAreaElement).value).toEqual('');

        _.rootScope.apply('model = "misko"');
        expect((_.rootElement as dom.TextAreaElement).value).toEqual('misko');
      });

      it('should render null as the empty string', () {
        _.compile('<textarea ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.TextAreaElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.TextAreaElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        var element = _.compile('<textarea ng-model="model">');
        var injector = ngInjector(element);

        element.value = 'abc';
        _.triggerEvent(element, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        element.value = 'def';
        var textarea = injector.get(InputTextLike);
        textarea.processValue();
        expect(_.rootScope.context['model']).toEqual('def');

      });

      // NOTE(deboer): This test passes on Dartium, but fails in the content_shell.
      // The Dart team is looking into this bug.
      xit('should write to input only if value is different',
        (Injector i, Animate animate) {

        NodeAttrs nodeAttrs = new NodeAttrs(new DivElement());

        var scope = _.rootScope;
        var element = new dom.TextAreaElement();
        var ngElement = new NgElement(element, scope, animate);
        var ngModelOptions = new NgModelOptions();

        nodeAttrs['ng-model'] = 'model';
        var model = new NgModel(scope, ngElement, dirInjector,
            nodeAttrs, new Animate(), null);
        dom.querySelector('body').append(element);
        var input = new InputTextLike(element, model, scope, ngModelOptions);

        element
          ..value = 'abc'
          ..selectionStart = 1
          ..selectionEnd = 2;

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
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var inputEl = _.compile('<textarea ng-model="model"></textarea>');
        var injector = ngInjector(inputEl);

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('type="radio"', () {
      it('should update input value from model', () {
        _.compile('<div>'
                    '<input type="radio" name="color" value="red" ng-model="color">'
                    '<input type="radio" name="color" value="green" ng-model="color">'
                    '<input type="radio" name="color" value="blue" ng-model="color">'
                  '</div>');
        _.rootScope.apply();

        var inputs = ngQuery(_.rootElement, 'input');

        RadioButtonInputElement redBtn = inputs[0];
        RadioButtonInputElement greenBtn = inputs[1];
        RadioButtonInputElement blueBtn = inputs[2];

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        // Should change correct element to checked.
        _.rootScope.apply('color = "green"');

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(true);
        expect(blueBtn.checked).toBe(false);

        // Non-existing element.
        _.rootScope.apply('color = "unknown"');

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        // Should update model with value of checked element.
        _.triggerEvent(redBtn, 'click');

        expect(_.rootScope.context['color']).toEqual('red');
        expect(redBtn.checked).toBe(true);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        _.triggerEvent(greenBtn, 'click');
        expect(_.rootScope.context['color']).toEqual('green');
        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(true);
        expect(blueBtn.checked).toBe(false);
      });

      it('should support ng-value', () {
        _.compile('<div>'
                    '<input type="radio" name="color" ng-value="red" ng-model="color">'
                    '<input type="radio" name="color" ng-value="green" ng-model="color">'
                    '<input type="radio" name="color" ng-value="blue" ng-model="color">'
                  '</div>');

        var red = {'name': 'RED'};
        var green = {'name': 'GREEN'};
        var blue = {'name': 'BLUE'};
        _.rootScope.context
          ..['red'] = red
          ..['green'] = green
          ..['blue'] = blue;

        _.rootScope.apply();

        var inputs = ngQuery(_.rootElement, 'input');

        RadioButtonInputElement redBtn = inputs[0];
        RadioButtonInputElement greenBtn = inputs[1];
        RadioButtonInputElement blueBtn = inputs[2];

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        // Should change correct element to checked.
        _.rootScope.context['color'] = green;
        _.rootScope.apply();

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(true);
        expect(blueBtn.checked).toBe(false);

        // Non-existing element.
        _.rootScope.context['color'] = {};
        _.rootScope.apply();

        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        // Should update model with value of checked element.
        _.triggerEvent(redBtn, 'click');

        expect(_.rootScope.context['color']).toEqual(red);
        expect(redBtn.checked).toBe(true);
        expect(greenBtn.checked).toBe(false);
        expect(blueBtn.checked).toBe(false);

        _.triggerEvent(greenBtn, 'click');
        expect(_.rootScope.context['color']).toEqual(green);
        expect(redBtn.checked).toBe(false);
        expect(greenBtn.checked).toBe(true);
        expect(blueBtn.checked).toBe(false);
      });

      it('should render as dirty when checked', (Scope scope) {
        var element = _.compile(
          '<div>'
          '  <input type="radio" id="on" ng-model="my_model" value="on" />'
          '  <input type="radio" id="off" ng-model="my_model" value="off" />'
          '</div>'
        );
        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        var input1 = element.querySelector("#on");
        var input2 = element.querySelector("#off");

        scope.apply();

        expect(model.pristine).toEqual(true);
        expect(model.dirty).toEqual(false);

        expect(input1).not.toHaveClass("ng-dirty");
        expect(input2).not.toHaveClass("ng-dirty");
        expect(input1).toHaveClass("ng-pristine");
        expect(input2).toHaveClass("ng-pristine");

        input1.checked = true;
        _.triggerEvent(input1, 'click');
        scope.apply();

        expect(model.pristine).toEqual(false);
        expect(model.dirty).toEqual(true);

        input1.checked = false;
        input2.checked = true;
        _.triggerEvent(input2, 'click');
        scope.apply();

        expect(input1).toHaveClass("ng-dirty");
        expect(input2).toHaveClass("ng-dirty");
        expect(input1).not.toHaveClass("ng-pristine");
        expect(input2).not.toHaveClass("ng-pristine");
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var element = _.compile(
          '<div>'
          '  <input type="radio" id="on" ng-model="model" value="on" />'
          '  <input type="radio" id="off" ng-model="model" value="off" />'
          '</div>'
        );
        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        var input1 = element.querySelector("#on");
        var input2 = element.querySelector("#off");

        model.render('on');
        scope.context['model'] = 'on';

        expect(input1.checked).toBe(false);
        expect(input2.checked).toBe(false);

        scope.apply();

        expect(input1.checked).toBe(true);
        expect(input2.checked).toBe(false);
      });
    });

    describe('type="search"', () {
      it('should update input value from model', () {
        _.compile('<input type="search" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "matias"');
        expect((_.rootElement as dom.InputElement).value).toEqual('matias');
      });

      it('should render null as the empty string', () {
        _.compile('<input type="search" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        var inputEl = _.compile('<input type="search" ng-model="model">');
        var injector = ngInjector(inputEl);

        inputEl.value = 'xzy';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('xzy');

        inputEl.value = '123';
        var input = injector.get(InputTextLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('123');
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var inputEl = _.compile('<input type="search" ng-model="model">');
        var injector = ngInjector(inputEl);

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('type="tel"', () {
      it('should update input value from model', () {
        _.compile('<input type="tel" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = "matias"');
        expect((_.rootElement as dom.InputElement).value).toEqual('matias');
      });

      it('should render null as the empty string', () {
        _.compile('<input type="tel" ng-model="model">');
        _.rootScope.apply();

        expect((_.rootElement as dom.InputElement).value).toEqual('');

        _.rootScope.apply('model = null');
        expect((_.rootElement as dom.InputElement).value).toEqual('');
      });

      it('should update model from the input value', () {
        _.compile('<input type="tel" ng-model="model">');
        var injector = ngInjector('input', _.rootElement);
        InputElement inputEl = _.rootElement;

        inputEl.value = 'xzy';
        _.triggerEvent(inputEl, 'change');
        expect(_.rootScope.context['model']).toEqual('xzy');

        inputEl.value = '123';
        var input = injector.get(InputTextLike);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('123');
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        var inputEl = _.compile('<input type="tel" ng-model="model">');
        var injector = ngInjector(inputEl);

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(inputEl.value).not.toEqual('xyz');

        scope.apply();
        expect(inputEl.value).toEqual('xyz');
      });
    });

    describe('contenteditable', () {
      it('should update content from model', () {
        _.compile('<p contenteditable ng-model="model">');
        _.rootScope.apply();

        expect(_.rootElement).toHaveText('');

        _.rootScope.apply('model = "misko"');
        expect(_.rootElement).toHaveText('misko');
      });

      it('should update model from the input value', () {
        var element = _.compile('<p contenteditable ng-model="model">');

        element.innerHtml = 'abc';
        _.triggerEvent(element, 'change');
        expect(_.rootScope.context['model']).toEqual('abc');

        element.innerHtml = 'def';
        var input = ngInjector(element).get(ContentEditable);
        input.processValue();
        expect(_.rootScope.context['model']).toEqual('def');
      });

      it('should only render the input value upon the next digest', (Scope scope) {
        Element element = _.compile('<div contenteditable ng-model="model"></div>');
        var injector = ngInjector(element);

        injector.get(NgModel).render('xyz');
        scope.context['model'] = 'xyz';
        expect(element).not.toHaveText('xyz');

        scope.apply();
        expect(element).toHaveText('xyz');
      });
    });

    describe('pristine / dirty', () {
      it('should be set to pristine by default', (Scope scope) {
        _.compile('<input type="text" ng-model="my_model" >');
        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        expect(model.pristine).toEqual(true);
        expect(model.dirty).toEqual(false);
      });

      it('should add and remove the correct CSS classes when set to dirty and to pristine', (Scope scope) {
        var element = _.compile('<input type="text" ng-model="my_model" >');
        var injector = ngInjector(element);
        NgModel model = injector.get(NgModel);

        model.addInfo('ng-dirty');
        scope.apply();

        expect(model.pristine).toEqual(false);
        expect(model.dirty).toEqual(true);
        expect(element).not.toHaveClass('ng-pristine');
        expect(element).toHaveClass('ng-dirty');

        model.removeInfo('ng-dirty');
        scope.apply();

        expect(model.pristine).toEqual(true);
        expect(model.dirty).toEqual(false);
        expect(element).toHaveClass('ng-pristine');
        expect(element).not.toHaveClass('ng-dirty');
      });

      // TODO(matias): figure out why the 2nd apply is optional
      it('should render the parent form/fieldset as dirty but not the other models',
        (Scope scope) {

        _.compile('<form name="myForm">'
                  '  <fieldset name="myFieldset">'
                  '    <input type="text" ng-model="my_model1" >'
                  '    <input type="text" ng-model="my_model2" >'
                  '   </fieldset>'
                  '</form>');

        var inputs = ngQuery(_.rootElement, 'input');

        var formElement      = _.rootScope.context['myForm'].element.node;
        var fieldsetElement  = _.rootScope.context['myFieldset'].element.node;
        var inputEl1    = inputs[0];
        var inputEl2    = inputs[1];

        scope.apply();

        expect(formElement).toHaveClass('ng-pristine');
        expect(formElement).not.toHaveClass('ng-dirty');

        expect(fieldsetElement).toHaveClass('ng-pristine');
        expect(fieldsetElement).not.toHaveClass('ng-dirty');

        expect(inputEl1).toHaveClass('ng-pristine');
        expect(inputEl1).not.toHaveClass('ng-dirty');

        expect(inputEl2).toHaveClass('ng-pristine');
        expect(inputEl2).not.toHaveClass('ng-dirty');

        inputEl1.value = '...hi...';
        _.triggerEvent(inputEl1, 'change');
        scope.apply();

        expect(formElement).not.toHaveClass('ng-pristine');
        expect(formElement).toHaveClass('ng-dirty');

        expect(fieldsetElement).not.toHaveClass('ng-pristine');
        expect(fieldsetElement).toHaveClass('ng-dirty');

        expect(inputEl1).not.toHaveClass('ng-pristine');
        expect(inputEl1).toHaveClass('ng-dirty');

        expect(inputEl2).toHaveClass('ng-pristine');
        expect(inputEl2).not.toHaveClass('ng-dirty');
      });
    });

    describe('validation', () {
      it('should happen automatically when the scope changes', (Scope scope) {
        _.compile('<input type="text" ng-model="model" required>');
        _.rootScope.apply();

        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        expect(model.invalid).toBe(true);
        expect(model.valid).toBe(false);

        _.rootScope.apply('model = "viljami"');

        expect(model.invalid).toBe(false);
        expect(model.valid).toBe(true);
      });

      it('should happen automatically upon user input via the onInput event', () {
        var inputEl = _.compile('<input type="text" ng-model="model" required>');
        _.rootScope.apply();

        var injector = ngInjector(inputEl);
        var model = injector.get(NgModel);

        expect(model.invalid).toBe(true);
        expect(model.valid).toBe(false);

        inputEl.value = 'some value';
        _.triggerEvent(inputEl, 'input');

        expect(model.invalid).toBe(false);
        expect(model.valid).toBe(true);
      });
    });

    describe('valid / invalid', () {
      it('should add and remove the correct flags when set to valid and to invalid', (Scope scope) {
        var element = _.compile('<input type="text" ng-model="my_model" >');
        var injector = ngInjector(element);
        var model = injector.get(NgModel);

        model.addError('ng-required');
        model.validate();
        scope.apply();

        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        //expect(element).not.toHaveClass('ng-valid');
        expect(element).toHaveClass('ng-invalid');

        model.removeError('ng-required');
        model.validate();
        scope.apply();

        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(element).not.toHaveClass('ng-invalid');
        // expect(element).toHaveClass('ng-valid');
      });

      it('should set the validity with respect to all existing validations when setValidity() is used', (Scope scope) {
        _.compile('<input type="text" ng-model="my_model">');
        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        model.addError("required");
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        model.addError("format");
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        model.removeError("format");
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        model.removeError("required");
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });

      it('should register each error only once when invalid', (Scope scope) {
        _.compile('<input type="text" ng-model="my_model">');
        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        model.addError("distinct-error");
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        model.addError("distinct-error");
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        model.removeError("distinct-error");
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });
    });

    describe('error handling', () {
      it('should return true or false depending on if an error exists on a form',
        (Scope scope, TestBed _) {

        _.compile('<input type="text" ng-model="input" name="input" >');
        scope.apply();

        var injector = ngInjector('input', _.rootElement);
        NgModel model = injector.get(NgModel);
        expect(model.hasErrorState('big-failure')).toBe(false);

        model.addError("big-failure");
        expect(model.hasErrorState('big-failure')).toBe(true);

        model.removeError("big-failure");
        expect(model.hasErrorState('big-failure')).toBe(false);
      });
    });

    describe('text-like events', () {
      it('should update the binding on the "input" event', () {
        var inputEl = _.compile('<input type="text" ng-model="model">');
        inputEl.value = 'waaaah';
        expect(_.rootScope.context['model']).not.toEqual('waaaah');

        _.triggerEvent(inputEl, 'input');
        expect(_.rootScope.context['model']).toEqual('waaaah');
      });
    });

    describe('error messages', () {
      it('should produce a useful error for bad ng-model expressions', () {
        expect(async(() {
          _.compile('<div no-love><textarea ng-model=ctrl.love></textarea></div');
          TextAreaElement inputEl = _.rootElement.querySelector('textarea');

          inputEl.value = 'xzy';
          _.triggerEvent(inputEl, 'change');
          _.rootScope.apply();
        })).toThrow('love');

      });
    });

    describe('reset()', () {
      it('should reset the model value to its original state', () {
        _.compile('<input type="text" ng-model="myModel">');
        _.rootScope.apply('myModel = "animal"');

        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');

        _.rootScope.apply('myModel = "man"');

        expect(_.rootScope.context['myModel']).toEqual('man');
        expect(model.modelValue).toEqual('man');
        expect(model.viewValue).toEqual('man');

        model.reset();

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');
      });
    });

    it('should set the model to be untouched when the model is reset', () {
      var input = _.compile('<input type="text" ng-model="myModel">');
      var injector = ngInjector(input);
      var model = injector.get(NgModel);

      expect(model.touched).toBe(false);
      expect(model.untouched).toBe(true);

      _.triggerEvent(input, 'blur');

      expect(model.touched).toBe(true);
      expect(model.untouched).toBe(false);

      model.reset();

      expect(model.touched).toBe(false);
      expect(model.untouched).toBe(true);
    });

    describe('validators', () {
      it('should display the valid and invalid CSS classes on the element for each validation',
        (TestBed _, Scope scope) {

        var input = _.compile('<input type="email" ng-model="myModel" />');

        scope.apply(() {
          scope.context['myModel'] = 'value';
        });

        expect(input).toHaveClass('ng-email-invalid');
        expect(input).not.toHaveClass('ng-email-valid');

        scope.apply(() {
          scope.context['myModel'] = 'value@email.com';
        });

        expect(input).toHaveClass('ng-email-valid');
        expect(input).not.toHaveClass('ng-email-invalid');
      });

      it('should display the valid and invalid CSS classes on the element for custom validations',
        (TestBed _, Scope scope) {

        var input = _.compile('<input type="text" ng-model="myModel" custom-input-validation />');

        scope.apply();

        expect(input).toHaveClass('custom-invalid');
        expect(input).not.toHaveClass('custom-valid');

        scope.apply(() {
          scope.context['myModel'] = 'yes';
        });

        expect(input).toHaveClass('custom-valid');
        expect(input).not.toHaveClass('custom-invalid');
      });

      it('should only validate twice during compilation and once upon scope digest',
        (TestBed _, Scope scope) {

        scope.context['required'] = true;
        _.compile('<input type="text" '
                         'ng-model="model" '
                         'ng-required="required" '
                         'ng-pattern="pattern" '
                         'counting-validator>');

        scope.context['pattern'] = '^[aeiou]+\$';
        scope.context['required'] = true;

        scope.apply();

        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);
        var counter = model.validators.firstWhere((validator) => validator.name == 'counting');

        // TODO(#881): There is a bug in ngModel where the validators are validated too often.
        // Should be 2. One for ngModel and one for all the other ones
        // Currently, this count is 2 on Chrome and 3 on Firefox.
        expect(counter.count == 2 || counter.count == 3).toBe(true);
        expect(model.invalid).toBe(true);

        counter.count = 0;
        scope.context['pattern'] = '';
        scope.context['required'] = false;
        scope.apply();

        expect(counter.count).toBe(1);
      });

      it('should only validate twice regardless of attribute order', (TestBed _, Scope scope) {
        scope.context['required'] = true;
        _.compile('<input type="text" '
                         'ng-required="required" '
                         'ng-pattern="pattern" '
                         'counting-validator '
                         'ng-model="model">');

        scope.context['pattern'] = '^[aeiou]+\$';
        scope.context['required'] = true;

        scope.apply();

        var injector = ngInjector('input', _.rootElement);
        var model = injector.get(NgModel);

        var counter = model.validators.firstWhere((validator) => validator.name == 'counting');

        // TODO(#881): There is a bug in ngModel where the validators are validated too often.
        // Should be 2. One for ngModel and one for all the other ones
        // Currently, this count is 3 on Chrome and 1 on Firefox.
        expect(counter.count == 2 || counter.count == 3).toBe(true);
      });
    });

    describe('converters', () {
      it('should parse the model value according to the given parser', (Scope scope) {
        var input = _.compile('<input type="text" ng-model="model">');
        scope.apply();

        var probe = scope.context['i'];
        var injector = ngInjector(input);
        var model = injector.get(NgModel);
        model.converter = new LowercaseValueParser();

        input.value = 'HELLO';
        _.triggerEvent(input, 'change');
        _.rootScope.apply();

        expect(model.viewValue).toEqual('HELLO');
        expect(model.modelValue).toEqual('hello');
      });

      it('should format the model value according to the given formatter', (Scope scope) {
        var input = _.compile('<input type="text" ng-model="model">');
        scope.apply();

        var injector = ngInjector(input);
        var model = injector.get(NgModel);
        model.converter = new UppercaseValueFormatter();

        scope.apply(() {
          scope.context['model'] = 'greetings';
        });

        expect(model.viewValue).toEqual('GREETINGS');
        expect(model.modelValue).toEqual('greetings');
      });

      it('should retain the current input value if the parser fails', (Scope scope) {
        _.compile('<form name="myForm">' +
                  ' <input type="text" ng-model="model1" name="myModel1">' +
                  ' <input type="text" ng-model="model2" name="myModel2">' +
                  '</form>');
        scope.apply();

        var inputs = ngQuery(_.rootElement, 'input');
        var input1 = inputs[0];
        var model1 = ngInjector(input1).get(NgModel);
        var input2 = inputs[1];
        var model2 = ngInjector(input2).get(NgModel);

        model1.converter = new FailedValueParser();

        input1.value = '123';
        _.triggerEvent(input1, 'change');
        _.rootScope.apply();

        expect(model1.viewValue).toEqual('123');
        expect(input1.value).toEqual('123');
        expect(model1.modelValue).toEqual(null);

        expect(model2.viewValue).toEqual(null);
        expect(input2.value).toEqual('');
        expect(model2.modelValue).toEqual(null);
      });

      it('should reformat the viewValue when the formatter is changed', (Scope scope) {
        var input = _.compile('<input type="text" ng-model="model">');
        scope.apply();

        var model = ngInjector(input).get(NgModel);
        model.converter = new LowercaseValueParser();

        input.value = 'HI THERE';
        _.triggerEvent(input, 'change');
        _.rootScope.apply();

        expect(model.viewValue).toEqual('HI THERE');
        expect(model.modelValue).toEqual('hi there');

        model.converter = new VowelValueParser();

        expect(model.viewValue).toEqual('iee');
        expect(model.modelValue).toEqual('hi there');
      });
    });
  });
}

@Controller(
    selector: '[no-love]',
    publishAs: 'ctrl')
class ControllerWithNoLove {
  var apathy = null;
}

class LowercaseValueParser implements NgModelConverter {
  final name = 'lowercase';
  format(value) => value;
  parse(value) {
    return value != null ? value.toLowerCase() : null;
  }
}

class UppercaseValueFormatter implements NgModelConverter {
  final name = 'uppercase';
  parse(value) => value;
  format(value) {
    return value != null ? value.toUpperCase() : null;
  }
}

class FailedValueParser implements NgModelConverter {
  final name = 'failed';
  format(value) => value;
  parse(value) {
    throw new Exception();
  }
}

class VowelValueParser implements NgModelConverter {
  final name = 'vowel';
  parse(value) => value;
  format(value) {
    if(value != null) {
      var exp = new RegExp("[^aeiouAEIOU]");
      value = value.replaceAll(exp, "");
    }
    return value;
  }
}

@Decorator(
    selector: '[custom-input-validation]')
class MyCustomInputValidator extends NgValidator {
  MyCustomInputValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  final String name = 'custom';

  bool isValid(name) {
    return name != null && name == 'yes';
  }
}

@Decorator(
    selector: '[counting-validator]')
class CountingValidator extends NgValidator {

  final String name = 'counting';
  int count = 0;

  CountingValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(String modelValue) {
    count++;
    return true;
  }
}
