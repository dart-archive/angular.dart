library compiler_spec;

import '../_specs.dart';


main() => describe('dte.compiler', () {
    Compiler $compile;
    DirectiveMap directives;
    Injector injector;
    Scope rootScope;

    beforeEach(module((Module module) {
      module
        ..type(TabComponent)
        ..type(PublishTypesAttrDirective)
        ..type(PaneComponent)
        ..type(SimpleTranscludeInAttachAttrDirective)
        ..type(IncludeTranscludeAttrDirective)
        ..type(LocalAttrDirective)
        ..type(OneOfTwoDirectives)
        ..type(TwoOfTwoDirectives)
        ..type(MyController)
        ..type(MyParentController)
        ..type(MyChildController);
      return (Injector _injector) {
        injector = _injector;
        $compile = injector.get(Compiler);
        directives = injector.get(DirectiveMap);
        rootScope = injector.get(Scope);
      };
    }));

    it('should compile basic hello world', inject(() {
      var element = $('<div ng-bind="name"></div>');
      var template = $compile(element, directives);

      rootScope.context['name'] = 'angular';
      template(injector, element);

      expect(element.text()).toEqual('');
      rootScope.apply();
      expect(element.text()).toEqual('angular');
    }));

    it('should not throw on an empty list', inject(() {
      $compile([], directives);
    }));

    it('should compile a directive in a child', inject(() {
      var element = $('<div><div ng-bind="name"></div></div>');
      var template = $compile(element, directives);

      rootScope.context['name'] = 'angular';


      template(injector, element);

      expect(element.text()).toEqual('');
      rootScope.apply();
      expect(element.text()).toEqual('angular');
    }));

    it('should compile repeater', inject(() {
      var element = $('<div><div ng-repeat="item in items" ng-bind="item"></div></div>');
      var template = $compile(element, directives);

      rootScope.context['items'] = ['A', 'b'];
      template(injector, element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      rootScope.apply();
      rootScope.apply();
      expect(element.text()).toEqual('Ab');

      rootScope.context['items'] = [];
      rootScope.apply();
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
    }));

    it('should compile repeater with children', inject((Compiler $compile) {
      var element = $('<div><div ng-repeat="item in items"><div ng-bind="item"></div></div></div>');
      var template = $compile(element, directives);

      rootScope.context['items'] = ['A', 'b'];
      template(injector, element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      rootScope.apply();
      rootScope.apply();
      expect(element.text()).toEqual('Ab');

      rootScope.context['items'] = [];
      rootScope.apply();
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
    }));

    it('should compile text', inject((Compiler $compile) {
      var element = $('<div>{{name}}<span>!</span></div>').contents();
      element.remove(null);

      var template = $compile(element, directives);

      rootScope.context['name'] = 'OK';
      var block = template(injector, element);

      element = $(block.elements);

      rootScope.apply();
      expect(element.text()).toEqual('OK!');
    }));

    it('should compile nested repeater', inject((Compiler $compile) {
      var element = $(
          '<div>' +
            '<ul ng-repeat="lis in uls">' +
               '<li ng-repeat="li in lis">{{li}}</li>' +
            '</ul>' +
          '</div>');
      var template = $compile(element, directives);

      rootScope.context['uls'] = [['A'], ['b']];
      template(injector, element);

      rootScope.apply();
      expect(element.text()).toEqual('Ab');
    }));

    it('should compile two directives with the same selector', inject((Logger log) {
      var element = $('<div two-directives></div>');
      var template = $compile(element, directives);

      template(injector, element);
      rootScope.apply();

      expect(log).toEqual(['OneOfTwo', 'TwoOfTwo']);
    }));



    describe("interpolation", () {
      it('should interpolate attribute nodes', inject(() {
        var element = $('<div test="{{name}}"></div>');
        var template = $compile(element, directives);

        rootScope.context['name'] = 'angular';
        template(injector, element);

        rootScope.apply();
        expect(element.attr('test')).toEqual('angular');
      }));

      it('should interpolate text nodes', inject(() {
        var element = $('<div>{{name}}</div>');
        var template = $compile(element, directives);

        rootScope.context['name'] = 'angular';
        template(injector, element);

        rootScope.apply();
        expect(element.text()).toEqual('angular');
      }));
    });


    describe('components', () {
      beforeEach(module((Module module) {
        module.type(SimpleComponent);
        module.type(CamelCaseMapComponent);
        module.type(IoComponent);
        module.type(IoControllerComponent);
        module.type(UnpublishedIoControllerComponent);
        module.type(IncorrectMappingComponent);
        module.type(NonAssignableMappingComponent);
        module.type(ParentExpressionComponent);
        module.type(PublishMeComponent);
        module.type(PublishMeDirective);
        module.type(LogComponent);
        module.type(AttachDetachComponent);
        module.type(SimpleAttachComponent);
        module.type(SimpleComponent);
        module.type(ExprAttrComponent);
        module.type(SayHelloFilter);
      }));

      it('should select on element', async(inject((NgZone zone) {
        var element = $(r'<div><simple></simple></div>');

        zone.run(() {
          BlockFactory blockFactory = $compile(element, directives);
          Block block = blockFactory(injector, element);
        });

        microLeap();
        expect(element.textWithShadow()).toEqual('INNER()');
      })));

      it('should create a simple component', async(inject((NgZone zone) {
        rootScope.context['name'] = 'OUTTER';
        var element = $(r'<div>{{name}}:<simple>{{name}}</simple></div>');

        zone.run(() {
          BlockFactory blockFactory = $compile(element, directives);
          Block block = blockFactory(injector, element);
        });

        microLeap();
        expect(element.textWithShadow()).toEqual('OUTTER:INNER(OUTTER)');
      })));

      it('should create a component that can access parent scope', async(inject((NgZone zone) {
        rootScope.context['fromParent'] = "should not be used";
        rootScope.context['val'] = "poof";
        var element = $('<parent-expression from-parent=val></parent-expression>');

        zone.run(() =>
          $compile(element, directives)(injector, element));

        microLeap();
        expect(renderedText(element)).toEqual('inside poof');
      })));

      it('should behave nicely if a mapped attribute is missing', async(inject((NgZone zone) {
        var element = $('<parent-expression></parent-expression>');
        zone.run(() =>
          $compile(element, directives)(injector, element));

        microLeap();
        expect(renderedText(element)).toEqual('inside ');
      })));

      it('should behave nicely if a mapped attribute evals to null', async(inject((NgZone zone) {
        rootScope.context['val'] = null;
        var element = $('<parent-expression fromParent=val></parent-expression>');
        zone.run(() =>
          $compile(element, directives)(injector, element));

        microLeap();
        expect(renderedText(element)).toEqual('inside ');
      })));

      it('should create a component with I/O', async(inject(() {
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element, directives)(injector, element);
        microLeap();

        rootScope.context['name'] = 'misko';
        rootScope.apply();
        var component = rootScope.context['ioComponent'];
        expect(component.scope.context['name']).toEqual(null);
        expect(component.scope.context['attr']).toEqual('A');
        expect(component.scope.context['expr']).toEqual('misko');
        component.scope.context['expr'] = 'angular';
        rootScope.apply();
        expect(rootScope.context['name']).toEqual('angular');
        expect(rootScope.context['done']).toEqual(null);
        component.scope.context['ondone']();
        expect(rootScope.context['done']).toEqual(true);
      })));

      xit('should should not create any watchers if no attributes are specified', async(inject((Profiler perf) {
        var element = $(r'<div><io></io></div>');
        $compile(element, directives)(injector, element);
        microLeap();
        injector.get(Scope).apply();
        // Re-enable once we can publish these numbers
        //expect(rootScope.watchGroup.totalFieldCost).toEqual(0);
        //expect(rootScope.watchGroup.totalCollectionCost).toEqual(0);
        //expect(rootScope.watchGroup.totalEvalCost).toEqual(0);
        //expect(rootScope.observeGroup.totalFieldCost).toEqual(0);
        //expect(rootScope.observeGroup.totalCollectionCost).toEqual(0);
        //expect(rootScope.observeGroup.totalEvalCost).toEqual(0);
      })));

      it('should create a component with I/O and "=" binding value should be available', async(inject(() {
        rootScope.context['name'] = 'misko';
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element, directives)(injector, element);
        microLeap();

        var component = rootScope.context['ioComponent'];
        rootScope.apply();
        expect(component.scope.context['expr']).toEqual('misko');
        component.scope.context['expr'] = 'angular';
        rootScope.apply();
        expect(rootScope.context['name']).toEqual('angular');
      })));

      it('should create a component with I/O bound to controller and "=" binding value should be available', async(inject(() {
        rootScope.context['done'] = false;
        var element = $(r'<div><io-controller attr="A" expr="name" once="name" ondone="done=true"></io-controller></div>');


        expect(injector).toBeDefined();
        $compile(element, directives)(injector, element);
        microLeap();

        IoControllerComponent component = rootScope.context['ioComponent'];

        expect(component.expr).toEqual(null);
        expect(component.exprOnce).toEqual(null);
        expect(component.attr).toEqual('A');
        rootScope.apply();

        rootScope.context['name'] = 'misko';
        rootScope.apply();
        expect(component.expr).toEqual('misko');
        expect(component.exprOnce).toEqual('misko');

        rootScope.context['name'] = 'igor';
        rootScope.apply();
        expect(component.expr).toEqual('igor');
        expect(component.exprOnce).toEqual('misko');

        component.expr = 'angular';
        rootScope.apply();
        expect(rootScope.context['name']).toEqual('angular');

        expect(rootScope.context['done']).toEqual(false);
        component.onDone();
        expect(rootScope.context['done']).toEqual(true);

        // Should be noop
        component.onOptional();
      })));

      it('should create a map attribute to controller', async(inject(() {
        var element = $(r'<div><io-controller attr="{{name}}"></io-controller></div>');
        $compile(element, directives)(injector, element);
        microLeap();

        IoControllerComponent component = rootScope.context['ioComponent'];

        rootScope.context['name'] = 'misko';
        rootScope.apply();
        expect(component.attr).toEqual('misko');

        rootScope.context['name'] = 'james';
        rootScope.apply();
        expect(component.attr).toEqual('james');
      })));

      it('should create a unpublished component with I/O bound to controller and "=" binding value should be available', async(inject(() {
        rootScope.context['name'] = 'misko';
        rootScope.context['done'] = false;
        var element = $(r'<div><unpublished-io-controller attr="A" expr="name" ondone="done=true"></unpublished-io-controller></div>');
        $compile(element, directives)(injector, element);
        microLeap();

        UnpublishedIoControllerComponent component = rootScope.context['ioComponent'];
        rootScope.apply();
        expect(component.attr).toEqual('A');
        expect(component.expr).toEqual('misko');
        component.expr = 'angular';
        rootScope.apply();
        expect(rootScope.context['name']).toEqual('angular');

        expect(rootScope.context['done']).toEqual(false);
        component.onDone();
        expect(rootScope.context['done']).toEqual(true);

        // Should be noop
        component.onOptional();
      })));

      it('should error on incorrect mapping', async(inject(() {
        expect(() {
          var element = $(r'<div><incorrect-mapping></incorrect-mapping</div>');
          $compile(element, directives)(injector, element);
        }).toThrow("Unknown mapping 'foo\' for attribute 'attr'.");
      })));

      it('should support filters in attribute expressions', async(inject(() {
        var element = $(r'''<expr-attr-component expr="'Misko' | hello" one-way="'James' | hello" once="'Chirayu' | hello"></expr-attr-component>''');
        $compile(element, directives)(injector, element);
        ExprAttrComponent component = rootScope.context['exprAttrComponent'];
        rootScope.apply();
        expect(component.expr).toEqual('Hello, Misko!');
        expect(component.oneWay).toEqual('Hello, James!');
        expect(component.exprOnce).toEqual('Hello, Chirayu!');
      })));

      it('should error on non-asignable-mapping', async(inject(() {
        expect(() {
          var element = $(r'<div><non-assignable-mapping></non-assignable-mapping</div>');
          $compile(element, directives)(injector, element);
        }).toThrow("Expression '1+2' is not assignable in mapping '@1+2' for attribute 'attr'.");
      })));

      it('should expose mapped attributes as camel case', async(inject(() {
        var element = $('<camel-case-map camel-case=G></camel-case-map>');
        $compile(element, directives)(injector, element);
        microLeap();
        rootScope.apply();
        var componentScope = rootScope.context['camelCase'];
        expect(componentScope.context['camelCase']).toEqual('G');
      })));

      it('should throw an exception if required directive is missing', async(inject((Compiler $compile, Scope rootScope, Injector injector) {
        try {
          var element = $('<tab local><pane></pane><pane local></pane></tab>');
          $compile(element, directives)(injector, element);
        } catch (e) {
          var text = '$e';
          expect(text).toContain('No provider found for');
          expect(text).toContain('(resolving ');
          expect(text).toContain('LocalAttrDirective');
        }
      })));

      it('should publish component controller into the scope', async(inject((NgZone zone) {
        var element = $(r'<div><publish-me></publish-me></div>');
        zone.run(() =>
        $compile(element, directives)(injector, element));

        microLeap();
        expect(element.textWithShadow()).toEqual('WORKED');
      })));

      it('should publish directive controller into the scope', async(inject((NgZone zone) {
        var element = $(r'<div><div publish-me>{{ctrlName.value}}</div></div>');
        zone.run(() =>
        $compile(element, directives)(injector, element));

        microLeap();
        expect(element.text()).toEqual('WORKED');
      })));

      it('should "publish" controller to injector under provided publishTypes', inject(() {
        var element = $(r'<div publish-types></div>');
        $compile(element, directives)(injector, element);
        expect(PublishTypesAttrDirective._injector.get(PublishTypesAttrDirective)).
            toBe(PublishTypesAttrDirective._injector.get(PublishTypesDirectiveSuperType));
      }));

      it('should allow repeaters over controllers', async(inject((Logger logger) {
        var element = $(r'<log ng-repeat="i in [1, 2]"></log>');
        $compile(element, directives)(injector, element);
        rootScope.apply();
        microLeap();

        expect(logger.length).toEqual(2);
      })));

      describe('lifecycle', () {
        var backend;
        beforeEach(module((Module module) {
          backend = new MockHttpBackend();
          module
            ..value(HttpBackend, backend)
            ..value(MockHttpBackend, backend);
        }));

        it('should fire onTemplate method', async(inject((Logger logger, MockHttpBackend backend) {
          backend.whenGET('some/template.url').respond('<div>WORKED</div>');
          var scope = rootScope.createChild({});
          scope.context['isReady'] = 'ready';
          scope.context['logger'] = logger;
          scope.context['once'] = null;
          var element = $('<attach-detach attr-value="{{isReady}}" expr-value="isReady" once-value="once">{{logger("inner")}}</attach-detach>');
          $compile(element, directives)(injector.createChild([new Module()..value(Scope, scope)]), element);
          expect(logger).toEqual(['new']);

          expect(logger).toEqual(['new']);

          rootScope.apply();
          var expected = ['new', 'attach:@ready; =>ready; =>!null', 'inner'];
          assert((() {
            // there is an assertion in flush which double checks that
            // flushes do not change model. This assertion creates one
            // more 'inner';
            expected.add('inner');
            return true;
          })());
          expect(logger).toEqual(expected);
          logger.clear();

          backend.flush();
          microLeap();
          expect(logger).toEqual(['templateLoaded', rootScope.context['shadowRoot']]);
          logger.clear();

          scope.destroy();
          expect(logger).toEqual(['detach']);
          expect(element.textWithShadow()).toEqual('WORKED');
        })));

        it('should should not call attach after scope is destroyed', async(inject((Logger logger, MockHttpBackend backend) {
          backend.whenGET('foo.html').respond('<div>WORKED</div>');
          var element = $('<simple-attach></simple-attach>');
          var scope = rootScope.createChild({});
          $compile(element, directives)(injector.createChild([new Module()..value(Scope, scope)]), element);
          expect(logger).toEqual(['SimpleAttachComponent']);
          scope.destroy();

          rootScope.apply();
          microLeap();

          expect(logger).toEqual(['SimpleAttachComponent']);
        })));
      });

      describe('invalid components', () {
        it('should throw a useful error message for missing selectors', () {
          module((Module module) {
            module
              ..type(MissingSelector);
          });
          expect(() {
            inject((Compiler c) { });
          }).toThrow('Missing selector annotation for MissingSelector');
        });


        it('should throw a useful error message for invalid selector', () {
          module((Module module) {
            module
              ..type(InvalidSelector);
          });
          expect(() {
            inject((Compiler c) { });
          }).toThrow('Unknown selector format \'buttonbar button\' for InvalidSelector');
        });
      });
    });


    describe('controller scoping', () {
      it('should make controllers available to sibling and child controllers', async(inject((Compiler $compile, Scope rootScope, Logger log, Injector injector) {
        var element = $('<tab local><pane local></pane><pane local></pane></tab>');
        $compile(element, directives)(injector, element);
        microLeap();

        expect(log.result()).toEqual('TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0; PaneComponent-2; LocalAttrDirective-0');
      })));

      it('should reuse controllers for transclusions', async(inject((Compiler $compile, Scope rootScope, Logger log, Injector injector) {
        var element = $('<div simple-transclude-in-attach include-transclude>block</div>');
        $compile(element, directives)(injector, element);
        microLeap();

        rootScope.apply();
        expect(log.result()).toEqual('IncludeTransclude; SimpleTransclude');
      })));

      it('should expose a parent controller to the scope of its children', inject((TestBed _) {

        var element = _.compile('<div my-parent-controller>' +
                                '  <div my-child-controller>{{ my_parent.data() }}</div>' +
                                '</div>');

        rootScope.apply();

        expect(element.text).toContain('my data');
      }));
    });


    describe('NgDirective', () {
      it('should allow creation of a new scope', inject((TestBed _) {
        _.rootScope.context['name'] = 'cover me';
        _.compile('<div><div my-controller>{{name}}</div></div>');
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('cover me');
        expect(_.rootElement.text).toEqual('MyController');
      }));
    });

  });


@NgController(
  selector: '[my-parent-controller]',
  publishAs: 'my_parent'
)
class MyParentController {
  data() {
    return "my data";
  }
}

@NgController(
  selector: '[my-child-controller]',
  publishAs: 'my_child'
)
class MyChildController {}

@NgComponent(
    selector: 'tab',
    visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY)
class TabComponent {
  int id = 0;
  Logger log;
  LocalAttrDirective local;
  TabComponent(Logger this.log, LocalAttrDirective this.local, Scope scope) {
    log('TabComponent-${id++}');
    local.ping();
  }
}

@NgComponent(selector: 'pane')
class PaneComponent {
  TabComponent tabComponent;
  LocalAttrDirective localDirective;
  Logger log;
  PaneComponent(TabComponent this.tabComponent, LocalAttrDirective this.localDirective, Logger this.log, Scope scope) {
    log('PaneComponent-${tabComponent.id++}');
    localDirective.ping();
  }
}

@NgDirective(
    selector: '[local]',
    visibility: NgDirective.LOCAL_VISIBILITY)
class LocalAttrDirective {
  int id = 0;
  Logger log;
  LocalAttrDirective(Logger this.log);
  ping() {
    log('LocalAttrDirective-${id++}');
  }
}

@NgDirective(
    selector: '[simple-transclude-in-attach]',
    visibility: NgDirective.CHILDREN_VISIBILITY, children: NgAnnotation.TRANSCLUDE_CHILDREN)
class SimpleTranscludeInAttachAttrDirective {
  SimpleTranscludeInAttachAttrDirective(BlockHole blockHole, BoundBlockFactory boundBlockFactory, Logger log, RootScope scope) {
    scope.runAsync(() {
      var block = boundBlockFactory(scope);
      block.insertAfter(blockHole);
      log('SimpleTransclude');
    });
  }
}

@NgDirective(selector: '[include-transclude]')
class IncludeTranscludeAttrDirective {
  IncludeTranscludeAttrDirective(SimpleTranscludeInAttachAttrDirective simple, Logger log) {
    log('IncludeTransclude');
  }
}

@NgDirective(selector: '[two-directives]')
class OneOfTwoDirectives {
  OneOfTwoDirectives(Logger log) {
    log('OneOfTwo');
  }
}

@NgDirective(selector: '[two-directives]')
class TwoOfTwoDirectives {
  TwoOfTwoDirectives(Logger log) {
    log('TwoOfTwo');
  }
}

class PublishTypesDirectiveSuperType {
}

@NgDirective(
    selector: '[publish-types]',
    publishTypes: const [PublishTypesDirectiveSuperType])
class PublishTypesAttrDirective implements PublishTypesDirectiveSuperType {
  static Injector _injector;
  PublishTypesAttrDirective(Injector injector) {
    _injector = injector;
  }
}

@NgComponent(
    selector: 'simple',
    template: r'{{name}}(<content>SHADOW-CONTENT</content>)'
)
class SimpleComponent {
  SimpleComponent(Scope scope) {
    scope.context['name'] = 'INNER';
  }
}

@NgComponent(
    selector: 'io',
    template: r'<content></content>',
    map: const {
        'attr': '@scope.context.attr',
        'expr': '<=>scope.context.expr',
        'ondone': '&scope.context.ondone',
    }
)
class IoComponent {
  Scope scope;
  IoComponent(Scope scope) {
    this.scope = scope;
    scope.rootScope.context['ioComponent'] = this;
    scope.context['expr'] = 'initialExpr';
  }
}

@NgComponent(
    selector: 'io-controller',
    template: r'<content></content>',
    publishAs: 'ctrl',
    map: const {
        'attr': '@attr',
        'expr': '<=>expr',
        'once': '=>!exprOnce',
        'ondone': '&onDone',
        'on-optional': '&onOptional'
    }
)
class IoControllerComponent {
  Scope scope;
  var attr;
  var expr;
  var exprOnce;
  var onDone;
  var onOptional;
  IoControllerComponent(Scope scope) {
    this.scope = scope;
    scope.rootScope.context['ioComponent'] = this;
  }
}

@NgComponent(
    selector: 'unpublished-io-controller',
    template: r'<content></content>',
    map: const {
        'attr': '@attr',
        'expr': '<=>expr',
        'ondone': '&onDone',
        'onOptional': '&onOptional'
    }
)
class UnpublishedIoControllerComponent {
  Scope scope;
  var attr;
  var expr;
  var exprOnce;
  var onDone;
  var onOptional;
  UnpublishedIoControllerComponent(Scope scope) {
    this.scope = scope;
    scope.rootScope.context['ioComponent'] = this;
  }
}

@NgComponent(
    selector: 'incorrect-mapping',
    template: r'<content></content>',
    map: const { 'attr': 'foo' })
class IncorrectMappingComponent { }

@NgComponent(
    selector: 'non-assignable-mapping',
    template: r'<content></content>',
    map: const { 'attr': '@1+2' })
class NonAssignableMappingComponent { }

@NgComponent(
    selector: 'camel-case-map',
    map: const {
      'camel-case': '@scope.context.camelCase',
    }
)
class CamelCaseMapComponent {
  Scope scope;
  CamelCaseMapComponent(Scope this.scope) {
    scope.rootScope.context['camelCase'] = scope;
  }
}

@NgComponent(
    selector: 'parent-expression',
    template: '<div>inside {{fromParent()}}</div>',
    map: const {
      'from-parent': '&scope.context.fromParent',
    }
)
class ParentExpressionComponent {
  Scope scope;
  ParentExpressionComponent(Scope this.scope);
}

@NgComponent(
    selector: 'publish-me',
    template: r'<content>{{ctrlName.value}}</content>',
    publishAs: 'ctrlName'
)
class PublishMeComponent {
  String value = 'WORKED';
}


@NgController (
    selector: '[publish-me]',
    publishAs: 'ctrlName'
)
class PublishMeDirective {
  String value = 'WORKED';
}


@NgComponent(
    selector: 'log',
    template: r'<content></content>',
    publishAs: 'ctrlName'
)
class LogComponent {
  LogComponent(Scope scope, Logger logger) {
    logger(scope);
  }
}

@NgComponent(
    selector: 'attach-detach',
    templateUrl: 'some/template.url',
    map: const {
        'attr-value': '@attrValue',
        'expr-value': '<=>exprValue',
        'once-value': '=>!onceValue',
        'optional-one': '=>optional',
        'optional-two': '<=>optional',
        'optional-once': '=>!optional',
    }
)
class AttachDetachComponent implements NgAttachAware, NgDetachAware, NgShadowRootAware {
  Logger logger;
  Scope scope;
  String attrValue = 'too early';
  String exprValue = 'too early';
  String onceValue = 'too early';
  String optional;

  AttachDetachComponent(Logger this.logger, TemplateLoader templateLoader, Scope this.scope) {
    logger('new');
    templateLoader.template.then((_) => logger('templateLoaded'));
  }

  attach() => logger('attach:@$attrValue; =>$exprValue; =>!$onceValue');
  detach() => logger('detach');
  onShadowRoot(shadowRoot) {
    scope.rootScope.context['shadowRoot'] = shadowRoot;
    logger(shadowRoot);
  }
}

@NgController(
    selector: '[my-controller]',
    publishAs: 'myCtrl'
)
class MyController {
  MyController(Scope scope) {
    scope.context['name'] = 'MyController';
  }
}

@NgComponent()
class MissingSelector {}

@NgComponent(selector: 'buttonbar button')
class InvalidSelector {}

@NgFilter(name:'hello')
class SayHelloFilter {
  call(String str) {
    return 'Hello, $str!';
  }
}

@NgComponent(
    selector: 'expr-attr-component',
    template: r'<content></content>',
    publishAs: 'ctrl',
    map: const {
        'expr': '<=>expr',
        'one-way': '=>oneWay',
        'once': '=>!exprOnce'
    }
)
class ExprAttrComponent {
  var expr;
  var oneWay;
  var exprOnce;

  ExprAttrComponent(Scope scope) {
    scope.rootScope.context['exprAttrComponent'] = this;
  }
}

@NgComponent(
    selector: 'simple-attach',
    templateUrl: 'foo.html')
class SimpleAttachComponent implements NgAttachAware, NgShadowRootAware {
  Logger logger;
  SimpleAttachComponent(this.logger) {
    logger('SimpleAttachComponent');
  }
  attach() => logger('attach');
  onShadowRoot(_) => logger('onShadowRoot');
}
