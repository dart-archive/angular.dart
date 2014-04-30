library form_spec;

import '../_specs.dart';

void main() {
  describe('form', () {
   TestBed _;

    it('should set the name of the form and attach it to the scope', (Scope scope, TestBed _) {
      expect(scope.context['myForm']).toBeNull();

      _.compile('<form name="myForm"></form>');
      scope.apply();

      expect(scope.context['myForm']).toBeDefined();

      var form = scope.context['myForm'];
      expect(form.name).toEqual('myForm');
    });

    it('should return the first control with the given name when accessed using map notation',
      (Scope scope, TestBed _) {
      _.compile('<form name="myForm">'
                '  <input type="text" name="model" ng-model="modelOne" probe="a" />'
                '  <input type="text" name="model" ng-model="modelTwo" probe="b" />'
                '</form>');
      scope.apply();

      NgForm form = _.rootScope.context['myForm'];
      NgModel one = _.rootScope.context['a'].directive(NgModel);
      NgModel two = _.rootScope.context['b'].directive(NgModel);

      expect(one).not.toBe(two);
      expect(form['model']).toBe(one);
      expect(scope.eval("myForm['model']")).toBe(one);
    });

    it('should return the all the controls with the given name', (Scope scope, TestBed _) {
      _.compile('<form name="myForm">'
                '  <input type="text" name="model" ng-model="modelOne" probe="a" />'
                '  <input type="text" name="model" ng-model="modelTwo" probe="b" />'
                '</form>');
      scope.apply();

      NgForm form = _.rootScope.context['myForm'];
      NgModel one = _.rootScope.context['a'].directive(NgModel);
      NgModel two = _.rootScope.context['b'].directive(NgModel);

      expect(one).not.toBe(two);

      var controls = form.controls['model'];
      expect(controls[0]).toBe(one);
      expect(controls[1]).toBe(two);

      expect(scope.eval("myForm.controls['model'][0]")).toBe(one);
      expect(scope.eval("myForm.controls['model'][1]")).toBe(two);
    });


    describe('pristine / dirty', () {
      it('should be set to pristine by default', (Scope scope, TestBed _) {
        _.compile('<form name="myForm"></form>');
        scope.apply();

        var form = scope.context['myForm'];
        expect(form).toBePristine();
      });

      it('should add and remove the correct CSS classes when set to dirty and to pristine', (Scope scope, TestBed _) {
        var element = e('<form name="myForm"><input ng-model="m" probe="m" /></form>');

        _.compile(element);
        scope.apply();

        Probe probe = _.rootScope.context['m'];
        var input = probe.directive(NgModel);
        var form = scope.context['myForm'];

        input.addInfo('ng-dirty');
        input.validate();
        scope.apply();

        expect(form).not.toBePristine();
        expect(element).not.toHaveClass('ng-pristine');
        expect(element).toHaveClass('ng-dirty');

        input.removeInfo('ng-dirty');
        input.validate();
        scope.apply();

        expect(form).toBePristine();
        expect(element).toHaveClass('ng-pristine');
        expect(element).not.toHaveClass('ng-dirty');
      });

      it('should revert back to pristine on the form if the value is reset on the model',
        (Scope scope, TestBed _) {
        _.compile('<form name="myForm">' +
                  '  <input type="text" ng-model="myModel1" probe="m" />' +
                  '  <input type="text" ng-model="myModel2" probe="n" />' +
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        var model1 = scope.context['m'].directive(NgModel);
        var model2 = scope.context['n'].directive(NgModel);

        expect(model1).toBePristine();
        expect(model2).toBePristine();

        var m1value = model1.viewValue;
        var m2value = model2.viewValue;

        model1.viewValue = 'some value';
        expect(model1).not.toBePristine();

        model2.viewValue = 'some value 123';

        model1.viewValue = m1value;
        expect(model1).toBePristine();
        expect(form).not.toBePristine();

        model2.viewValue = m2value;
        expect(model2).toBePristine();
        expect(form).toBePristine();
      });
    });

    describe('valid / invalid', () {
      it('should be valid when empty', (Scope scope, TestBed _) {
        _.compile('<form name="myForm"></form>');
        scope.apply();

        var form = scope.context['myForm'];
        expect(form).toBeValid();
      });

      it('should be valid by default', (Scope scope, TestBed _) {
        _.compile('<form name="myForm"><input type="text" /></form>');
        scope.apply();

        var form = scope.context['myForm'];
        expect(form).toBeValid();
      });

      it('should expose NgForm as NgControl', (Scope scope, TestBed _) {
        _.compile('<form name="myForm" probe="formProbe"><input type="text" /></form>');
        scope.apply();

        expect(scope.context['formProbe'].injector.get(NgControl) is NgForm).toBeTruthy();
      });

      it('should add and remove the correct flags when set to valid and to invalid',
        (Scope scope, TestBed _) {

        var element = e('<form name="myForm"><input ng-model="m" probe="m" /></form>');
        _.compile(element);
        scope.apply();

        Probe probe = _.rootScope.context['m'];
        var model = probe.directive(NgModel);
        var form = scope.context['myForm'];

        model.addError('some-error');
        model.validate();
        scope.apply();

        expect(form).not.toBeValid();

        expect(element).toHaveClass('ng-invalid');
        expect(element).not.toHaveClass('ng-valid');

        model.removeError('some-error');
        model.validate();
        scope.apply();

        expect(form).toBeValid();
        expect(element).not.toHaveClass('ng-invalid');
        //expect(element).toHaveClass('ng-valid');
      });

      it('should set the validity with respect to all existing validations when error states are set is used', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="one" name="one" />'
                  '  <input type="text" ng-model="two" name="two" />'
                  '  <input type="text" ng-model="three" name="three" />'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];
        NgModel three = form['three'];

        one.addError("some error");
        one.validate();
        expect(form).not.toBeValid();

        two.addError("some error");
        two.validate();
        expect(form).not.toBeValid();

        one.removeError("some error");
        one.validate();
        expect(form).not.toBeValid();

        two.removeError("some error");
        two.validate();
        expect(form).toBeValid();
      });

      it('should collect the invalid models upon failed validation', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="one" name="one" />' +
                  '  <input type="text" ng-model="two" name="two" />' +
                  '  <input type="text" ng-model="three" name="three" />' +
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];
        NgModel three = form['three'];

        one.addError("email");
        two.removeError("number");
        three.addError("format");

        expect(form.errorStates.keys.length).toBe(2);
        expect(form.errorStates['email'].elementAt(0)).toBe(one);
        expect(form.errorStates['format'].elementAt(0)).toBe(three);
      });


      it('should not handle the control errorType pair more than once', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="one" name="one" />'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];

        one.addError('validation error');
        one.validate();
        expect(form).not.toBeValid();

        one.addError('validation error');
        one.validate();

        expect(form).not.toBeValid();

        one.removeError('validation error');
        one.validate();
        expect(form).toBeValid();
      });

      it('should update the validity of the parent form when the inner model changes', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="one" name="one" />'
                  '  <input type="text" ng-model="two" name="two" />'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        NgModel one = form['one'];
        NgModel two = form['two'];

        one.addError("required");
        expect(form).not.toBeValid();

        two.addError("required");
        expect(form).not.toBeValid();

        one.removeError("required");
        expect(form).not.toBeValid();

        two.removeError("required");
        expect(form).toBeValid();
      });

      it('should register the name of inner forms that contain the ng-form attribute',
        (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <div ng-form="myInnerForm" probe="f">'
                  '    <input type="text" ng-model="one" name="one" probe="m" />'
                  '  </div>'
                  '</form>');
        scope.apply(() {
          scope.context['one'] = 'it works!';
        });

        var form = scope.context['myForm'];
        var inner = _.rootScope.context['f'].directive(NgForm);

        expect(inner.name).toEqual('myInnerForm');
        expect(scope.eval('myForm["myInnerForm"]["one"].viewValue'))
            .toEqual('it works!');
      });

      it('should set the validity for the parent form when fieldsets are used', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <fieldset probe="f">'
                  '    <input type="text" ng-model="one" name="one" probe="m" />'
                  '  </fieldset>'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        var fieldset = _.rootScope.context['f'].directive(NgForm);
        var model = _.rootScope.context['m'].directive(NgModel);

        model.addError("error");

        expect(model).not.toBeValid();
        expect(fieldset).not.toBeValid();
        expect(form).not.toBeValid();

        model.removeError("error");

        expect(model).toBeValid();
        expect(fieldset).toBeValid();
        expect(form).toBeValid();
      });

      it('should revalidate itself when an inner model is removed', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input ng-model="m" ng-if="on" required />'
                  '</form>');
        scope.context['on'] = true;
        scope.apply();

        var form = scope.context['myForm'];

        expect(form).not.toBeValid();

        scope.context['on'] = false;
        scope.apply();

        expect(form).toBeValid();

        scope.context['on'] = true;
        scope.apply();

        expect(form).not.toBeValid();
      });
    });

    describe('controls', () {
      it('should add each contained ng-model as a control upon compile', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="mega_model" name="mega_name" />'
                  '  <select ng-model="fire_model" name="fire_name">'
                  '    <option>value</option>'
                  '  </select>'
                  '</form>');

        scope.context['mega_model'] = 'mega';
        scope.context['fire_model'] = 'fire';
        scope.apply();

        var form = scope.context['myForm'];
        expect(form['mega_name'].modelValue).toBe('mega');
        expect(form['fire_name'].modelValue).toBe('fire');
      });

      it('should properly remove controls directly from the ngForm instance', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="mega_model" name="mega_control" />' +
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        var control = form['mega_control'];
        form.removeControl(control);
        expect(form['mega_control']).toBeNull();
      });

      it('should remove all controls when the scope is destroyed', (Scope scope, TestBed _) {
        Scope childScope = scope.createChild({});
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="one" name="one" />'
                  '  <input type="text" ng-model="two" name="two" />'
                  '  <input type="text" ng-model="three" name="three" />'
                  '</form>', scope: childScope);
        childScope.apply();

        var form = childScope.context['myForm'];
        expect(form['one']).toBeDefined();
        expect(form['two']).toBeDefined();
        expect(form['three']).toBeDefined();

        childScope.destroy();

        expect(form['one']).toBeNull();
        expect(form['two']).toBeNull();
        expect(form['three']).toBeNull();
      });

      it('should remove from parent when child is removed', (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" name="mega_name" ng-if="mega_visible" ng-model="value"/>'
                  '</form>');

        scope.context['mega_visible'] = true;
        scope.apply();

        var form = scope.context['myForm'];
        expect(form['mega_name']).toBeDefined();

        scope.context['mega_visible'] = false;
        scope.apply();
        expect(form['mega_name']).toBeNull();
      });
    });

    describe('onSubmit', () {
      it('should suppress the submission event if no action is provided within the form', (Scope scope, TestBed _) {
        var element = e('<form name="myForm"></form>');

        _.compile(element);
        scope.apply();

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        expect(submissionEvent.defaultPrevented).toBe(false);
        element.dispatchEvent(submissionEvent);
        expect(submissionEvent.defaultPrevented).toBe(true);

        Event fakeEvent = new Event.eventType('CustomEvent', 'running');

        expect(fakeEvent.defaultPrevented).toBe(false);
        element.dispatchEvent(submissionEvent);
        expect(fakeEvent.defaultPrevented).toBe(false);
      });

      it('should not prevent the submission event if an action is defined', (Scope scope, TestBed _) {
        var element = e('<form name="myForm" action="..."></form>');

        _.compile(element);
        scope.apply();

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        expect(submissionEvent.defaultPrevented).toBe(false);
        element.dispatchEvent(submissionEvent);
        expect(submissionEvent.defaultPrevented).toBe(false);
      });

      it('should execute the ng-submit expression if provided upon form submission', (Scope scope, TestBed _) {
        var element = e('<form name="myForm" ng-submit="submitted = true"></form>');

        _.compile(element);
        scope.apply();

        _.rootScope.context['submitted'] = false;

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');
        element.dispatchEvent(submissionEvent);

        expect(_.rootScope.context['submitted']).toBe(true);
      });

      it('should apply the valid and invalid prefixed submit CSS classes to the element',
          (TestBed _, Scope scope) {

        _.compile('<form name="superForm">'
                  ' <input type="text" ng-model="myModel" probe="i" required />'
                  '</form>');
        scope.apply();

        NgForm form = _.rootScope.context['superForm'];
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);
        var formElement = form.element.node;

        expect(form.submitted).toBe(false);
        expect(form.validSubmit).toBe(false);
        expect(form.invalidSubmit).toBe(false);
        expect(formElement).not.toHaveClass('ng-submit-invalid');
        expect(formElement).not.toHaveClass('ng-submit-valid');

        Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

        formElement.dispatchEvent(submissionEvent);
        scope.apply();

        expect(form.submitted).toBe(true);
        expect(form.validSubmit).toBe(false);
        expect(form.invalidSubmit).toBe(true);
        expect(formElement).toHaveClass('ng-submit-invalid');
        expect(formElement).not.toHaveClass('ng-submit-valid');

        _.rootScope.apply('myModel = "man"');
        formElement.dispatchEvent(submissionEvent);
        scope.apply();

        expect(form.submitted).toBe(true);
        expect(form.validSubmit).toBe(true);
        expect(form.invalidSubmit).toBe(false);
        expect(formElement).not.toHaveClass('ng-submit-invalid');
        expect(formElement).toHaveClass('ng-submit-valid');
      });
    });

    describe('error handling', () {
      it('should return true or false depending on if an error exists on a form',
          (Scope scope, TestBed _) {
        _.compile('<form name="myForm">'
                  '  <input type="text" ng-model="input" name="input" />'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        NgModel input = form['input'];

        expect(form.hasErrorState('big-failure')).toBe(false);

        input.addError('big-failure');
        input.validate();

        expect(form.hasErrorState('big-failure')).toBe(true);

        input.removeError('big-failure');
        input.validate();

        expect(form.hasErrorState('big-failure')).toBe(false);
      });
    });

    describe('validators', () {
      it('should display the valid and invalid CSS classes on the element for each validation',
        (TestBed _, Scope scope) {

        var form = _.compile(
          '<form name="myForm">' +
          ' <input type="text" ng-model="myModel" required />' +
          '</form>'
        );

        scope.apply();

        expect(form).toHaveClass('ng-required-invalid');
        expect(form).not.toHaveClass('ng-required-valid');

        scope.apply(() {
          scope.context['myModel'] = 'value';
        });

        expect(form).toHaveClass('ng-required-valid');
        expect(form).not.toHaveClass('ng-required-invalid');
      });

      it('should re-validate itself when validators are toggled on and off',
        (TestBed _, Scope scope) {

        scope.context['required'] = true;
        _.compile('<form name="myForm">'
                  '<input type="text" ng-model="model" ng-required="required" probe="i" />'
                  '</form>');
        scope.apply();

        var form = scope.context['myForm'];
        var model = scope.context['i'].directive(NgModel);

        expect(form).not.toBeValid();
        expect(model).not.toBeValid();

        scope.context['required'] = false;
        scope.apply();

        expect(form).toBeValid();
        expect(model).toBeValid();
      });


      describe('custom validators', () {
        beforeEachModule((Module module) {
          module.bind(MyCustomFormValidator);
        });

        it('should display the valid and invalid CSS classes on the element for custom validations', (TestBed _, Scope scope) {
          var form = _.compile('<form name="myForm">'
          ' <input type="text" ng-model="myModel" custom-form-validation />'
          '</form>');

          scope.apply();

          expect(form).toHaveClass('custom-invalid');
          expect(form).not.toHaveClass('custom-valid');

          scope.apply(() {
            scope.context['myModel'] = 'yes';
          });

          expect(form).not.toHaveClass('custom-invalid');
          expect(form).toHaveClass('custom-valid');
        });
      });
    });

    describe('reset()', () {
      it('should reset the model value to its original state', (TestBed _) {
        _.compile('<form name="superForm">' +
                  ' <input type="text" ng-model="myModel" probe="i" />'
                  '</form>');
        _.rootScope.apply('myModel = "animal"');

        NgForm form = _.rootScope.context['superForm'];

        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');

        _.rootScope.apply('myModel = "man"');

        expect(_.rootScope.context['myModel']).toEqual('man');
        expect(model.modelValue).toEqual('man');
        expect(model.viewValue).toEqual('man');

        form.reset();
        _.rootScope.apply();

        expect(_.rootScope.context['myModel']).toEqual('animal');
        expect(model.modelValue).toEqual('animal');
        expect(model.viewValue).toEqual('animal');
      });

      // TODO(matias): special-base form_valid
      it('should set the form control to be untouched when the model is reset',
          (TestBed _, Scope scope) {

        var form = _.compile('<form name="duperForm">'
                             ' <input type="text" ng-model="myModel" probe="i" />'
                             '</form>');
        var model = _.rootScope.context['i'].directive(NgModel);
        var input = model.element.node;

        NgForm formModel = _.rootScope.context['duperForm'];
        scope.apply();

        expect(formModel.touched).toBe(false);
        expect(formModel.untouched).toBe(true);
        expect(form).not.toHaveClass('ng-touched');
        expect(form).toHaveClass('ng-untouched');

        _.triggerEvent(input, 'blur');
        scope.apply();

        expect(formModel.touched).toBe(true);
        expect(formModel.untouched).toBe(false);
        expect(form).toHaveClass('ng-touched');
        expect(form).not.toHaveClass('ng-untouched');

        formModel.reset();
        scope.apply();

        expect(formModel.touched).toBe(false);
        expect(formModel.untouched).toBe(true);
        expect(form).not.toHaveClass('ng-touched');
        expect(form).toHaveClass('ng-untouched');

        _.triggerEvent(input, 'blur');

        expect(formModel.touched).toBe(true);
      });

      it('should reset each of the controls to be untouched only when the form has a valid submission', (Scope scope, TestBed _) {
        var form = _.compile('<form name="duperForm">'
                             ' <input type="text" ng-model="myModel" probe="i" required />'
                             '</form>');

        NgForm formModel = _.rootScope.context['duperForm'];
        var model = _.rootScope.context['i'].directive(NgModel);
        var input = model.element.node;
        _.triggerEvent(input, 'blur');

        expect(formModel.touched).toBe(true);
        expect(model.touched).toBe(true);
        expect(formModel.invalid).toBe(true);

        _.triggerEvent(form, 'submit');

        expect(formModel.touched).toBe(true);
        expect(model.touched).toBe(true);
        expect(formModel.invalid).toBe(true);

        scope.apply(() {
          scope.context['myModel'] = 'value';
        });
        _.triggerEvent(form, 'submit');

        expect(formModel).toBeValid();
        expect(model.touched).toBe(false);
      });
    });

    it("should use map notation to fetch controls", (TestBed _) {
        Scope s = _.rootScope;
        s.context['name'] = 'cool';

        var form = _.compile('<form name="myForm">'
                             ' <input type="text" ng-model="someModel" probe="i" name="name" />'
                             '</form>');

        NgForm formModel = s.context['myForm'];
        Probe probe = s.context['i'];
        var model = probe.directive(NgModel);

        expect(s.eval('name')).toEqual('cool');
        expect(s.eval('myForm.name')).toEqual('myForm');
        expect(s.eval('myForm["name"]')).toBe(model);
        expect(s.eval('myForm["name"].name')).toEqual("name");
    });

    describe('regression tests: form', () {
      beforeEachModule((Module module) {
        module.bind(NgForm);
      });

      it('should be resolvable by injector if configured by user.',
           (Injector injector, Compiler compiler, DirectiveMap directives) {
        var element = es('<form></form>');
        expect(() => compiler(element, directives)(injector, element))
            .not.toThrow();
      });
    });
  });
}

@Decorator(
    selector: '[custom-form-validation]')
class MyCustomFormValidator extends NgValidator {
  final String name = 'custom';

  MyCustomFormValidator(NgModel ngModel) {
    ngModel.addValidator(this);
  }

  bool isValid(name) => name != null && name == 'yes';
}
