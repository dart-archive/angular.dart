import "_specs.dart";
import "_log.dart";
import "dart:mirrors";


@NgComponent(visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY)
class TabComponent {
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

@NgDirective(visibility: NgDirective.LOCAL_VISIBILITY)
class LocalAttrDirective {
  int id = 0;
  Log log;
  LocalAttrDirective(Log this.log);
  ping() {
    log('LocalAttrDirective-${id++}');
  }
}

@NgDirective(visibility: NgDirective.CHILDREN_VISIBILITY, transclude: '.')
class SimpleTranscludeInAttachAttrDirective {
  SimpleTranscludeInAttachAttrDirective(BlockHole blockHole, BoundBlockFactory boundBlockFactory, Log log, Scope scope) {
    scope.$evalAsync(() {
      var block = boundBlockFactory(scope);
      block.insertAfter(blockHole);
      log('SimpleTransclude');
    });
  }
}

class IncludeTranscludeAttrDirective {
  IncludeTranscludeAttrDirective(SimpleTranscludeInAttachAttrDirective simple, Log log) {
    log('IncludeTransclude');
  }
}

class PublishTypesDirectiveSuperType {
}

@NgDirective(publishTypes: const [PublishTypesDirectiveSuperType])
class PublishTypesAttrDirective implements PublishTypesDirectiveSuperType {
  static Injector _injector;
  PublishTypesAttrDirective(Injector injector) {
    _injector = injector;
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
        ..directive(PublishTypesAttrDirective)
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
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
    }));

    xit('should compile repeater with children', inject((Compiler $compile) {
      var element = $('<div><div [ng-repeat]="item in items"><div ng-bind="item"></div></div></div>');
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
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
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
        var blockFactory = $compile(element);
        var block = blockFactory(element);

        block;
        $rootScope.names = ['james;', 'misko;'];
        $rootScope.$apply();

        expect(element.text()).toEqual('james;misko;');
      }));
    });


    describe('components', () {
      beforeEach(module((AngularModule module) {
        module.directive(SimpleComponent);
        module.directive(CamelCaseMapComponent);
        module.directive(IoComponent);
        module.directive(ParentExpressionComponent);
        module.directive(PublishMeComponent);
        module.directive(LogComponent);
      }));

      it('should create a simple component', async(inject(() {
        $rootScope.name = 'OUTTER';
        $rootScope.sep = '-';
        var element = $(r'<div>{{name}}{{sep}}{{$id}}:<simple>{{name}}{{sep}}{{$id}}</simple></div>');
        BlockFactory blockFactory = $compile(element);
        Block block = blockFactory(injector, element);
        $rootScope.$digest();

        nextTurn();
        expect(element.textWithShadow()).toEqual('OUTTER-_1:INNER_2(OUTTER-_1)');
      })));

      it('should create a component that can access parent scope', async(inject(() {
        $rootScope.fromParent = "should not be used";
        $rootScope.val = "poof";
        var element = $('<parent-expression from-parent=val></parent-expression>');

        $compile(element)(injector, element);

        nextTurn();
        expect(renderedText(element)).toEqual('inside poof');
      })));

      it('should behave nicely if a mapped attribute is missing', async(inject(() {
        var element = $('<parent-expression></parent-expression>');
        $compile(element)(injector, element);

        nextTurn();
        expect(renderedText(element)).toEqual('inside ');
      })));

      it('should behave nicely if a mapped attribute evals to null', async(inject(() {
        $rootScope.val = null;
        var element = $('<parent-expression fromParent=val></parent-expression>');
        $compile(element)(injector, element);

        nextTurn();
        expect(renderedText(element)).toEqual('inside ');
      })));

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

      it('should create a component with IO and "=" binding value should be available', inject(() {
        $rootScope.name = 'misko';
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element)(injector, element);
        var component = $rootScope.ioComponent;
        expect(component.scope.expr).toEqual('misko');
        $rootScope.$apply();
        component.scope.expr = 'angular';
        $rootScope.$apply();
        expect($rootScope.name).toEqual('angular');
      }));

      it('should expose mapped attributes as camel case', inject(() {
        var element = $('<camel-case-map camel-case=6></camel-case-map>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        var componentScope = $rootScope.camelCase;
        expect(componentScope.camelCase).toEqual('6');
      }));

      it('should throw an exception if required directive is missing', inject((Compiler $compile, Scope $rootScope, Injector injector) {
        expect(() {
          var element = $('<tab local><pane></pane><pane local></pane></tab>');
          $compile(element)(injector, element);
        }, throwsA(contains('No provider found for LocalAttrDirective! (resolving LocalAttrDirective)')));
      }));

      it('should publish component controller into the scope', async(inject(() {
        var element = $(r'<div><publish-me></publish-me></div>');
        $compile(element)(injector, element);
        $rootScope.$apply();

        nextTurn();
        expect(element.textWithShadow()).toEqual('WORKED');
      })));

      it('should "publish" controller to injector under provided publishTypes', inject(() {
        var element = $(r'<div publish-types></div>');
        $compile(element)(injector, element);
        expect(PublishTypesAttrDirective._injector.get(PublishTypesAttrDirective)).
            toBe(PublishTypesAttrDirective._injector.get(PublishTypesDirectiveSuperType));
      }));

      it('should allow repeaters over controllers', inject((Logger logger) {
        var element = $(r'<log ng-repeat="i in [1, 2]"></log>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(logger.length).toEqual(2);
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

@NgComponent(
    template: r'{{name}}{{sep}}{{$id}}(<content>SHADOW-CONTENT</content>)'
)
class SimpleComponent {
  SimpleComponent(Scope scope) {
    scope.name = 'INNER';
  }
}

@NgComponent(
    template: r'<content></content>',
    map: const {
      'attr': '@',
      'expr': '=',
      'ondone': '&',
    }
)
class IoComponent {
  Scope scope;
  IoComponent(Scope scope) {
    this.scope = scope;
    scope.$root.ioComponent = this;
  }
}

@NgComponent(
    map: const {
      'camelCase': '@',
    }
)
class CamelCaseMapComponent {
  CamelCaseMapComponent(Scope scope) {
    scope.$root.camelCase = scope;
  }
}

@NgComponent(
    template: '<div>inside {{fromParent()}}</div>',
    map: const {
      'fromParent': '&',
    }
)
class ParentExpressionComponent {
}

@NgComponent(
    template: r'<content>{{ctrlName.value}}</content>',
    publishAs: 'ctrlName'
)
class PublishMeComponent {
  String value = 'WORKED';
}


@NgComponent(
    template: r'<content></content>',
    publishAs: 'ctrlName'
)
class LogComponent {
  LogComponent(Scope scope, Logger logger) {
    logger.add(scope);
  }
}
