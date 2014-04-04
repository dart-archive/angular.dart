library ng_class_spec;

import '../_specs.dart';

main() {
  describe('ngClass', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should add new and remove old classes dynamically', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element).toHaveClass('existing');
      expect(element).toHaveClass('A');

      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();
      expect(element).toHaveClass('existing');
      expect(element).not.toHaveClass('A');
      expect(element).toHaveClass('B');

      _.rootScope.context['dynClass'] = null;
      _.rootScope.apply();
      expect(element).toHaveClass('existing');
      expect(element).not.toHaveClass('A');
      expect(element).not.toHaveClass('B');
    });


    it('should support adding multiple classes via an array', () {
      _.rootScope.context['a'] = 'a';
      _.rootScope.context['b'] = '';
      _.rootScope.context['c'] = null;
      var element = _.compile('<div class="existing" ng-class="[\'literalA\', a, b, c]"></div>');
      _.rootScope.apply();
      expect(element).toHaveClass('existing');
      expect(element).toHaveClass('a');
      expect(element).not.toHaveClass('b');
      expect(element).not.toHaveClass('c');
      expect(element).not.toHaveClass('null');
      _.rootScope.context['a']  = null;
      _.rootScope.context['b']  = 'b';
      _.rootScope.context['c']  = 'c';
      _.rootScope.apply();
      expect(element).not.toHaveClass('a');
      expect(element).toHaveClass('b');
      expect(element).toHaveClass('c');
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
          expect(element).toHaveClass('existing');
          expect(element).toHaveClass('A');
          expect(element).not.toHaveClass('B');
          expect(element).toHaveClass('AnotB');

          _.rootScope.context['conditionB'] = () { return true; };
          _.rootScope.apply();
          expect(element).toHaveClass('existing');
          expect(element).toHaveClass('A');
          expect(element).toHaveClass('B');
          expect(element).not.toHaveClass('AnotB');
        });


    it('should remove classes when the referenced object is the same but its property is changed',
        () {
          var element = _.compile('<div ng-class="classes"></div>');
          _.rootScope.context['classes'] = { 'A': true, 'B': true };
          _.rootScope.apply();
          expect(element).toHaveClass('A');
          expect(element).toHaveClass('B');
          _.rootScope.context['classes']['A'] = false;
          _.rootScope.apply();
          expect(element).not.toHaveClass('A');
          expect(element).toHaveClass('B');
        });

    it('should support adding multiple classes via a space delimited string', () {
      var element = _.compile('<div class="existing" ng-class="\'A B\'"></div>');
      _.rootScope.apply();
      expect(element).toHaveClass('existing');
      expect(element).toHaveClass('A');
      expect(element).toHaveClass('B');
    });


    it('should preserve class added post compilation with pre-existing classes', () {
      var element = _.compile('<div class="existing" ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element).toHaveClass('existing');

      // add extra class, change model and eval
      element.classes.add('newClass');
      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();

      expect(element).toHaveClass('existing');
      expect(element).toHaveClass('B');
      expect(element).toHaveClass('newClass');
    });


    it('should preserve class added post compilation without pre-existing classes"', () {
      var element = _.compile('<div ng-class="dynClass"></div>');
      _.rootScope.context['dynClass'] = 'A';
      _.rootScope.apply();
      expect(element).toHaveClass('A');

      // add extra class, change model and eval
      element.classes.add('newClass');
      _.rootScope.context['dynClass'] = 'B';
      _.rootScope.apply();

      expect(element).toHaveClass('B');
      expect(element).toHaveClass('newClass');
    });


    it('should preserve other classes with similar name"', () {
      var element = _.compile('<div class="ui-panel ui-selected" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      _.rootScope.context['dynCls'] = 'foo';
      _.rootScope.apply();
      // TODO(deboer): Abstract ng-binding
      expect(element.className.replaceAll(' ng-binding', '')).toEqual('ui-panel ui-selected foo');
    });


    it('should not add duplicate classes', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      // TODO(deboer): Abstract ng-binding
      expect(element.className.replaceAll(' ng-binding', '')).toEqual('panel bar');
    });


    it('should remove classes even if it was specified via class attribute', () {
      var element = _.compile('<div class="panel bar" ng-class="dynCls"></div>');
      _.rootScope.context['dynCls'] = 'panel';
      _.rootScope.apply();
      _.rootScope.context['dynCls'] = 'window';
      _.rootScope.apply();
      // TODO(deboer): Abstract ng-binding
      expect(element.className.replaceAll(' ng-binding', '')).toEqual('bar window');
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
      expect(e1).toHaveClass('existing');
      expect(e1).toHaveClass('odd');
      expect(e2).toHaveClass('existing');
      expect(e2).toHaveClass('even');
    });


    it('should allow both ngClass and ngClassOdd/Even on the same element', () {
      var element = _.compile('<ul>' +
          '<li ng-repeat="i in [0,1]" ng-class="\'plainClass\'" ' +
          'ng-class-odd="\'odd\'" ng-class-even="\'even\'">{{\$index}}</li>' +
      '<ul>');
      _.rootScope.apply();
      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1).toHaveClass('plainClass');
      expect(e1).toHaveClass('odd');
      expect(e1).not.toHaveClass('even');
      expect(e2).toHaveClass('plainClass');
      expect(e2).toHaveClass('even');
      expect(e2).not.toHaveClass('odd');
    });

    it('should allow both ngClass and ngClassOdd/Even with multiple classes', () {
      var element = _.compile('<ul>' +
        '<li ng-repeat="i in [0,1]" ng-class="[\'A\', \'B\']" ' +
        'ng-class-odd="[\'C\', \'D\']" ng-class-even="[\'E\', \'F\']"></li>' +
        '<ul>');
      _.rootScope.apply();
      var e1 = element.nodes[1];
      var e2 = element.nodes[2];

      expect(e1).toHaveClass('A');
      expect(e1).toHaveClass('B');
      expect(e1).toHaveClass('C');
      expect(e1).toHaveClass('D');
      expect(e1).not.toHaveClass('E');
      expect(e1).not.toHaveClass('F');

      expect(e2).toHaveClass('A');
      expect(e2).toHaveClass('B');
      expect(e2).toHaveClass('E');
      expect(e2).toHaveClass('F');
      expect(e2).not.toHaveClass('C');
      expect(e2).not.toHaveClass('D');
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
      expect(element).not.toHaveClass('two');

      _.rootScope.apply(() {
        _.rootScope.context['cls'] = "to";
      });

      expect(element).toHaveClass('one');
      expect(element).toHaveClass('to'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('four'); // should still be there
      expect(element).not.toHaveClass('two');
      expect(element).not.toHaveClass('too');
    });


    it('should not mess up class value due to observing an interpolated class attribute', () {
      _.rootScope.context['foo'] = true;
      _.rootScope.watch("anything", (_0, _1) {
        _.rootScope.context['foo'] = false;
      });
      var element = _.compile('<div ng-class="{foo:foo}"></div>');
      _.rootScope.apply();
      expect(element).not.toHaveClass('foo');
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

      expect(e1).toHaveClass('odd');
      expect(e1).not.toHaveClass('even');

      expect(e2).toHaveClass('even');
      expect(e2).not.toHaveClass('odd');
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

      expect(e1).toHaveClass('odd');
      expect(e1).not.toHaveClass('even');

      expect(e2).toHaveClass('even');
      expect(e2).not.toHaveClass('odd');
    });
  });
}
