import "_specs.dart";
import "_log.dart";
import "dart:mirrors";


class TabComponent {
  static String $visibility = DirectiveVisibility.DIRECT_CHILDREN;
  int id = 0;
  Log log;
  LocalAttrDirective local;
  TabComponent(Log this.log, LocalAttrDirective this.local, Scope scope) {
    log('TabComponent-${id++}');
    local.ping();
  }
}

class PaneComponent {
  TabComponent tabComponent;
  LocalAttrDirective localDirective;
  Log log;
  PaneComponent(TabComponent this.tabComponent, LocalAttrDirective this.localDirective, Log this.log, Scope scope) {
    log('PaneComponent-${tabComponent.id++}');
    localDirective.ping();
  }
}

class LocalAttrDirective {
  static String $visibility = DirectiveVisibility.LOCAL;
  int id = 0;
  Log log;
  LocalAttrDirective(Log this.log);
  ping() {
    log('LocalAttrDirective-${id++}');
  }
}

class SimpleTranscludeInAttachAttrDirective {
  static String $transclude = '.';
  static String $visibility = DirectiveVisibility.CHILDREN;

  Log log;
  BlockList blockList;

  SimpleTranscludeInAttachAttrDirective(BlockList this.blockList, Log this.log, Scope scope) {
    scope.$evalAsync(() {
      var block = blockList.newBlock(scope);
      block.insertAfter(blockList);
      log('SimpleTransclude');
    });
  }
}

class IncludeTranscludeAttrDirective {
  IncludeTranscludeAttrDirective(SimpleTranscludeInAttachAttrDirective simple, Log log) {
    log('IncludeTransclude');
  }
}

main() {

  describe('dte.compiler', () {
    Compiler $compile;
    Injector injector;
    Scope $rootScope;
    DirectiveRegistry directives;

    beforeEach(module((AngularModule module) {
      module
        ..directive(TabComponent)
        ..directive(PaneComponent)
        ..directive(SimpleTranscludeInAttachAttrDirective)
        ..directive(IncludeTranscludeAttrDirective)
        ..directive(LocalAttrDirective);
      return (Injector _injector) {
        injector = _injector;
        $compile = injector.get(Compiler);
        $rootScope = injector.get(Scope);
      };
    }));

    it('should compile basic hello world', inject(() {
      var element = $('<div ng-bind="name"></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';
      template(injector, element);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));

    it('should not throw on an empty list', inject(() {
      $compile([]);
    }));

    it('should compile a directive in a child', inject(() {
      var element = $('<div><div ng-bind="name"></div></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';


      template(injector, element);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));


    it('should compile repeater', inject(() {
      var element = $('<div><div ng-repeat="item in items" ng-bind="item"></div></div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(injector, element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      $rootScope.$digest();
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: ng-repeat=item in items-->');
    }));

    xit('should compile repeater with children', inject((Compiler $compile) {
      var element = $('<div><div ng-repeat="item in items"><div ng-bind="item"></div></div></div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      $rootScope.$digest();
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: ng-repeat=item in items-->');
    }));


    xit('should compile multi-root repeater', inject((Compiler $compile) {
      var element = $(
          '<div>' +
            '<div repeat="item in items" bind="item" include-next></div>' +
            '<span bind="item"></span>' +
          '</div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(element);

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


    xit('should compile text', inject((Compiler $compile) {
      var element = $('<div>{{name}}<span>!</span></div>').contents();
      element.remove();

      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template();

      element = $(block.elements);

      block;

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    xit('should compile nested repeater', inject((Compiler $compile) {
      var element = $(
          '<div>' +
            '<ul repeat="lis in uls">' +
               '<li repeat="li in lis" bind="li"></li>' +
            '</ul>' +
          '</div>');
      var template = $compile(element);

      $rootScope.uls = [['A'], ['b']];
      template(element);

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

        block;

        $rootScope.name = 'a';
        $rootScope.$apply();
        expect(element.text()).toEqual('when');

        $rootScope.name = 'abc';
        $rootScope.$apply();
        expect(element.text()).toEqual('default');
      }));
    });


    xit('should allow multiple transclusions on one element and in correct order.', () {
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
      inject((Compiler $compile) {
        var element = $(
            '<div><b>prefix<span two one three>{{test}}</span>suffix</b></div>');
        var block = $compile(element)(element);

        $rootScope.test = 0;
        block;
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
      it('should interpolate attribute nodes', inject(() {
        var element = $('<div test="{{name}}"></div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(injector, element);

        $rootScope.$digest();
        expect(element.attr('test')).toEqual('angular');
      }));


      it('should interpolate text nodes', inject(() {
        var element = $('<div>{{name}}</div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(injector, element);

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

        block;
        $rootScope.names = ['james;', 'misko;'];
        $rootScope.$apply();

        expect(element.text()).toEqual('james;misko;');
      }));
    });


    describe('components', () {
      beforeEach(module((AngularModule module) {
        module.directive(SimpleComponent);
        module.directive(IoComponent);
        module.directive(PublishMeComponent);
      }));

      it('should create a simple component', inject(() {
        $rootScope.name = 'OUTTER';
        $rootScope.sep = '-';
        var element = $(r'<div>{{name}}{{sep}}{{$id}}:<simple>{{name}}{{sep}}{{$id}}</simple></div>');
        BlockType blockType = $compile(element);
        Block block = blockType(injector, element);
        $rootScope.$digest();

        expect(element.textWithShadow()).toEqual('OUTTER-_1:INNER_2(OUTTER-_1)');
      }));

      it('should create a component with IO', inject(() {
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element)(injector, element);
        $rootScope.name = 'misko';
        $rootScope.$apply();
        var component = $rootScope.ioComponent;
        expect(component.scope.name).toEqual(null);
        expect(component.scope.attr).toEqual('A');
        expect(component.scope.expr).toEqual('misko');
        component.scope.expr = 'angular';
        $rootScope.$apply();
        expect($rootScope.name).toEqual('angular');
        expect($rootScope.done).toEqual(null);
        component.scope.ondone();
        expect($rootScope.done).toEqual(true);
      }));

      it('should throw an exception if required directive is missing', inject((Compiler $compile, Scope $rootScope, Injector injector) {
        expect(() {
          var element = $('<tab local><pane></pane><pane local></pane></tab>');
          $compile(element)(injector, element);
        }, throwsA(contains('No provider found for LocalAttrDirective! (resolving LocalAttrDirective)')));
      }));

      it('should publish component controller into the scope', inject(() {
        var element = $(r'<div><publish-me></publish-me></div>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(element.textWithShadow()).toEqual('WORKED');
      }));
    });

    describe('controller scoping', () {

      it('shoud make controllers available to sibling and child controllers', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
        var element = $('<tab local><pane local></pane><pane local></pane></tab>');
        $compile(element)(injector, element);
        expect(log.result()).toEqual('TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0; PaneComponent-2; LocalAttrDirective-0');
      }));

      it('should reuse controllers for transclusions', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
        var element = $('<div simple-transclude-in-attach include-transclude>block</div>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(log.result()).toEqual('IncludeTransclude; SimpleTransclude');
      }));

    });
  });
}

class SimpleComponent {
  static String $template = r'{{name}}{{sep}}{{$id}}(<content>SHADOW-CONTENT</content>)';
  SimpleComponent(Scope scope) {
    scope.name = 'INNER';
  }
}

class IoComponent {
  static String $template = r'<content></content>';
  static Map $map = {"attr": "@", "expr": "=", "ondone": "&"};
  Scope scope;
  IoComponent(Scope scope) {
    this.scope = scope;
    scope.$root.ioComponent = this;
  }
}

class PublishMeComponent {
  static String $template = r'<content>{{ctrlName.value}}</content>';
  static String $publishAs = 'ctrlName';

  String value = 'WORKED';
  PublishMeComponent() {}
}
