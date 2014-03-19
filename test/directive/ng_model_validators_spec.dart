library ng_model_validators;

import '../_specs.dart';

void main() {
  they(should, tokens, callback, [exclusive=false]) {
    tokens.forEach((token) {
      describe(token, () {
        (exclusive ? iit : it)(should, () => callback(token));
      });
    });
  }

  tthey(should, tokens, callback) =>
    they(should, tokens, callback, true);

  describe('ngModel validators', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    describe('required', () {
      it('should validate the input field if the required attribute is set', (RootScope scope) {
        _.compile('<input type="text" ng-model="val" probe="i" required />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'value';
        });

        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });


      it('should validate a number input field if the required attribute is set', (RootScope scope) {
        _.compile('<input type="number" ng-model="val" probe="i" required="true" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        _.rootScope.apply();

        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 5;
        });

        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });


      it('should validate the input field depending on if ng-required is true', (RootScope scope) {
        _.compile('<input type="text" ng-model="val" probe="i" ng-required="requireMe" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        _.rootScope.apply();

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['requireMe'] = true;
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['requireMe'] = false;
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });
    });

    describe('[type="url"]', () {
      it('should validate the input field given a valid or invalid URL', (RootScope scope) {
        _.compile('<input type="url" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'googledotcom';
        });

        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'http://www.google.com';
        });

        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });
    });

    describe('[type="email"]', () {
      it('should validate the input field given a valid or invalid email address', (RootScope scope) {
        _.compile('<input type="email" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'matiasatemail.com';
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'matias@gmail.com';
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });
    });

    describe('[type="number|range"]', () {
      they('should validate the input field given a valid or invalid number',
        ['range', 'number'],
        (type) {

        _.compile('<input type="$type" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = '11';
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);


        _.rootScope.apply(() {
          _.rootScope.context['val'] = 10;
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'twelve';
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
      });

      they('should perform a max number validation if a max attribute value is present',
        ['range', 'number'],
        (type) {

        _.compile('<input type="$type" ng-model="val" max="10" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "8";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-max')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "99";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-max')).toBe(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "a";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-max')).toBe(false);
        expect(model.hasErrorState('ng-number')).toBe(true);
      });

      they('should perform a max number validation if a ng-max attribute value is present and/or changed',
        ['range', 'number'],
        (type) {

        _.compile('<input type="$type" ng-model="val" ng-max="maxVal" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        //should be valid even when no number is present
        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-max')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "20";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-max')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['maxVal'] = "19";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-max')).toBe(true);

        _.rootScope.apply(() {
          _.rootScope.context['maxVal'] = "22";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-max')).toBe(false);
      });

      they('should perform a min number validation if a min attribute value is present',
        ['range', 'number'],
        (type) {

        _.compile('<input type="$type" ng-model="val" min="-10" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "8";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-min')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "-20";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-min')).toBe(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "x";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-min')).toBe(false);
        expect(model.hasErrorState('ng-number')).toBe(true);
      });

      they('should perform a min number validation if a ng-min attribute value is present and/or changed',
        ['range', 'number'],
        (type) {

        _.compile('<input type="$type" ng-model="val" ng-min="minVal" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        //should be valid even when no number is present
        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-min')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "5";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-min')).toBe(false);

        _.rootScope.apply(() {
          _.rootScope.context['minVal'] = "5.5";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
        expect(model.hasErrorState('ng-min')).toBe(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "5.6";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
        expect(model.hasErrorState('ng-min')).toBe(false);
      });
    });

    describe('pattern', () {
      it('should validate the input field if a ng-pattern attribute is provided', (RootScope scope) {
        _.compile('<input type="text" ng-pattern="myPattern" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
          _.rootScope.context['myPattern'] = "[a-z]+";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
          _.rootScope.context['myPattern'] = "[0-9]+";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "123";
          _.rootScope.context['myPattern'] = "123";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });

      it('should validate the input field if a pattern attribute is provided', (RootScope scope) {
        _.compile('<input type="text" pattern="[0-5]+" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "012345";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "6789";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
      });
    });

    describe('minlength', () {
      it('should validate the input field if a minlength attribute is provided', (RootScope scope) {
        _.compile('<input type="text" minlength="5" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abcdef";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });

      it('should validate the input field if a ng-minlength attribute is provided', (RootScope scope) {
        _.compile('<input type="text" ng-minlength="len" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abcdef";
          _.rootScope.context['len'] = 3;
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
          _.rootScope.context['len'] = 5;
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
      });
    });

    describe('maxlength', () {
      it('should validate the input field if a maxlength attribute is provided', (RootScope scope) {
        _.compile('<input type="text" maxlength="5" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abcdef";
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);
      });

      it('should validate the input field if a ng-maxlength attribute is provided', (RootScope scope) {
        _.compile('<input type="text" ng-maxlength="len" ng-model="val" probe="i" />');
        Probe probe = _.rootScope.context['i'];
        var model = probe.directive(NgModel);

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abcdef";
          _.rootScope.context['len'] = 6;
        });

        model.validate();
        expect(model.valid).toEqual(true);
        expect(model.invalid).toEqual(false);

        _.rootScope.apply(() {
          _.rootScope.context['val'] = "abc";
          _.rootScope.context['len'] = 1;
        });

        model.validate();
        expect(model.valid).toEqual(false);
        expect(model.invalid).toEqual(true);
      });
    });

    describe('when toggled it should properly validate', () {
      var build, input, scope, model;
      beforeEach(() {
        scope = _.rootScope;
        build = (attr, type) {
          input = _.compile('<input type="$type" probe="p" ng-model="value" $attr="attr" />');
          model = scope.context['p'].directive(NgModel);
        };
      });

      it('ng-required', () {
        var input = build('ng-required', 'text');
        scope.apply(() {
          scope.context['attr'] = true;
          scope.context['value'] = '';
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = false;
        });

        expect(model.valid).toBe(true);
      });

      it('ng-pattern', () {
        var input = build('ng-pattern', 'text');
        scope.apply(() {
          scope.context['attr'] = '^\d+\$';
          scope.context['value'] = 'abc';
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = null;
        });

        expect(model.valid).toBe(true);
      });

      it('ng-minlength', () {
        var input = build('ng-minlength', 'text');
        scope.apply(() {
          scope.context['attr'] = '10';
          scope.context['value'] = 'abc';
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = null;
        });

        expect(model.valid).toBe(true);
      });

      it('ng-minlength', () {
        var input = build('ng-maxlength', 'text');
        scope.apply(() {
          scope.context['attr'] = '3';
          scope.context['value'] = 'abcd';
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = null;
        });

        expect(model.valid).toBe(true);
      });

      it('ng-min', () {
        var input = build('ng-min', 'number');
        scope.apply(() {
          scope.context['attr'] = '5.0';
          scope.context['value'] = 3;
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = null;
        });

        expect(model.valid).toBe(true);
      });

      it('ng-max', () {
        var input = build('ng-max', 'number');
        scope.apply(() {
          scope.context['attr'] = '5.0';
          scope.context['value'] = 8;
        });

        expect(model.valid).toBe(false);

        scope.apply(() {
          scope.context['attr'] = null;
        });

        expect(model.valid).toBe(true);
      });
    }); 
  });
}
