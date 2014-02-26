library form_spec;

import '../_specs.dart';

main() =>
describe('form', () {
 TestBed _;

  it('should set the name of the form and attach it to the scope', inject((Scope scope, TestBed _) {
    var element = $('<form name="myForm"></form>');

    expect(scope.context['myForm']).toBeNull();

    _.compile(element);
    scope.apply();

    expect(scope.context['myForm']).toBeDefined();

    var form = scope.context['myForm'];
    expect(form.name).toEqual('myForm');
  }));

  describe('pristine / dirty', () {
    it('should be set to pristine by default', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      expect(form.pristine).toEqual(true);
      expect(form.dirty).toEqual(false);
    }));

    it('should add and remove the correct CSS classes when set to dirty and to pristine', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];

      form.dirty = true;
      expect(form.pristine).toEqual(false);
      expect(form.dirty).toEqual(true);
      expect(element.hasClass('ng-pristine')).toBe(false);
      expect(element.hasClass('ng-dirty')).toBe(true);

      form.pristine = true;
      expect(form.pristine).toEqual(true);
      expect(form.dirty).toEqual(false);
      expect(element.hasClass('ng-pristine')).toBe(true);
      expect(element.hasClass('ng-dirty')).toBe(false);
    }));
  });

  describe('valid / invalid', () {
    it('should add and remove the correct flags when set to valid and to invalid', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];

      form.invalid = true;
      expect(form.valid).toEqual(false);
      expect(form.invalid).toEqual(true);
      expect(element.hasClass('ng-valid')).toBe(false);
      expect(element.hasClass('ng-invalid')).toBe(true);

      form.valid = true;
      expect(form.valid).toEqual(true);
      expect(form.invalid).toEqual(false);
      expect(element.hasClass('ng-invalid')).toBe(false);
      expect(element.hasClass('ng-valid')).toBe(true);
    }));

    it('should set the validity with respect to all existing validations when setValidity() is used', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <input type="text" ng-model="one" name="one" />' +
                      '  <input type="text" ng-model="two" name="two" />' +
                      '  <input type="text" ng-model="three" name="three" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      NgModel one = form['one'];
      NgModel two = form['two'];
      NgModel three = form['three'];

      form.updateControlValidity(one, "some error", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      form.updateControlValidity(two, "some error", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      form.updateControlValidity(one, "some error", true);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      form.updateControlValidity(two, "some error", true);
      expect(form.valid).toBe(true);
      expect(form.invalid).toBe(false);
    }));

    it('should not handle the control errorType pair more than once', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <input type="text" ng-model="one" name="one" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      NgModel one = form['one'];

      form.updateControlValidity(one, "validation error", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      form.updateControlValidity(one, "validation error", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      form.updateControlValidity(one, "validation error", true);
      expect(form.valid).toBe(true);
      expect(form.invalid).toBe(false);
    }));

    it('should update the validity of the parent form when the inner model changes', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <input type="text" ng-model="one" name="one" />' +
                      '  <input type="text" ng-model="two" name="two" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      NgModel one = form['one'];
      NgModel two = form['two'];

      one.setValidity("required", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      two.setValidity("required", false);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      one.setValidity("required", true);
      expect(form.valid).toBe(false);
      expect(form.invalid).toBe(true);

      two.setValidity("required", true);
      expect(form.valid).toBe(true);
      expect(form.invalid).toBe(false);
    }));

    it('should set the validity for the parent form when fieldsets are used', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <fieldset probe="f">' +
                      '    <input type="text" ng-model="one" name="one" probe="m" />' +
                      '  </fieldset>' +
                      '</form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      var fieldset = _.rootScope.context['f'].directive(NgForm);
      var model = _.rootScope.context['m'].directive(NgModel);

      model.setValidity("error", false);

      expect(model.valid).toBe(false);
      expect(fieldset.valid).toBe(false);
      expect(form.valid).toBe(false);

      model.setValidity("error", true);

      expect(model.valid).toBe(true);
      expect(fieldset.valid).toBe(true);
      expect(form.valid).toBe(true);

      form.updateControlValidity(fieldset, "error", false);
      expect(model.valid).toBe(true);
      expect(fieldset.valid).toBe(true);
      expect(form.valid).toBe(false);

      fieldset.updateControlValidity(model, "error", false);
      expect(model.valid).toBe(true);
      expect(fieldset.valid).toBe(false);
      expect(form.valid).toBe(false);
    }));
  });

  describe('controls', () {
    it('should add each contained ng-model as a control upon compile', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <input type="text" ng-model="mega_model" name="mega_name" />' +
                      '  <select ng-model="fire_model" name="fire_name">' +
                      '    <option>value</option>' 
                      '  </select>' +
                      '</form>');

      _.compile(element);

      scope.context['mega_model'] = 'mega';
      scope.context['fire_model'] = 'fire';
      scope.apply();

      var form = scope.context['myForm'];
      expect(form['mega_name'].modelValue).toBe('mega');
      expect(form['fire_name'].modelValue).toBe('fire');
    }));

    it('should properly remove controls directly from the ngForm instance', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm">' 
                      '  <input type="text" ng-model="mega_model" name="mega_control" />' +
                      '</form>');

      _.compile(element);
      scope.apply();

      var form = scope.context['myForm'];
      var control = form['mega_control'];
      form.removeControl(control);
      expect(form['mega_control']).toBeNull();
    }));

    it('should remove all controls when the scope is destroyed', inject((Scope scope, TestBed _) {
      Scope childScope = scope.createChild({});
      var element = $('<form name="myForm">' + 
                      '  <input type="text" ng-model="one" name="one" />' +
                      '  <input type="text" ng-model="two" name="two" />' +
                      '  <input type="text" ng-model="three" name="three" />' +
                      '</form>');

      _.compile(element, scope: childScope);
      childScope.apply();

      var form = childScope.context['myForm'];
      expect(form['one']).toBeDefined();
      expect(form['two']).toBeDefined();
      expect(form['three']).toBeDefined();

      childScope.destroy();

      expect(form['one']).toBeNull();
      expect(form['two']).toBeNull();
      expect(form['three']).toBeNull();
    }));
  });

  describe('onSubmit', () {
    it('should suppress the submission event if no action is provided within the form', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.apply();

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

      expect(submissionEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(submissionEvent.defaultPrevented).toBe(true);

      Event fakeEvent = new Event.eventType('CustomEvent', 'running');

      expect(fakeEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(fakeEvent.defaultPrevented).toBe(false);
    }));

    it('should not prevent the submission event if an action is defined', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm" action="..."></form>');

      _.compile(element);
      scope.apply();

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

      expect(submissionEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(submissionEvent.defaultPrevented).toBe(false);
    }));

    it('should execute the ng-submit expression if provided upon form submission', inject((Scope scope, TestBed _) {
      var element = $('<form name="myForm" ng-submit="submitted = true"></form>');

      _.compile(element);
      scope.apply();

      _.rootScope.context['submitted'] = false;

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');
      element[0].dispatchEvent(submissionEvent);

      expect(_.rootScope.context['submitted']).toBe(true);
    }));

    it('should apply the valid and invalid prefixed submit CSS classes to the element', inject((TestBed _) {
      _.compile('<form name="superForm">' + 
                ' <input type="text" ng-model="myModel" probe="i" required />' +
                '</form>');

      NgForm form = _.rootScope.context['superForm'];
      Probe probe = _.rootScope.context['i'];
      var model = probe.directive(NgModel);

      expect(form.submitted).toBe(false);
      expect(form.valid_submit).toBe(false);
      expect(form.invalid_submit).toBe(false);
      expect(form.element.classes.contains('ng-submit-invalid')).toBe(false);
      expect(form.element.classes.contains('ng-submit-valid')).toBe(false);

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

      form.element.dispatchEvent(submissionEvent);
      _.rootScope.apply();

      expect(form.submitted).toBe(true);
      expect(form.valid_submit).toBe(false);
      expect(form.invalid_submit).toBe(true);
      expect(form.element.classes.contains('ng-submit-invalid')).toBe(true);
      expect(form.element.classes.contains('ng-submit-valid')).toBe(false);

      _.rootScope.apply('myModel = "man"');
      form.element.dispatchEvent(submissionEvent);

      expect(form.submitted).toBe(true);
      expect(form.valid_submit).toBe(true);
      expect(form.invalid_submit).toBe(false);
      expect(form.element.classes.contains('ng-submit-invalid')).toBe(false);
      expect(form.element.classes.contains('ng-submit-valid')).toBe(true);
    }));
  });

  describe('reset()', () {
    it('should reset the model value to its original state', inject((TestBed _) {
      _.compile('<form name="superForm">' + 
                ' <input type="text" ng-model="myModel" probe="i" />' +
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
    }));

    it('should set the form control to be untouched when the model is reset or submitted', inject((TestBed _) {
      var form = _.compile('<form name="duperForm">' + 
                           ' <input type="text" ng-model="myModel" probe="i" />' +
                           '</form>');
      var model = _.rootScope.context['i'].directive(NgModel);
      var input = model.element;

      NgForm formModel = _.rootScope.context['duperForm'];

      expect(formModel.touched).toBe(false);
      expect(formModel.untouched).toBe(true);
      expect(form.classes.contains('ng-touched')).toBe(false);
      expect(form.classes.contains('ng-untouched')).toBe(true);

      _.triggerEvent(input, 'blur');

      expect(formModel.touched).toBe(true);
      expect(formModel.untouched).toBe(false);
      expect(form.classes.contains('ng-touched')).toBe(true);
      expect(form.classes.contains('ng-untouched')).toBe(false);

      formModel.reset();

      expect(formModel.touched).toBe(false);
      expect(formModel.untouched).toBe(true);
      expect(form.classes.contains('ng-touched')).toBe(false);
      expect(form.classes.contains('ng-untouched')).toBe(true);

      _.triggerEvent(input, 'blur');

      expect(formModel.touched).toBe(true);

      _.triggerEvent(form, 'submit');

      expect(formModel.touched).toBe(false);
      expect(formModel.untouched).toBe(true);
      expect(form.classes.contains('ng-touched')).toBe(false);
      expect(form.classes.contains('ng-untouched')).toBe(true);
    }));
  });

  describe('regression tests: form', () {
    it('should be resolvable by injector if configured by user.', () {
      module((Module module) {
        module.type(NgForm);
      });

      inject((Injector injector, Compiler compiler, DirectiveMap directives) {
        var element = $('<form></form>');
        compiler(element, directives)(injector, element);
        // The only expectation is that this doesn't throw
      });
    });
  });
});
