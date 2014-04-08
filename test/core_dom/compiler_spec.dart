library compiler_spec;

import '../_specs.dart';


forBothCompilers(fn) {
  describe('walking compiler', () {
    beforeEachModule((Module m) {
      m.type(Compiler, implementedBy: WalkingCompiler);
      return m;
    });
    fn();
  });

  describe('tagging compiler', () {
    beforeEachModule((Module m) {
      m.type(Compiler, implementedBy: TaggingCompiler);
      return m;
    });
    fn();
  });
}

void main() {
  forBothCompilers(() =>
  describe('dte.compiler', () {
    TestBed _;

    beforeEachModule((Module module) {
      module
          ..type(TabComponent)
          ..type(PublishModuleAttrDirective)
          ..type(PaneComponent)
          ..type(SimpleTranscludeInAttachAttrDirective)
          ..type(IgnoreChildrenDirective)
          ..type(IncludeTranscludeAttrDirective)
          ..type(LocalAttrDirective)
          ..type(OneOfTwoDirectives)
          ..type(TwoOfTwoDirectives)
          ..type(MyController)
          ..type(MyParentController)
          ..type(MyChildController);
    });

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should compile basic hello world', () {
      var element = _.compile('<div ng-bind="name"></div>');

      _.rootScope.context['name'] = 'angular';

      expect(element.text).toEqual('');
      _.rootScope.apply();
      expect(element.text).toEqual('angular');
    });

    it('should not throw on an empty list', () {
      _.compile([]);
    });

    it('should compile a comment on the top level', () {
      _.compile('<!-- comment -->');
      expect(_.rootElements[0]).toHaveHtml('<!-- comment -->');
    });

    it('should compile a comment with no directives around', () {
      var element = _.compile('<div><!-- comment --></div>');
      expect(element).toHaveHtml('<!-- comment -->');
    });

    it('should compile a comment when the parent has a directive', () {
      var element = _.compile('<div ng-show="true"><!-- comment --></div>');
      expect(element).toHaveHtml('<!-- comment -->');
    });

    it('should compile a directive in a child', () {
      var element = _.compile('<div><div ng-bind="name"></div></div>');

      _.rootScope.context['name'] = 'angular';

      expect(element.text).toEqual('');
      _.rootScope.apply();
      expect(element.text).toEqual('angular');
    });

    it('should compile repeater', () {
      var element = _.compile('<div><div ng-repeat="item in items" ng-bind="item"></div></div>');

      _.rootScope.context['items'] = ['A', 'b'];
      expect(element.text).toEqual('');

      _.rootScope.apply();
      expect(element.text).toEqual('Ab');

      _.rootScope.context['items'] = [];
      _.rootScope.apply();
      expect(element).toHaveHtml('<!--ANCHOR: [ng-repeat]=item in items-->');
    });

    it('should compile a text child of a basic repeater', () {
      var element = _.compile(
                '<div ng-show="true">' +
                  '<span ng-repeat="r in [1, 2]">{{r}}</span>' +
                '</div>');
      _.rootScope.apply();
      expect(element.text).toEqual('12');
    });

    it('should compile a text child of a repeat with a directive', () {
      _.compile(
            '<div ng-show="true">'
              '<span ng-show=true" ng-repeat="r in robots">{{r}}</span>'
            '</div>');
    });

    it('should compile a sibling template directive', () {
      var element = _.compile(
        '<div ng-model="selected">'
          '<option value="">blank</option>'
          '<div ng-repeat="value in [1,2]" ng-value="value">{{value}}</div>'
      '</div>');

      _.rootScope.apply();
      expect(element.text).toEqual('blank12');
    });

    it('should compile repeater with children', (Compiler compile) {
      var element = _.compile('<div><div ng-repeat="item in items"><div ng-bind="item"></div></div></div>');

      _.rootScope.context['items'] = ['A', 'b'];

      expect(element.text).toEqual('');
      _.rootScope.apply();
      expect(element.text).toEqual('Ab');

      _.rootScope.context['items'] = [];
      _.rootScope.apply();
      expect(element).toHaveHtml('<!--ANCHOR: [ng-repeat]=item in items-->');
    });

    it('should compile text', (Compiler compile) {
      var element = _.compile('<div>{{name}}<span>!</span></div>');
      _.rootScope.context['name'] = 'OK';

      microLeap();
      _.rootScope.apply();
      expect(element.text).toEqual('OK!');
    });

    it('should compile nested repeater', (Compiler compile) {
      var element = _.compile(
          '<div>' +
          '<ul ng-repeat="lis in uls">' +
          '<li ng-repeat="li in lis">{{li}}</li>' +
          '</ul>' +
          '</div>');

      _.rootScope.context['uls'] = [['A'], ['b']];

      _.rootScope.apply();
      expect(element.text).toEqual('Ab');
    });

    it('should compile two directives with the same selector', (Logger log) {
      var element = _.compile('<div two-directives></div>');

      _.rootScope.apply();

      expect(log).toEqual(['OneOfTwo', 'TwoOfTwo']);
    });

    it('should compile a directive that ignores children', (Logger log) {
      // The ng-repeat comes first, so it is not ignored, but the children *are*
      var element = _.compile('<div ng-repeat="i in [1,2]" ignore-children><div two-directives></div></div>');

      _.rootScope.apply();

      expect(log).toEqual(['Ignore', 'Ignore']);
    });

    it('should compile a text child after a directive child', () {
      _.compile('<div><span ng-show="true">hi</span>{{hello}}</div>');
    });


    describe("interpolation", () {
      it('should interpolate attribute nodes', () {
        var element = _.compile('<div test="{{name}}"></div>');

        _.rootScope.context['name'] = 'angular';

        _.rootScope.apply();
        expect(element.attributes['test']).toEqual('angular');
      });

      it('should interpolate text nodes', () {
        var element = _.compile('<div>{{name}}</div>');

        _.rootScope.context['name'] = 'angular';

        _.rootScope.apply();
        expect(element.text).toEqual('angular');
      });
    });


    describe('components', () {
      beforeEachModule((Module module) {
        module
          ..type(SimpleComponent)
          ..type(CamelCaseMapComponent)
          ..type(IoComponent)
          ..type(IoControllerComponent)
          ..type(UnpublishedIoControllerComponent)
          ..type(IncorrectMappingComponent)
          ..type(NonAssignableMappingComponent)
          ..type(ParentExpressionComponent)
          ..type(PublishMeComponent)
          ..type(PublishMeDirective)
          ..type(LogComponent)
          ..type(AttachDetachComponent)
          ..type(SimpleAttachComponent)
          ..type(SimpleComponent)
          ..type(ExprAttrComponent)
          ..type(LogElementComponent)
          ..type(SayHelloFilter);
      });

      it('should select on element', async((NgZone zone) {
        var element = _.compile(r'<div><simple></simple></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('INNER()');
      }));

      it('should store ElementProbe with Elements', async(() {
        _.compile('<div><simple>innerText</simple></div>');
        microLeap();
        var simpleElement = _.rootElement.querySelector('simple');
        expect(simpleElement.text).toEqual('innerText');
        var simpleProbe = ngProbe(simpleElement);
        var simpleComponent = simpleProbe.injector.get(SimpleComponent);
        expect(simpleComponent.scope.context['name']).toEqual('INNER');
        var shadowRoot = simpleElement.shadowRoot;
        var shadowProbe = ngProbe(shadowRoot);
        expect(shadowProbe).toBeNotNull();
        expect(shadowProbe.element).toEqual(shadowRoot);
        expect(shadowProbe.parent.element).toEqual(simpleElement);
      }));

      it('should create a simple component', async((NgZone zone) {
        _.rootScope.context['name'] = 'OUTTER';
        var element = _.compile(r'<div>{{name}}:<simple>{{name}}</simple></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('OUTTER:INNER(OUTTER)');
      }));

      it('should create a component that can access parent scope', async((NgZone zone) {
        _.rootScope.context['fromParent'] = "should not be used";
        _.rootScope.context['val'] = "poof";
        var element = _.compile('<parent-expression from-parent=val></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside poof');
      }));

      it('should behave nicely if a mapped attribute is missing', async((NgZone zone) {
        var element = _.compile('<parent-expression></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside ');
      }));

      it('should behave nicely if a mapped attribute evals to null', async((NgZone zone) {
        _.rootScope.context['val'] = null;
        var element = _.compile('<parent-expression fromParent=val></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside ');
      }));

      it('should create a component with I/O', async(() {
         _.compile(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        microLeap();

        _.rootScope.context['name'] = 'misko';
        _.rootScope.apply();
        var component = _.rootScope.context['ioComponent'];
        expect(component.scope.context['name']).toEqual(null);
        expect(component.scope.context['attr']).toEqual('A');
        expect(component.scope.context['expr']).toEqual('misko');
        component.scope.context['expr'] = 'angular';
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('angular');
        expect(_.rootScope.context['done']).toEqual(null);
        component.scope.context['ondone']();
        expect(_.rootScope.context['done']).toEqual(true);
      }));

      xit('should should not create any watchers if no attributes are specified', async((Profiler perf) {
        _.compile(r'<div><io></io></div>');
        microLeap();
        _.injector.get(Scope).apply();
        // Re-enable once we can publish these numbers
        //expect(_.rootScope.watchGroup.totalFieldCost).toEqual(0);
        //expect(_.rootScope.watchGroup.totalCollectionCost).toEqual(0);
        //expect(_.rootScope.watchGroup.totalEvalCost).toEqual(0);
        //expect(_.rootScope.observeGroup.totalFieldCost).toEqual(0);
        //expect(_.rootScope.observeGroup.totalCollectionCost).toEqual(0);
        //expect(_.rootScope.observeGroup.totalEvalCost).toEqual(0);
      }));

      it('should create a component with I/O and "=" binding value should be available', async(() {
        _.rootScope.context['name'] = 'misko';
        _.compile(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        microLeap();

        var component = _.rootScope.context['ioComponent'];
        _.rootScope.apply();
        expect(component.scope.context['expr']).toEqual('misko');
        component.scope.context['expr'] = 'angular';
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('angular');
      }));

      it('should create a component with I/O bound to controller and "=" binding value should be available', async(() {
        _.rootScope.context['done'] = false;
        _.compile(r'<div><io-controller attr="A" expr="name" once="name" ondone="done=true"></io-controller></div>');

        expect(_.injector).toBeDefined();
        microLeap();

        IoControllerComponent component = _.rootScope.context['ioComponent'];

        expect(component.expr).toEqual(null);
        expect(component.exprOnce).toEqual(null);
        expect(component.attr).toEqual('A');
        _.rootScope.apply();

        _.rootScope.context['name'] = 'misko';
        _.rootScope.apply();
        expect(component.expr).toEqual('misko');
        expect(component.exprOnce).toEqual('misko');

        _.rootScope.context['name'] = 'igor';
        _.rootScope.apply();
        expect(component.expr).toEqual('igor');
        expect(component.exprOnce).toEqual('misko');

        component.expr = 'angular';
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('angular');

        expect(_.rootScope.context['done']).toEqual(false);
        component.onDone();
        expect(_.rootScope.context['done']).toEqual(true);

        // Should be noop
        component.onOptional();
      }));

      it('should create a map attribute to controller', async(() {
        _.compile(r'<div><io-controller attr="{{name}}"></io-controller></div>');
        microLeap();

        IoControllerComponent component = _.rootScope.context['ioComponent'];

        _.rootScope.context['name'] = 'misko';
        _.rootScope.apply();
        expect(component.attr).toEqual('misko');

        _.rootScope.context['name'] = 'james';
        _.rootScope.apply();
        expect(component.attr).toEqual('james');
      }));

      it('should create a unpublished component with I/O bound to controller and "=" binding value should be available', async(() {
        _.rootScope.context['name'] = 'misko';
        _.rootScope.context['done'] = false;
        _.compile(r'<div><unpublished-io-controller attr="A" expr="name" ondone="done=true"></unpublished-io-controller></div>');
        microLeap();

        UnpublishedIoControllerComponent component = _.rootScope.context['ioComponent'];
        _.rootScope.apply();
        expect(component.attr).toEqual('A');
        expect(component.expr).toEqual('misko');
        component.expr = 'angular';
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('angular');

        expect(_.rootScope.context['done']).toEqual(false);
        component.onDone();
        expect(_.rootScope.context['done']).toEqual(true);

        // Should be noop
        component.onOptional();
      }));

      it('should error on incorrect mapping', async(() {
        expect(() {
          _.compile(r'<div><incorrect-mapping></incorrect-mapping</div>');
        }).toThrow("Unknown mapping 'foo\' for attribute 'attr'.");
      }));

      it('should support filters in attribute expressions', async(() {
        _.compile(r'''<expr-attr-component expr="'Misko' | hello" one-way="'James' | hello" once="'Chirayu' | hello"></expr-attr-component>''');
        ExprAttrComponent component = _.rootScope.context['exprAttrComponent'];
        _.rootScope.apply();
        expect(component.expr).toEqual('Hello, Misko!');
        expect(component.oneWay).toEqual('Hello, James!');
        expect(component.exprOnce).toEqual('Hello, Chirayu!');
      }));

      it('should error on non-asignable-mapping', async(() {
        expect(() {
          _.compile(r'<div><non-assignable-mapping></non-assignable-mapping</div>');
        }).toThrow("Expression '1+2' is not assignable in mapping '@1+2' for attribute 'attr'.");
      }));

      it('should expose mapped attributes as camel case', async(() {
        _.compile('<camel-case-map camel-case=G></camel-case-map>');
        microLeap();
        _.rootScope.apply();
        var componentScope = _.rootScope.context['camelCase'];
        expect(componentScope.context['camelCase']).toEqual('G');
      }));

      // TODO: This is a terrible test
      it('should throw an exception if required directive is missing', async(() {
        try {
          _.compile('<tab local><pane></pane><pane local></pane></tab>');
        } catch (e) {
          var text = '$e';
          expect(text).toContain('No provider found for');
          expect(text).toContain('(resolving ');
          expect(text).toContain('LocalAttrDirective');
        }
      }));

      it('should publish component controller into the scope', async((NgZone zone) {
        var element = _.compile(r'<div><publish-me></publish-me></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('WORKED');
      }));

      it('should publish directive controller into the scope', async((NgZone zone) {
        var element = _.compile(r'<div><div publish-me>{{ctrlName.value}}</div></div>');

        microLeap();
        _.rootScope.apply();
        expect(element.text).toEqual('WORKED');
      }));

      it('should "publish" controller to injector under provided module', () {
        _.compile(r'<div publish-types></div>');
        expect(PublishModuleAttrDirective._injector.get(PublishModuleAttrDirective)).
        toBe(PublishModuleAttrDirective._injector.get(PublishModuleDirectiveSuperType));
      });

      it('should allow repeaters over controllers', async((Logger logger) {
        _.compile(r'<log ng-repeat="i in [1, 2]"></log>');
        _.rootScope.apply();
        microLeap();

        expect(logger.length).toEqual(2);
      }));

      describe('lifecycle', () {
        beforeEachModule((Module module) {
          var httpBackend = new MockHttpBackend();

          module
            ..value(HttpBackend, httpBackend)
            ..value(MockHttpBackend, httpBackend);
        });

        it('should fire onTemplate method', async((Compiler compile, Logger logger, MockHttpBackend backend) {
          backend.whenGET('some/template.url').respond('<div>WORKED</div>');
          var scope = _.rootScope.createChild({});
          scope.context['isReady'] = 'ready';
          scope.context['logger'] = logger;
          scope.context['once'] = null;
          var elts = es('<attach-detach attr-value="{{isReady}}" expr-value="isReady" once-value="once">{{logger("inner")}}</attach-detach>');
          compile(elts, _.injector.get(DirectiveMap))(_.injector.createChild([new Module()..value(Scope, scope)]), elts);
          expect(logger).toEqual(['new']);

          expect(logger).toEqual(['new']);

          _.rootScope.apply();
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
          expect(logger).toEqual(['templateLoaded', _.rootScope.context['shadowRoot']]);
          logger.clear();

          scope.destroy();
          expect(logger).toEqual(['detach']);
          expect(elts).toHaveText('WORKED');
        }));

        it('should should not call attach after scope is destroyed', async((Compiler compile, Logger logger, MockHttpBackend backend) {
          backend.whenGET('foo.html').respond('<div>WORKED</div>');
          var elts = es('<simple-attach></simple-attach>');
          var scope = _.rootScope.createChild({});
          compile(elts, _.injector.get(DirectiveMap))(_.injector.createChild([new Module()..value(Scope, scope)]), elts);
          expect(logger).toEqual(['SimpleAttachComponent']);
          scope.destroy();

          _.rootScope.apply();
          microLeap();

          expect(logger).toEqual(['SimpleAttachComponent']);
        }));

        it('should inject compenent element as the dom.Element', async((Logger log, TestBed _, MockHttpBackend backend) {
          backend.whenGET('foo.html').respond('<div>WORKED</div>');
          _.compile('<log-element></log-element>');
          Element element = _.rootElement;
          expect(log).toEqual([element, element, element.shadowRoot]);
        }));
      });

      describe('invalid components', () {
        it('should throw a useful error message for missing selectors', () {
          Module module = new Module()
              ..type(MissingSelector);
          var injector = _.injector.createChild([module], forceNewInstances: [Compiler, DirectiveMap]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);
          expect(() {
              c(es('<div></div>'), injector.get(DirectiveMap));
          }).toThrow('Missing selector annotation for MissingSelector');
        });


        it('should throw a useful error message for invalid selector', () {
          Module module = new Module()
            ..type(InvalidSelector);
          var injector = _.injector.createChild([module], forceNewInstances: [Compiler, DirectiveMap]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);

          expect(() {
            c(es('<div></div>'), directives);
          }).toThrow('Unknown selector format \'buttonbar button\' for InvalidSelector');
        });
      });
    });


    describe('controller scoping', () {
      it('should make controllers available to sibling and child controllers', async((Logger log) {
        _.compile('<tab local><pane local></pane><pane local></pane></tab>');
        microLeap();

        expect(log.result()).toEqual('TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0; PaneComponent-2; LocalAttrDirective-0');
      }));

      it('should use the correct parent injector', async((Logger log) {
        // Getting the parent offsets correct while descending the template is tricky.  If we get it wrong, this
        // test case will create too many TabCompoenents.

        _.compile('<div ng-bind="true"><div ignore-children></div><tab local><pane local></pane></tab>');
        microLeap();

        expect(log.result()).toEqual('Ignore; TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0');
      }));

      it('should reuse controllers for transclusions', async((Logger log) {
        _.compile('<div simple-transclude-in-attach include-transclude>view</div>');
        microLeap();

        _.rootScope.apply();
        expect(log.result()).toEqual('IncludeTransclude; SimpleTransclude');
      }));

      it('should expose a parent controller to the scope of its children', (TestBed _) {
        var element = _.compile('<div my-parent-controller>'
            '  <div my-child-controller>{{ my_parent.data() }}</div>'
            '</div>');

        _.rootScope.apply();

        expect(element.text).toContain('my data');
      });

      it('should expose a ancestor controller to the scope of its children thru a undecorated element', (TestBed _) {
        var element = _.compile(
            '<div my-parent-controller>'
              '<div>'
                '<div my-child-controller>{{ my_parent.data() }}</div>'
              '</div>'
            '</div>');

        _.rootScope.apply();

        expect(element.text).toContain('my data');
      });
    });


    describe('NgDirective', () {
      it('should allow creation of a new scope', () {
        _.rootScope.context['name'] = 'cover me';
        _.compile('<div><div my-controller>{{name}}</div></div>');
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('cover me');
        expect(_.rootElement.text).toEqual('MyController');
      });
    });

  }));
}


@NgController(
  selector: '[my-parent-controller]',
  publishAs: 'my_parent')
class MyParentController {
  data() {
    return "my data";
  }
}

@NgController(
  selector: '[my-child-controller]',
  publishAs: 'my_child')
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
    visibility: NgDirective.CHILDREN_VISIBILITY, children: AbstractNgAnnotation.TRANSCLUDE_CHILDREN)
class SimpleTranscludeInAttachAttrDirective {
  SimpleTranscludeInAttachAttrDirective(ViewPort viewPort, BoundViewFactory boundViewFactory, Logger log, RootScope scope) {
    scope.runAsync(() {
      var view = boundViewFactory(scope);
      viewPort.insert(view);
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

@NgDirective(
    selector: '[ignore-children]',
    children: AbstractNgAnnotation.IGNORE_CHILDREN
)
class IgnoreChildrenDirective {
  IgnoreChildrenDirective(Logger log) {
    log('Ignore');
  }
}

class PublishModuleDirectiveSuperType {
}

@NgDirective(
    selector: '[publish-types]',
    module: PublishModuleAttrDirective.module)
class PublishModuleAttrDirective implements PublishModuleDirectiveSuperType {
  static Module _module = new Module()
      ..factory(PublishModuleDirectiveSuperType, (i) => i.get(PublishModuleAttrDirective));
  static module() => _module;

  static Injector _injector;
  PublishModuleAttrDirective(Injector injector) {
    _injector = injector;
  }
}

@NgComponent(
    selector: 'simple',
    template: r'{{name}}(<content>SHADOW-CONTENT</content>)')
class SimpleComponent {
  Scope scope;
  SimpleComponent(Scope this.scope) {
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
    })
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
    })
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
    })
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
    })
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
    })
class ParentExpressionComponent {
  Scope scope;
  ParentExpressionComponent(Scope this.scope);
}

@NgComponent(
    selector: 'publish-me',
    template: r'<content>{{ctrlName.value}}</content>',
    publishAs: 'ctrlName')
class PublishMeComponent {
  String value = 'WORKED';
}

@NgController (
    selector: '[publish-me]',
    publishAs: 'ctrlName')
class PublishMeDirective {
  String value = 'WORKED';
}


@NgComponent(
    selector: 'log',
    template: r'<content></content>',
    publishAs: 'ctrlName')
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
    })
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
    publishAs: 'myCtrl')
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
    })
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

@NgComponent(
    selector: 'log-element',
    templateUrl: 'foo.html')
class LogElementComponent{
  LogElementComponent(Logger logger, Element element, Node node,
                        ShadowRoot shadowRoot) {
    logger(element);
    logger(node);
    logger(shadowRoot);
  }
}
