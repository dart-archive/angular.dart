library ng_class_spec;

import '../_specs.dart';

main() {
  describe('ngClass', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should add new and remove old classes dynamically', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBe(true);
      expect(element.classes.contains('A')).toBe(true);

      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBe(true);
      expect(element.classes.contains('A')).toBe(false);
      expect(element.classes.contains('B')).toBe(true);

      _.rootScope.context['dynClass'] = null;
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBe(true);
      expect(element.classes.contains('A')).toBe(false);
      expect(element.classes.contains('B')).toBe(false);
    });


    it('should support adding multiple classes via an array', () {
      _.rootScope.context['a'] = 'a';
      _.rootScope.context['b'] = '';
      _.rootScope.context['c'] = null;
      var element = _.compile('<div class="existing" ng-class="[\'literalA\', a, b, c]"></div>');
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBeTruthy();
      expect(element.classes.contains('a')).toBeTruthy();
      expect(element.classes.contains('b')).toBeFalsy();
      expect(element.classes.contains('c')).toBeFalsy();
      expect(element.classes.contains('null')).toBeFalsy();
      _.rootScope.context['a']  = null;
      _.rootScope.context['b']  = 'b';
      _.rootScope.context['c']  = 'c';
      _.rootScope.apply();
      expect(element.classes.contains('a')).toBeFalsy();
      expect(element.classes.contains('b')).toBeTruthy();
      expect(element.classes.contains('c')).toBeTruthy();
    });


    it('should support adding multiple classes conditionally via a map of class names to boolean' +
        'expressions', () {
          var element = _.compile(
              '<div class="existing" ' +
              'ng-class="{A: conditionA, B: conditionB(), AnotB: conditionA&&!conditionB()}">' +
          '</div>');
          _.rootScope.context['conditionA'] = true;
          _.rootScope.context['conditionB'] = () { return false; };
          _.rootScope.apply();
          expect(element.classes.contains('existing')).toBeTruthy();
          expect(element.classes.contains('A')).toBeTruthy();
          expect(element.classes.contains('B')).toBeFalsy();
          expect(element.classes.contains('AnotB')).toBeTruthy();

          _.rootScope.context['conditionB'] = () { return true; };
          _.rootScope.apply();
          expect(element.classes.contains('existing')).toBeTruthy();
          expect(element.classes.contains('A')).toBeTruthy();
          expect(element.classes.contains('B')).toBeTruthy();
          expect(element.classes.contains('AnotB')).toBeFalsy();
        });


    it('should remove classes when the referenced object is the same but its property is changed',
        () {
          var element = _.compile('<div ng-class="classes"></div>');
          _.rootScope.context['classes'] = { 'A': true, 'B': true };
          _.rootScope.apply();
          expect(element.classes.contains('A')).toBeTruthy();
          expect(element.classes.contains('B')).toBeTruthy();
          _.rootScope.context['classes']['A'] = false;
          _.rootScope.apply();
          expect(element.classes.contains('A')).toBeFalsy();
          expect(element.classes.contains('B')).toBeTruthy();
        });

    it('should support adding multiple classes via a space delimited string', () {
      var element = _.compile('<div class="existing" ng-class="\'A B\'"></div>');
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBeTruthy();
      expect(element.classes.contains('A')).toBeTruthy();
      expect(element.classes.contains('B')).toBeTruthy();
    });


    it('should preserve class added post compilation with pre-existing classes', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element.classes.contains('existing')).toBe(true);

      // add extra class, change model and eval
      element.classes.add('newClass');
      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();

      expect(element.classes.contains('existing')).toBe(true);
      expect(element.classes.contains('B')).toBe(true);
      expect(element.classes.contains('newClass')).toBe(true);
    });


    it('should preserve class added post compilation without pre-existing classes"', () {
      var element = _.compile('<div ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element.classes.contains('A')).toBe(true);

      // add extra class, change model and eval
      element.classes.add('newClass');
      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();

      expect(element.classes.contains('B')).toBe(true);
      expect(element.classes.contains('newClass')).toBe(true);
    });


    it('should preserve other classes with similar name"', () {
      var element = _.compile('<div class="ui-panel ui-selected" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      _.rootScope.context['dynCls'] = 'foo';
      _.rootScope.apply();
      expect(element.className).toEqual('ui-panel ui-selected foo');
    });


    it('should not add duplicate classes', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      expect(element.className).toEqual('panel bar');
    });


    it('should remove classes even if it was specified via class attribute', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      _.rootScope.context['dynCls'] = 'window';
      _.rootScope.apply();
      expect(element.className).toEqual('bar window');
    });


    it('should remove classes even if they were added by another code', () {
      var element = _.compile('<div ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'foo';
      _.rootScope.apply();
      element.classes.add('foo');
      _.rootScope.context['dynCls'] = '';
      _.rootScope.apply();
    });


    it('should ngClass odd/even', () {
      var element = _.compile('<ul><li ng-repeat="i in [0,1]" class="existing" ng-class-odd="\'odd\'" ng-class-even="\'even\'"></li><ul>');
      _.rootScope.apply();
      var e1 = element.nodes[1];
      var e2 = element.nodes[2];
      expect(e1.classes.contains('existing')).toBeTruthy();
      expect(e1.classes.contains('odd')).toBeTruthy();
      expect(e2.classes.contains('existing')).toBeTruthy();
      expect(e2.classes.contains('even')).toBeTruthy();
    });


    it('should allow both ngClass and ngClassOdd/Even on the same element', () {
      var element = _.compile('<ul>' +
          '<li ng-repeat="i in [0,1]" ng-class="\'plainClass\'" ' +
          'ng-class-odd="\'odd\'" ng-class-even="\'even\'">{{\$index}}</li>' +
      '<ul>');
      _.rootScope.apply();
      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1.classes.contains('plainClass')).toBeTruthy();
      expect(e1.classes.contains('odd')).toBeTruthy();
      expect(e1.classes.contains('even')).toBeFalsy();
      expect(e2.classes.contains('plainClass')).toBeTruthy();
      expect(e2.classes.contains('even')).toBeTruthy();
      expect(e2.classes.contains('odd')).toBeFalsy();
    });

    it('should allow both ngClass and ngClassOdd/Even with multiple classes', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in [0,1]" ng-class="[\'A\', \'B\']" ' +
        'ng-class-odd="[\'C\', \'D\']" ng-class-even="[\'E\', \'F\']"></li>' +
        '<ul>');
      _.rootScope.apply();
      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1.classes.contains('A')).toBeTruthy();
      expect(e1.classes.contains('B')).toBeTruthy();
      expect(e1.classes.contains('C')).toBeTruthy();
      expect(e1.classes.contains('D')).toBeTruthy();
      expect(e1.classes.contains('E')).toBeFalsy();
      expect(e1.classes.contains('F')).toBeFalsy();

      expect(e2.classes.contains('A')).toBeTruthy();
      expect(e2.classes.contains('B')).toBeTruthy();
      expect(e2.classes.contains('E')).toBeTruthy();
      expect(e2.classes.contains('F')).toBeTruthy();
      expect(e2.classes.contains('C')).toBeFalsy();
      expect(e2.classes.contains('D')).toBeFalsy();
    });


    it('should reapply ngClass when interpolated class attribute changes', () {
      var element = _.compile('<div class="one {{cls}} three" ng-class="{four: four}"></div>');

      _.rootScope.apply(() {
        _.rootScope.context['cls'] = "two";
        _.rootScope.context['four'] = true;
      });
      expect(element).toHaveClass('one');
      expect(element).toHaveClass('two'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('four');

      _.rootScope.apply(() {
        _.rootScope.context['cls'] = "too";
      });

      expect(element).toHaveClass('one');
      expect(element).toHaveClass('too'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('four'); // should still be there
      expect(element.classes.contains('two')).toBeFalsy();

      _.rootScope.apply(() {
        _.rootScope.context['cls'] = "to";
      });

      expect(element).toHaveClass('one');
      expect(element).toHaveClass('to'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('four'); // should still be there
      expect(element.classes.contains('two')).toBeFalsy();
      expect(element.classes.contains('too')).toBeFalsy();
    });


    it('should not mess up class value due to observing an interpolated class attribute', () {
      _.rootScope.context['foo'] = true;
      _.rootScope.watch("anything", (_0, _1) {
        _.rootScope.context['foo'] = false;
      });
      var element = _.compile('<div ng-class="{foo:foo}"></div>');
      _.rootScope.apply();
      expect(element.classes.contains('foo')).toBe(false);
    });


    it('should update ngClassOdd/Even when model is changed by filtering', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in items" ' +
        'ng-class-odd="\'odd\'" ng-class-even="\'even\'"></li>' +
        '<ul>');
      _.rootScope.context['items'] = ['a','b','c'];
      _.rootScope.apply();

      _.rootScope.context['items'] = ['a','b'];
      _.rootScope.apply();

      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1.classes.contains('odd')).toBeTruthy();
      expect(e1.classes.contains('even')).toBeFalsy();

      expect(e2.classes.contains('even')).toBeTruthy();
      expect(e2.classes.contains('odd')).toBeFalsy();
    });


    it('should update ngClassOdd/Even when model is changed by sorting', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in items" ' +
        'ng-class-odd="\'odd\'" ng-class-even="\'even\'">i</li>' +
        '<ul>');
      _.rootScope.context['items'] = ['a','b'];
      _.rootScope.apply();

      _.rootScope.context['items'] = ['b','a'];
      _.rootScope.apply();

      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1.classes.contains('odd')).toBeTruthy();
      expect(e1.classes.contains('even')).toBeFalsy();

      expect(e2.classes.contains('even')).toBeTruthy();
      expect(e2.classes.contains('odd')).toBeFalsy();
    });
  });
}
