library ng_model_validators;

import '../_specs.dart';

main() =>
describe('ngModel validators', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  describe('required', () {
    it('should validate the input field if the required attribute is set', inject((Scope scope) {
      _.compile('<input type="text" ng-model="val" probe="i" required />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.val = 'value';
      model.validate();

      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));


    it('should validate a number input field if the required attribute is set', inject((Scope scope) {
      _.compile('<input type="number" ng-model="val" probe="i" required="true" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.val = 5;
      model.validate();

      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));


    it('should validate the input field depending on if ng-required is true', inject((Scope scope) {
      _.compile('<input type="text" ng-model="val" probe="i" ng-required="requireMe" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      _.rootScope.$apply();

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['requireMe'] = true;
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['requireMe'] = false;
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));
  });

  describe('[type="url"]', () {
    it('should validate the input field given a valid or invalid URL', inject((Scope scope) {
      _.compile('<input type="url" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = 'googledotcom';
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = 'http://www.google.com';
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));
  });

  describe('[type="email"]', () {
    it('should validate the input field given a valid or invalid email address', inject((Scope scope) {
      _.compile('<input type="email" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = 'matiasatemail.com';
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = 'matias@gmail.com';
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));
  });

  describe('[type="number"]', () {
    it('should validate the input field given a valid or invalid number', inject((Scope scope) {
      _.compile('<input type="number" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = '11';
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);


      _.rootScope.$apply(() {
        _.rootScope['val'] = 10;
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = 'twelve';
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);
    }));
  });

  describe('pattern', () {
    it('should validate the input field if a ng-pattern attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" ng-pattern="myPattern" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
        _.rootScope['myPattern'] = "[a-z]+";
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
        _.rootScope['myPattern'] = "[0-9]+";
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "123";
        _.rootScope['myPattern'] = "123";
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));

    it('should validate the input field if a pattern attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" pattern="[0-5]+" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "012345";
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "6789";
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);
    }));
  });

  describe('minlength', () {
    it('should validate the input field if a minlength attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" minlength="5" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abcdef";
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));

    it('should validate the input field if a ng-minlength attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" ng-minlength="len" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abcdef";
        _.rootScope['len'] = 3;
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
        _.rootScope['len'] = 5;
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);
    }));
  });

  describe('maxlength', () {
    it('should validate the input field if a maxlength attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" maxlength="5" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abcdef";
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);
    }));

    it('should validate the input field if a ng-maxlength attribute is provided', inject((Scope scope) {
      _.compile('<input type="text" ng-maxlength="len" ng-model="val" probe="i" />');
      Probe probe = _.rootScope.i;
      var model = probe.directive(NgModel);

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abcdef";
        _.rootScope['len'] = 6;
      });

      model.validate();
      expect(model.valid).toEqual(true);
      expect(model.invalid).toEqual(false);

      _.rootScope.$apply(() {
        _.rootScope['val'] = "abc";
        _.rootScope['len'] = 1;
      });

      model.validate();
      expect(model.valid).toEqual(false);
      expect(model.invalid).toEqual(true);
    }));
  });
});
