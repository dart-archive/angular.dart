library ng_class_spec;

import 'dart:async';
import 'dart:html' as dom;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('ngClass', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should add new and remove old classes dynamically', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.dynClass = 'A';
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBe(true);
      expect(element.hasClass('A')).toBe(true);

      _.rootScope.dynClass = 'B';
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBe(true);
      expect(element.hasClass('A')).toBe(false);
      expect(element.hasClass('B')).toBe(true);

      _.rootScope.dynClass = null;
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBe(true);
      expect(element.hasClass('A')).toBe(false);
      expect(element.hasClass('B')).toBe(false);
    });


    it('should support adding multiple classes via an array', () {
      var element = _.compile('<div class="existing" ng-class="[\'A\', \'B\']"></div>');
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBeTruthy();
      expect(element.hasClass('A')).toBeTruthy();
      expect(element.hasClass('B')).toBeTruthy();
    });


    it('should support adding multiple classes conditionally via a map of class names to boolean' +
        'expressions', () {
          var element = _.compile(
              '<div class="existing" ' +
              'ng-class="{A: conditionA, B: conditionB(), AnotB: conditionA&&!conditionB()}">' +
          '</div>');
          _.rootScope.conditionA = true;
          _.rootScope.conditionB = () { return false; };
          _.rootScope.$digest();
          expect(element.hasClass('existing')).toBeTruthy();
          expect(element.hasClass('A')).toBeTruthy();
          expect(element.hasClass('B')).toBeFalsy();
          expect(element.hasClass('AnotB')).toBeTruthy();

          _.rootScope.conditionB = () { return true; };
          _.rootScope.$digest();
          expect(element.hasClass('existing')).toBeTruthy();
          expect(element.hasClass('A')).toBeTruthy();
          expect(element.hasClass('B')).toBeTruthy();
          expect(element.hasClass('AnotB')).toBeFalsy();
        });


    it('should remove classes when the referenced object is the same but its property is changed',
        () {
          var element = _.compile('<div ng-class="classes"></div>');
          _.rootScope.classes = { 'A': true, 'B': true };
          _.rootScope.$digest();
          expect(element.hasClass('A')).toBeTruthy();
          expect(element.hasClass('B')).toBeTruthy();
          _.rootScope.classes['A'] = false;
          _.rootScope.$digest();
          expect(element.hasClass('A')).toBeFalsy();
          expect(element.hasClass('B')).toBeTruthy();
        });

    it('should support adding multiple classes via a space delimited string', () {
      var element = _.compile('<div class="existing" ng-class="\'A B\'"></div>');
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBeTruthy();
      expect(element.hasClass('A')).toBeTruthy();
      expect(element.hasClass('B')).toBeTruthy();
    });


    it('should preserve class added post compilation with pre-existing classes', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.dynClass = 'A';
      _.rootScope.$digest();
      expect(element.hasClass('existing')).toBe(true);

      // add extra class, change model and eval
      element.addClass('newClass');
      _.rootScope.dynClass = 'B';
      _.rootScope.$digest();

      expect(element.hasClass('existing')).toBe(true);
      expect(element.hasClass('B')).toBe(true);
      expect(element.hasClass('newClass')).toBe(true);
    });


    it('should preserve class added post compilation without pre-existing classes"', () {
      var element = _.compile('<div ng-class="dynClass"></div>');
      _.rootScope.dynClass = 'A';
      _.rootScope.$digest();
      expect(element.hasClass('A')).toBe(true);

      // add extra class, change model and eval
      element.addClass('newClass');
      _.rootScope.dynClass = 'B';
      _.rootScope.$digest();

      expect(element.hasClass('B')).toBe(true);
      expect(element.hasClass('newClass')).toBe(true);
    });


    it('should preserve other classes with similar name"', () {
      var element = _.compile('<div class="ui-panel ui-selected" ng-class="dynCls"></div>');
      _.rootScope.dynCls = 'panel';
      _.rootScope.$digest();
      _.rootScope.dynCls = 'foo';
      _.rootScope.$digest();
      expect(element[0].className).toEqual('ui-panel ui-selected foo');
    });


    it('should not add duplicate classes', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.dynCls = 'panel';
      _.rootScope.$digest();
      expect(element[0].className).toEqual('panel bar');
    });


    it('should remove classes even if it was specified via class attribute', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.dynCls = 'panel';
      _.rootScope.$digest();
      _.rootScope.dynCls = 'window';
      _.rootScope.$digest();
      expect(element[0].className).toEqual('bar window');
    });


    it('should remove classes even if they were added by another code', () {
      var element = _.compile('<div ng-class="dynCls"></div>');
      _.rootScope.dynCls = 'foo';
      _.rootScope.$digest();
      element.addClass('foo');
      _.rootScope.dynCls = '';
      _.rootScope.$digest();
    });


    it('should ngClass odd/even', () {
      var element = _.compile('<ul><li ng-repeat="i in [0,1]" class="existing" ng-class-odd="\'odd\'" ng-class-even="\'even\'"></li><ul>');
      _.rootScope.$digest();
      var e1 = $(element[0].nodes[1]);
      var e2 = $(element[0].nodes[2]);
      expect(e1.hasClass('existing')).toBeTruthy();
      expect(e1.hasClass('odd')).toBeTruthy();
      expect(e2.hasClass('existing')).toBeTruthy();
      expect(e2.hasClass('even')).toBeTruthy();
    });


    it('should allow both ngClass and ngClassOdd/Even on the same element', () {
      var element = _.compile('<ul>' +
          '<li ng-repeat="i in [0,1]" ng-class="\'plainClass\'" ' +
          'ng-class-odd="\'odd\'" ng-class-even="\'even\'">{{\$index}}</li>' +
      '<ul>');
      _.rootScope.$digest();
      var e1 = $(element[0].nodes[1]);
      var e2 = $(element[0].nodes[2]);

      expect(e1.hasClass('plainClass')).toBeTruthy();
      expect(e1.hasClass('odd')).toBeTruthy();
      expect(e1.hasClass('even')).toBeFalsy();
      expect(e2.hasClass('plainClass')).toBeTruthy();
      expect(e2.hasClass('even')).toBeTruthy();
      expect(e2.hasClass('odd')).toBeFalsy();
    });

    it('should allow both ngClass and ngClassOdd/Even with multiple classes', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in [0,1]" ng-class="[\'A\', \'B\']" ' +
        'ng-class-odd="[\'C\', \'D\']" ng-class-even="[\'E\', \'F\']"></li>' +
        '<ul>');
      _.rootScope.$apply();
      var e1 = $(element[0].nodes[1]);
      var e2 = $(element[0].nodes[2]);

      expect(e1.hasClass('A')).toBeTruthy();
      expect(e1.hasClass('B')).toBeTruthy();
      expect(e1.hasClass('C')).toBeTruthy();
      expect(e1.hasClass('D')).toBeTruthy();
      expect(e1.hasClass('E')).toBeFalsy();
      expect(e1.hasClass('F')).toBeFalsy();

      expect(e2.hasClass('A')).toBeTruthy();
      expect(e2.hasClass('B')).toBeTruthy();
      expect(e2.hasClass('E')).toBeTruthy();
      expect(e2.hasClass('F')).toBeTruthy();
      expect(e2.hasClass('C')).toBeFalsy();
      expect(e2.hasClass('D')).toBeFalsy();
    });


    it('should reapply ngClass when interpolated class attribute changes', () {
      var element = _.compile('<div class="one {{cls}} three" ng-class="{four: four}"></div>');

      _.rootScope.$apply(() {
        _.rootScope.cls = "two";
        _.rootScope.four = true;
      });
      expect(element).toHaveClass('one');
      expect(element).toHaveClass('two'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('four');

      _.rootScope.$apply(() {
        _.rootScope.cls = "too";
      });
      // we have to wait for DOM mutation observer to fire.
      return new Future(() {
        print(element);
        expect(element).toHaveClass('one');
        expect(element).toHaveClass('too'); // interpolated
        expect(element).toHaveClass('three');
        expect(element).toHaveClass('four'); // should still be there
        expect(element.hasClass('two')).toBeFalsy();

        _.rootScope.$apply(() {
          _.rootScope.cls = "to";
        });
        return new Future(() {
          expect(element).toHaveClass('one');
          expect(element).toHaveClass('to'); // interpolated
          expect(element).toHaveClass('three');
          expect(element).toHaveClass('four'); // should still be there
          expect(element.hasClass('two')).toBeFalsy();
          expect(element.hasClass('too')).toBeFalsy();
        });
      });
    });


    it('should not mess up class value due to observing an interpolated class attribute', () {
      _.rootScope.foo = true;
      _.rootScope.$watch("anything", () {
        _.rootScope.foo = false;
      });
      var element = _.compile('<div ng-class="{foo:foo}"></div>');
      _.rootScope.$digest();
      expect(element.hasClass('foo')).toBe(false);
    });


    it('should update ngClassOdd/Even when model is changed by filtering', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in items" ' +
        'ng-class-odd="\'odd\'" ng-class-even="\'even\'"></li>' +
        '<ul>');
      _.rootScope.items = ['a','b','c'];
      _.rootScope.$digest();

      _.rootScope.items = ['a','b'];
      _.rootScope.$digest();

      var e1 = $(element[0].nodes[1]);
      var e2 = $(element[0].nodes[2]);

      expect(e1.hasClass('odd')).toBeTruthy();
      expect(e1.hasClass('even')).toBeFalsy();

      expect(e2.hasClass('even')).toBeTruthy();
      expect(e2.hasClass('odd')).toBeFalsy();
    });


    it('should update ngClassOdd/Even when model is changed by sorting', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in items" ' +
        'ng-class-odd="\'odd\'" ng-class-even="\'even\'">i</li>' +
        '<ul>');
      _.rootScope.items = ['a','b'];
      _.rootScope.$digest();

      _.rootScope.items = ['b','a'];
      _.rootScope.$digest();

      var e1 = $(element[0].nodes[1]);
      var e2 = $(element[0].nodes[2]);

      expect(e1.hasClass('odd')).toBeTruthy();
      expect(e1.hasClass('even')).toBeFalsy();

      expect(e2.hasClass('even')).toBeTruthy();
      expect(e2.hasClass('odd')).toBeFalsy();
    });
  });
}
