import "_specs.dart";
import "dart:mirrors";

main() {

  describe('dte.compiler', () {
    Compiler $compile;
    Scope $rootScope;
    Directives directives;

    beforeEach(inject((Injector injector) {
      directives = injector.get(Directives);

      directives.register(NgBindAttrDirective);

      $compile = injector.get(Compiler);
      $rootScope = injector.get(Scope);
    }));

    it('should compile basic hello world', inject(() {
      var element = $('<div ng-bind="name"></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';
      template(element).attach($rootScope);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));

    it('should compile a directive in a child', inject(() {
      var element = $('<div><div ng-bind="name"></div></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';


      template(element).attach($rootScope);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));


    xit('should compile repeater', inject(() {
      var element = $('<div><div repeat="item in items" bind="item"></div></div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(element).attach($rootScope);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: repeat=item in items-->');
    }));


    xit('should compile multi-root repeater', inject(() {
      var element = $(
          '<div>' +
            '<div repeat="item in items" bind="item" include-next></div>' +
            '<span bind="item"></span>' +
          '</div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(element).attach($rootScope);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('AAbb');
      expect(element.html()).toEqual(
          '<!--ANCHOR: repeat=item in items-->' +
          '<div repeat="item in items" bind="item" include-next="">A</div><span bind="item">A</span>' +
          '<div repeat="item in items" bind="item" include-next="">b</div><span bind="item">b</span>');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: repeat=item in items-->');
    }));


    xit('should compile text', inject(() {
      var element = $('<div>{{name}}<span>!</span></div>').contents();
      element.remove();

      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template();

      element = $(block.elements);

      block.attach($rootScope);

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    xit('should compile nested repeater', inject(() {
      var element = $(
          '<div>' +
            '<ul repeat="lis in uls">' +
               '<li repeat="li in lis" bind="li"></li>' +
            '</ul>' +
          '</div>');
      var template = $compile(element);

      $rootScope.uls = [['A'], ['b']];
      template(element).attach($rootScope);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');
    }));


    describe('transclusion', () {
      beforeEach(module(($provide) {
        /*
        Switch.$transclude = '>[switch-when],>[switch-default]';
        Switch.$inject=['$anchor', '$value'];
        Switch($anchor, $value) {
          var block;

          attach = (scope) {
            scope.$watch($value, (value) {
              if (block) {
                block.remove();
              }
              var type = 'switch-when=' + value;

              if (!$anchor.blockTypes.hasOwnProperty(type)) {
                type = 'switch-default';
              }
              block = $anchor.newBlock(type);
              LOG(block);
              LOG($anchor);
              block.insertAfter($anchor);
              block.attach(scope.$new());
            });
          }
        };
        */

        $provide.value('directive:[switch]', Switch);
      }));

      xit('should transclude multiple templates', inject(($rootScope) {
        var element = $(
            '<div switch="name">' +
                '<span switch-when="a">when</span>' +
                '<span switch-default>default</span>' +
            '</div>');
        var template = $compile(element);
        var block = template(element);

        block.attach($rootScope);

        $rootScope.name = 'a';
        $rootScope.$apply();
        expect(element.text()).toEqual('when');

        $rootScope.name = 'abc';
        $rootScope.$apply();
        expect(element.text()).toEqual('default');
      }));
    });


    it('should allow multiple transclusions on one element and in correct order.', () {
      module(($provide) {
        /*
        var One = ($anchor) {
          this.attach = (scope) {
            var block = $anchor.newBlock();
            var childScope = scope.$new();

            childScope.test = childScope.test + 1;
            block.insertAfter($anchor);
            block.attach(childScope);
          }
        };
        One.$transclude = '.';
        One.$priority = 100;

        var Two = ($anchor) {
          this.attach = (scope) {
            var block = $anchor.newBlock();
            var childScope = scope.$new();

            childScope.test = childScope.test + 1;
            block.insertAfter($anchor);
            block.attach(childScope);
          }
        };
        Two.$transclude = '.';

        var Three = ($anchor) {
          this.attach = (scope) {
            var block = $anchor.newBlock();
            var childScope = scope.$new();

            childScope.test = childScope.test + 1;
            block.insertAfter($anchor);
            block.attach(childScope);
          }
        };
        Three.$transclude = '.';

        $provide.value({
          'directive:[one]': One,
          'directive:[two]': Two,
          'directive:[three]': Three
        });
        */
      });
      inject(($compile) {
        var element = $(
            '<div><b>prefix<span two one three>{{test}}</span>suffix</b></div>');
        var block = $compile(element)(element);

        $rootScope.test = 0;
        block.attach($rootScope);
        $rootScope.$apply();

        expect(element.length).toEqual(1);
        expect(STRINGIFY(element[0])).toEqual(
          '<div>' +
            '<b>prefix' +
              '<!--ANCHOR: one--><!--ANCHOR: two--><!--ANCHOR: three--><span two="" one="" three="">3</span>' +
            'suffix</b>' +
          '</div>');
      });
    });


    describe("interpolation", () {
      xit('should interpolate attribute nodes', inject(() {
        var element = $('<div test="{{name}}"></div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(element).attach($rootScope);

        $rootScope.$digest();
        expect(element.attr('test')).toEqual('angular');
      }));


      xit('should interpolate text nodes', inject(() {
        var element = $('<div>{{name}}</div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(element).attach($rootScope);

        expect(element.text()).toEqual('');
        $rootScope.$digest();
        expect(element.text()).toEqual('angular');
      }));
    });


    describe('directive generation', () {
      var Bind, Repeat;

      beforeEach(module(($provide) {
        /*
        Generate() {};

        Generate.$generate = (value) {
          expect(value).toEqual('abc');

          return [['[bind]', 'name'], ['[repeat]', 'name in names']];
        };

        */

        $provide.value('directive:[generate]', Generate);
      }));


      xit('should generate directive from a directive', inject(() {
        var element = $('<ul><li generate="abc"></li></ul>');
        var blockType = $compile(element);
        var block = blockType(element);

        block.attach($rootScope);
        $rootScope.names = ['james;', 'misko;'];
        $rootScope.$apply();

        expect(element.text()).toEqual('james;misko;');
      }));
    });


    describe('reuse DOM instances', () {
      xit('should compile with no transclusion', inject(($compile) {
        var element = $('<span bind="name"></span>');
        var spanBT = $compile(element);
        var block = spanBT(element);

        block.attach($rootScope);
        $rootScope.name = 'world';
        $rootScope.$apply();

        expect(element.text()).toEqual('world');
      }));

      xit('should compile with transclusion and no block reuse', inject(() {
        var element = $(
            '<ul>' +
                '<li>-</li>' +
                '<li repeat="i in upper" bind="i">1</li>' +
                '<li>-</li>' +
            '</ul>');
        var ulBlockType = $compile(element);
        var block = ulBlockType(element);

        block.attach($rootScope);
        $rootScope.upper = ['A', 'B'];
        $rootScope.$apply();

        expect(element.text()).toEqual('-AB-');
        expect(element.html()).toEqual(
            '<li>-</li>' +
            '<!--ANCHOR: repeat=i in upper-->' +
            '<li repeat="i in upper" bind="i">A</li>' +
            '<li repeat="i in upper" bind="i">B</li>' +
            '<li>-</li>');
      }));


      xit('should compile and collect template instances', inject(() {
        var element = $(
            '<ul>' +
                '<li>-</li>' +
                '<li repeat="i in upper" instance="1" bind="i">1</li>' +
                '<li instance="2">2</li>' +
                '<li>-</li>' +
            '</ul>');
        var blockCache = [];
        var ulBlockType = $compile(element, blockCache);

        var block = ulBlockType(element, blockCache);

        block.attach($rootScope);
        $rootScope.upper = ['A', 'B'];
        $rootScope.$apply();

        expect(element.text()).toEqual('-AB-');
        expect(element.html()).toEqual(
            '<li>-</li>' +
            '<!--ANCHOR: repeat=i in upper-->' +
            '<li repeat="i in upper" instance="1" bind="i">A</li>' +
            '<li instance="2">B</li>' +
            '<li>-</li>');
      }));

      xit('should compile and collect template instances, and correctly compute offsets', inject(() {
        var element = $(
            '<ul>' +
                '<li>-</li>' +
                '<li repeat="i in upper" instance="1" bind="i">1</li>' +
                '<li instance="2">2</li>' +
                '<li>-</li>' +
                '<li repeat="i in lower" instance="3" bind="i">3</li>' +
                '<li instance="4">4</li>' +
                '<li>-</li>' +
            '</ul>');
        var blockCache = [];
        var ulBlockType = $compile(element, blockCache);
        var block = ulBlockType(element, blockCache);

        block.attach($rootScope);
        $rootScope.upper = ['A', 'B'];
        $rootScope.lower = ['a', 'b'];
        $rootScope.$apply();

        expect(element.text()).toEqual('-AB-ab-');
        expect(element.html()).toEqual(
            '<li>-</li>' +
            '<!--ANCHOR: repeat=i in upper-->' +
            '<li repeat="i in upper" instance="1" bind="i">A</li>' +
            '<li instance="2">B</li>' +
            '<li>-</li>' +
            '<!--ANCHOR: repeat=i in lower-->' +
            '<li repeat="i in lower" instance="3" bind="i">a</li>' +
            '<li instance="4">b</li>' +
            '<li>-</li>');
      }));
    });
  });
}
