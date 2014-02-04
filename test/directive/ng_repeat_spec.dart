library ng_repeat_spec;

import '../_specs.dart';

main() {
  describe('NgRepeater', () {
    var element, $compile, scope, $exceptionHandler, directives;

    beforeEach(inject((Injector injector, Scope $rootScope, Compiler compiler, DirectiveMap _directives) {
      $exceptionHandler = injector.get(ExceptionHandler);
      scope = $rootScope;
      $compile = (html) {
        element = $(html);
        var blockFactory = compiler(element, _directives);
        var block = blockFactory(injector, element);
        return element;
      };
      directives = _directives;
    }));

    it(r'should set create a list of items', inject((Scope scope, Compiler compiler, Injector injector) {
      var element = $('<div><div ng-repeat="item in items">{{item}}</div></div>');
      BlockFactory blockFactory = compiler(element, directives);
      Block block = blockFactory(injector, element);
      scope.context['items'] = ['a', 'b'];
      scope.apply();
      expect(element.text()).toEqual('ab');
    }));


    it(r'should set create a list of items from iterable',
        inject((Scope scope, Compiler compiler, Injector injector) {
      var element = $('<div><div ng-repeat="item in items">{{item}}</div></div>');
      BlockFactory blockFactory = compiler(element, directives);
      Block block = blockFactory(injector, element);
      scope.context['items'] = ['a', 'b'].map((i) => i); // makes an iterable
      scope.apply();
      expect(element.text()).toEqual('ab');
    }));


    it(r'should iterate over an array of objects', () {
      element = $compile(
        '<ul>' +
          '<li ng-repeat="item in items">{{item.name}};</li>' +
        '</ul>');

      // INIT
      scope.context['items'] = [{"name": 'misko'}, {"name":'shyam'}];
      scope.apply();
      expect(element.find('li').length).toEqual(2);
      expect(element.text()).toEqual('misko;shyam;');

      // GROW
      scope.context['items'].add({"name": 'adam'});
      scope.apply();
      expect(element.find('li').length).toEqual(3);
      expect(element.text()).toEqual('misko;shyam;adam;');

      // SHRINK
      scope.context['items'].removeLast();
      scope.context['items'].removeAt(0);
      scope.apply();
      expect(element.find('li').length).toEqual(1);
      expect(element.text()).toEqual('shyam;');
    });


    it(r'should gracefully handle nulls', () {
      element = $compile(
        '<div>' +
          '<ul>' +
            '<li ng-repeat="item in null">{{item.name}};</li>' +
          '</ul>' +
        '</div>');
      scope.apply();
      expect(element.find('ul').length).toEqual(1);
      expect(element.find('li').length).toEqual(0);
    });


    describe('track by', () {
      it(r'should track using expression function', () {
        element = $compile(
            '<ul>' +
                '<li ng-repeat="item in items track by item.id">{{item.name}};</li>' +
            '</ul>');
        scope.context['items'] = [{"id": 'misko'}, {"id": 'igor'}];
        scope.apply();
        var li0 = element.find('li')[0];
        var li1 = element.find('li')[1];

        scope.context['items'].add(scope.context['items'].removeAt(0));
        scope.apply();
        expect(element.find('li')[0]).toBe(li1);
        expect(element.find('li')[1]).toBe(li0);
      });


      it(r'should track using build in $id function', () {
        element = $compile(
            '<ul>' +
                r'<li ng-repeat="item in items track by $id(item)">{{item.name}};</li>' +
            '</ul>');
        scope.context['items'] = [{"name": 'misko'}, {"name": 'igor'}];
        scope.apply();
        var li0 = element.find('li')[0];
        var li1 = element.find('li')[1];

        scope.context['items'].add(scope.context['items'].removeAt(0));
        scope.apply();
        expect(element.find('li')[0]).toBe(li1);
        expect(element.find('li')[1]).toBe(li0);
      });


      it(r'should iterate over an array of primitives', () {
        element = $compile(
            r'<ul>' +
                r'<li ng-repeat="item in items track by $index">{{item}};</li>' +
            r'</ul>');

        // INIT
        scope.context['items'] = [true, true, true];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('true;true;true;');

        scope.context['items'] = [false, true, true];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('false;true;true;');

        scope.context['items'] = [false, true, false];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('false;true;false;');

        scope.context['items'] = [true];
        scope.apply();
        expect(element.find('li').length).toEqual(1);
        expect(element.text()).toEqual('true;');

        scope.context['items'] = [true, true, false];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('true;true;false;');

        scope.context['items'] = [true, false, false];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('true;false;false;');

        // string
        scope.context['items'] = ['a', 'a', 'a'];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('a;a;a;');

        scope.context['items'] = ['ab', 'a', 'a'];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('ab;a;a;');

        scope.context['items'] = ['test'];
        scope.apply();
        expect(element.find('li').length).toEqual(1);
        expect(element.text()).toEqual('test;');

        scope.context['items'] = ['same', 'value'];
        scope.apply();
        expect(element.find('li').length).toEqual(2);
        expect(element.text()).toEqual('same;value;');

        // number
        scope.context['items'] = [12, 12, 12];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('12;12;12;');

        scope.context['items'] = [53, 12, 27];
        scope.apply();
        expect(element.find('li').length).toEqual(3);
        expect(element.text()).toEqual('53;12;27;');

        scope.context['items'] = [89];
        scope.apply();
        expect(element.find('li').length).toEqual(1);
        expect(element.text()).toEqual('89;');

        scope.context['items'] = [89, 23];
        scope.apply();
        expect(element.find('li').length).toEqual(2);
        expect(element.text()).toEqual('89;23;');
      });

    });


    it(r'should error on wrong parsing of ngRepeat', () {
      element = $('<ul><li ng-repeat="i dont parse"></li></ul>');
      expect(() {
        $compile(element);
      }).toThrow("[NgErr7] ngRepeat error! Expected expression in form of '_item_ in _collection_[ track by _id_]' but got 'i dont parse'.");
    });


    it("should throw error when left-hand-side of ngRepeat can't be parsed", () {
        element = $('<ul><li ng-repeat="i dont parse in foo"></li></ul>');
        expect(() {
          $compile(element);
        }).toThrow("[NgErr8] ngRepeat error! '_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got 'i dont parse'.");
    });


    it(r'should expose iterator offset as $index when iterating over arrays',
        () {
      element = $compile(
        '<ul>' +
          '<li ng-repeat="item in items">{{item}}:{{\$index}}|</li>' +
        '</ul>');
      scope.context['items'] = ['misko', 'shyam', 'frodo'];
      scope.apply();
      expect(element.text()).toEqual('misko:0|shyam:1|frodo:2|');
    });


    it(r'should expose iterator position as $first, $middle and $last when iterating over arrays',
        () {
      element = $compile(
        '<ul>' +
          '<li ng-repeat="item in items">{{item}}:{{\$first}}-{{\$middle}}-{{\$last}}|</li>' +
        '</ul>');
      scope.context['items'] = ['misko', 'shyam', 'doug'];
      scope.apply();
      expect(element.text()).
          toEqual('misko:true-false-false|shyam:false-true-false|doug:false-false-true|');

      scope.context['items'].add('frodo');
      scope.apply();
      expect(element.text()).
          toEqual('misko:true-false-false|' +
                  'shyam:false-true-false|' +
                  'doug:false-true-false|' +
                  'frodo:false-false-true|');

      scope.context['items'].removeLast();
      scope.context['items'].removeLast();
      scope.apply();
      expect(element.text()).toEqual('misko:true-false-false|shyam:false-false-true|');

      scope.context['items'].removeLast();
      scope.apply();
      expect(element.text()).toEqual('misko:true-false-true|');
    });

    it(r'should report odd', () {
      element = $compile(
        '<ul>' +
          '<li ng-repeat="item in items">{{item}}:{{\$odd}}-{{\$even}}|</li>' +
        '</ul>');
      scope.context['items'] = ['misko', 'shyam', 'doug'];
      scope.apply();
      expect(element.text()).toEqual('misko:false-true|shyam:true-false|doug:false-true|');

      scope.context['items'].add('frodo');
      scope.apply();
      expect(element.text()).toEqual('misko:false-true|shyam:true-false|doug:false-true|frodo:true-false|');

      scope.context['items'].removeLast();
      scope.context['items'].removeLast();
      scope.apply();
      expect(element.text()).toEqual('misko:false-true|shyam:true-false|');

      scope.context['items'].removeLast();
      scope.apply();
      expect(element.text()).toEqual('misko:false-true|');
    });

    it(r'should repeat over nested arrays', () {
      element = $compile(
        '<ul>' +
          '<li ng-repeat="subgroup in groups">' +
            '<div ng-repeat="group in subgroup">{{group}}|</div>X' +
          '</li>' +
        '</ul>');
      scope.context['groups'] = [['a', 'b'], ['c','d']];
      scope.apply();

      expect(element.text()).toEqual('a|b|Xc|d|X');
    });


    describe('stability', () {
      var a, b, c, d, lis;

      beforeEach(() {
        element = $compile(
          '<ul>' +
            '<li ng-repeat="item in items">{{key}}:{{val}}|></li>' +
          '</ul>');
        a = {};
        b = {};
        c = {};
        d = {};

        scope.context['items'] = [a, b, c];
        scope.apply();
        lis = element.find('li');
      });


      it(r'should preserve the order of elements', () {
        scope.context['items'] = [a, c, d];
        scope.apply();
        var newElements = element.find('li');
        expect(newElements[0]).toEqual(lis[0]);
        expect(newElements[1]).toEqual(lis[2]);
        expect(newElements[2] == lis[1]).toEqual(false);
      });


      it(r'should throw error on adding existing duplicates and recover', () {
        scope.context['items'] = [a, a, a];
        expect(() {
          scope.apply();
        }).toThrow("[NgErr50] ngRepeat error! Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: item in items, Duplicate key: {}");

        // recover
        scope.context['items'] = [a];
        scope.apply();
        var newElements = element.find('li');
        expect(newElements.length).toEqual(1);
        expect(newElements[0]).toEqual(lis[0]);

        scope.context['items'] = [];
        scope.apply();
        newElements = element.find('li');
        expect(newElements.length).toEqual(0);
      });


      it(r'should throw error on new duplicates and recover', () {
        scope.context['items'] = [d, d, d];
        expect(() {
          scope.apply();
        }).toThrow("[NgErr50] ngRepeat error! Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: item in items, Duplicate key: {}");

        // recover
        scope.context['items'] = [a];
        scope.apply();
        var newElements = element.find('li');
        expect(newElements.length).toEqual(1);
        expect(newElements[0]).toEqual(lis[0]);

        scope.context['items'] = [];
        scope.apply();
        newElements = element.find('li');
        expect(newElements.length).toEqual(0);
      });


      it(r'should reverse items when the collection is reversed', () {
        scope.context['items'] = [a, b, c];
        scope.apply();
        lis = element.find('li');

        scope.context['items'] = [c, b, a];
        scope.apply();
        var newElements = element.find('li');
        expect(newElements.length).toEqual(3);
        expect(newElements[0]).toEqual(lis[2]);
        expect(newElements[1]).toEqual(lis[1]);
        expect(newElements[2]).toEqual(lis[0]);
      });


      it(r'should reuse elements even when model is composed of primitives', () {
        // rebuilding repeater from scratch can be expensive, we should try to avoid it even for
        // model that is composed of primitives.

        scope.context['items'] = ['hello', 'cau', 'ahoj'];
        scope.apply();
        lis = element.find('li');
        lis[2].id = 'yes';

        scope.context['items'] = ['ahoj', 'hello', 'cau'];
        scope.apply();
        var newLis = element.find('li');
        expect(newLis.length).toEqual(3);
        expect(newLis[0]).toEqual(lis[2]);
        expect(newLis[1]).toEqual(lis[0]);
        expect(newLis[2]).toEqual(lis[1]);
      });
    });

  });
}
