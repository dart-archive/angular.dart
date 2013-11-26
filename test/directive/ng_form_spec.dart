library form_spec;

import '../_specs.dart';

main() =>
describe('ng-model', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  it('should set all inner models to dirty', inject((Scope scope) {
    var element = $('<form name="myForm">' +
                    '  <input type="text" name="found" ng-model="model1" />' +
                    '  <input type="text" ng-model="model2" />' +
                    '</form>');

    _.compile(element);
    scope.$apply();

    expect(scope.myForm.pristine).toBe(true);

    scope.myForm.dirty = true;
    expect(scope.myForm.pristine).toBe(false);
    expect(scope.myForm.dirty).toBe(true);
    expect(scope.myForm['found'].dirty).toBe(true);
    expect(scope.myForm['found'].pristine).toBe(false);

    scope.myForm.pristine = true;
    expect(scope.myForm.pristine).toBe(true);
    expect(scope.myForm.dirty).toBe(false);
    expect(scope.myForm['found'].dirty).toBe(false);
    expect(scope.myForm['found'].pristine).toBe(true);
  }));

  it('should update the form accordingly when an input field is updated', inject((Scope scope, TemplateCache cache) {
    var element = $('<form name="myForm">' +
                    '  <input type="text" name="model_name" ng-model="model_inst" />' +
                    '</form>');

    _.compile(element);
    scope.$apply();

    var myForm = scope.myForm;
    var formElement = element[0];

    myForm['model_name'].setValidity("required", false);
    expect(myForm.valid).toBe(false);
    expect(myForm.invalid).toBe(true);
    expect(formElement.classes.contains("ng-invalid-required")).toBe(true);
    expect(formElement.classes.contains("ng-valid-required")).toBe(false);

    myForm['model_name'].setValidity("required", true);
    expect(myForm.valid).toBe(true);
    expect(myForm.invalid).toBe(false);
    expect(formElement.classes.contains("ng-invalid-required")).toBe(false);
    expect(formElement.classes.contains("ng-valid-required")).toBe(true);
  }));
});
