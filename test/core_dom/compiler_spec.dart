library compiler_spec;

import '../_specs.dart';
import 'package:angular/core_dom/directive_injector.dart';


withElementProbeConfig(fn) {
  describe('with ElementProbe enabled', () {
    beforeEachModule((Module m) {
      return m;
    });
    fn('elementProbe');
  });

  describe('with ElementProbe disabled', () {
    beforeEachModule((Module m) {
      m.bind(CompilerConfig, toValue: new CompilerConfig.withOptions(elementProbeEnabled: false));
      return m;
    });
    fn('no-elementProbe');
  });
}

forAllCompilersAndComponentFactories(fn) {
  withElementProbeConfig(fn);

  describe('transcluding components', () {
    beforeEachModule((Module m) {
      m.bind(ComponentFactory, toImplementation: TranscludingComponentFactory);

      return m;
    });
    fn('transcluding');
  });
}

void main() {
  forAllCompilersAndComponentFactories((compilerType) =>
  describe('dte.compiler', () {
    TestBed _;

    beforeEachModule((Module module) {
      module
          ..bind(TabComponent)
          ..bind(PublishModuleAttrDirective)
          ..bind(PaneComponent)
          ..bind(SimpleTranscludeInAttachAttrDirective)
          ..bind(IgnoreChildrenDirective)
          ..bind(IncludeTranscludeAttrDirective)
          ..bind(LocalAttrDirective)
          ..bind(OneOfTwoDirectives)
          ..bind(TwoOfTwoDirectives)
          ..bind(SameNameDecorator)
          ..bind(SameNameTransclude)
          ..bind(ScopeAwareComponent)
          ..bind(Parent, toValue: null)
          ..bind(Child)
          ..bind(ChildTemplateComponent)
          ..bind(InjectorDependentComponent);
    });

    beforeEach((TestBed tb) => _ = tb);

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
              '<span ng-show="true" ng-repeat="r in robots">{{r}}</span>'
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


    describe("bind-", () {
      beforeEachModule((Module module) {
        module
          ..bind(IoComponent);
      });

      it('should support bind- syntax', () {
        var element = _.compile('<div ng-bind bind-ng-bind="name"></div>');

        _.rootScope.context['name'] = 'angular';

        expect(element.text).toEqual('');
        _.rootScope.apply();
        expect(element.text).toEqual('angular');
      });

      it('should work with attr bindings', async(() {
        _.compile('<div><io bind-attr="\'A\'"></io></div>');
        microLeap();
        _.rootScope.apply();

        var component = _.rootScope.context['ioComponent'];
        expect(component.scope.context['attr']).toEqual('A');
      }));

      it('should work with one-way bindings', async(() {
        _.compile('<div><io bind-oneway="name"></io></div>');
        _.rootScope.context['name'] = 'misko';
        microLeap();
        _.rootScope.apply();
        var component = _.rootScope.context['ioComponent'];
        expect(component.scope.context['oneway']).toEqual('misko');

        component.scope.context['oneway'] = 'angular';
        _.rootScope.apply();
        // Not two-way, did not change.
        expect(_.rootScope.context['name']).toEqual('misko');
      }));

      it('should work with two-way bindings', async(() {
        _.compile('<div><io bind-expr="name"></io></div>');

        _.rootScope.context['name'] = 'misko';
        microLeap();
        _.rootScope.apply();
        var component = _.rootScope.context['ioComponent'];
        expect(component.scope.context['expr']).toEqual('misko');
        component.scope.context['expr'] = 'angular';
        _.rootScope.apply();
        expect(_.rootScope.context['name']).toEqual('angular');
      }));
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
          ..bind(AttachWithAttr)
          ..bind(CamelCaseMapComponent)
          ..bind(IoComponent)
          ..bind(IoControllerComponent)
          ..bind(UnpublishedIoControllerComponent)
          ..bind(IncorrectMappingComponent)
          ..bind(NonAssignableMappingComponent)
          ..bind(ParentExpressionComponent)
          ..bind(PublishMeComponent)
          ..bind(LogComponent)
          ..bind(AttachDetachComponent)
          ..bind(SimpleAttachComponent)
          ..bind(SimpleComponent)
          ..bind(MultipleContentTagsComponent)
          ..bind(ConditionalContentComponent)
          ..bind(ExprAttrComponent)
          ..bind(LogElementComponent)
          ..bind(SayHelloFormatter)
          ..bind(OuterComponent)
          ..bind(InnerComponent)
          ..bind(InnerInnerComponent)
          ..bind(OuterWithDivComponent)
          ..bind(OneTimeDecorator)
          ..bind(OnceInside)
          ..bind(OuterShadowless)
          ..bind(InnerShadowy)
          ..bind(TemplateUrlComponent);
      });

      describe("distribution", () {
        it('should safely remove components that have no content', async(() {
          _.rootScope.context['flag'] = true;
          _.compile('<div ng-if=flag><simple></simple></div>');
          microLeap(); _.rootScope.apply();
          _.rootScope.context['flag'] = false;
          microLeap(); _.rootScope.apply();
        }));

        it('should support multiple content tags', async(() {
          var element = _.compile(r'<div>'
            '<multiple-content-tags>'
              '<div>B</div>'
              '<div>C</div>'
              '<div class="left">A</div>'
            '</multiple-content-tags>'
          '</div>');

          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(A, BC)');
        }));

        it('should redistribute only direct children', async(() {
          var element = _.compile(r'<div>'
            '<multiple-content-tags>'
              '<div>B<div class="left">A</div></div>'
              '<div>C</div>'
            '</multiple-content-tags>'
          '</div>');

          microLeap();
          _.rootScope.apply();

          expect(element).toHaveText('(, BAC)');
        }));

        it("should redistribute when the light dom changes", async(() {
          var element = _.compile(r'<div>'
            '<multiple-content-tags>'
              '<div ng-if="showLeft" class="left">A</div>'
              '<div>B</div>'
            '</multiple-content-tags>'
          '</div>');
          document.body.append(element);

          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(, B)');

          _.rootScope.context['showLeft'] = true;
          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(A, B)');

          _.rootScope.context['showLeft'] = false;
          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(, B)');
        }));

        it("should redistribute when a class has been added or removed", async(() {
          var element = _.compile(r'<div>'
            '<multiple-content-tags>'
              '<div ng-class="{\'left\':showLeft}">A</div>'
              '<div>B</div>'
            '</multiple-content-tags>'
          '</div>');
          document.body.append(element);

          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(, AB)');

          _.rootScope.context['showLeft'] = true;
          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(A, B)');

          _.rootScope.context['showLeft'] = false;
          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('(, AB)');
        }));

        it('should redistribute when the shadow dom changes', async(() {
          if (compilerType == 'no-elementProbe') return;

          var element = _.compile(r'<div>'
            '<conditional-content>'
              '<div class="left">A</div>'
              '<div>B</div>'
              '<div>C</div>'
            '</conditional-content>'
          '</div>');

          final scope = _shadowScope(element.children[0]);

          microLeap();
          scope.apply();
          expect(element).toHaveText('(, ABC)');

          scope.context['showLeft'] = true;
          microLeap();
          scope.apply();
          expect(element).toHaveText('(A, BC)');

          scope.context['showLeft'] = false;
          microLeap();
          scope.apply();
          expect(element).toHaveText('(, ABC)');
        }));

        it("should support nested compoonents", async((){
          var element = _.compile(r'<div>'
            '<outer-with-div>'
              '<div ng-class="{\'left\':showLeft, \'right\':!showLeft}">A</div>'
              '<div class="left">B</div>'
              '<div class="left">C</div>'
            '</outer-with-div>'
          '</div>');
          document.body.append(element);

          microLeap();
          _.rootScope.apply();

          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('OUTER(INNER(BC))');

          _.rootScope.context["showLeft"] = true;
          microLeap();
          _.rootScope.apply();

          expect(element).toHaveText('OUTER(INNER(ABC))');
        }));

        it("should support nesting with content being direct child of a nested component", async((){
          // platform.js does not emulate this behavior, so the test fails on firefox.
          // Remove the if when this is fixed.
          if (compilerType != "transcluding") return;

          var element = _.compile(r'<div>'
            '<outer>'
              '<div ng-class="{\'left\':showLeft, \'right\':!showLeft}">A</div>'
              '<div class="right">B</div>'
              '<div class="right">C</div>'
            '</outer>'
          '</div>');
          document.body.append(element);

          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('OUTER(INNER(INNERINNER(,ABC)))');

          _.rootScope.context["showLeft"] = true;
          microLeap();
          _.rootScope.apply();

          expect(element).toHaveText('OUTER(INNER(INNERINNER(A,BC)))');
        }));

        it("should not duplicate elements when using components with templateUrl", async((MockHttpBackend backend) {
          backend.expectGET("${TEST_SERVER_BASE_PREFIX}test/core_dom/template.html").respond(200, "<content></content>");

          _.rootScope.context["show"] = true;
          var element = _.compile(r'<div>'
            '<template-url-component>'
              '<div ng-if="show">A</div>'
              '<div>B</div>'
            '<template-url-component>'
          '</div>');
          document.body.append(element);

          microLeap();
          _.rootScope.apply();

          backend.flush();

          _.rootScope.context["show"] = false;
          microLeap();
          _.rootScope.apply();

          _.rootScope.context["show"] = true;
          microLeap();
          _.rootScope.apply();

          expect(element).toHaveText('AB');
        }));
      });

      it('should store ElementProbe with Elements', async(() {
        if (compilerType == 'no-elementProbe') return;

        _.compile('<div><simple>innerText</simple></div>');
        microLeap();
        _.rootScope.apply();
        var simpleElement = _.rootElement.querySelector('simple');
        expect(simpleElement).toHaveText('INNER(innerText)');
        var simpleProbe = ngProbe(simpleElement);
        var simpleComponent = simpleProbe.injector.getByKey(new Key(SimpleComponent));
        expect(simpleComponent.scope.context['name']).toEqual('INNER');
        var shadowRoot = simpleElement.shadowRoot;

        // If there is no shadow root, skip this.
        if (compilerType != 'transcluding') {
          var shadowProbe = ngProbe(shadowRoot);
          expect(shadowProbe).toBeNotNull();
          expect(shadowProbe.element).toEqual(shadowRoot);
          expect(shadowProbe.parent.element).toEqual(simpleElement);
        }
      }));

      describe('elementProbeEnabled option', () {
        beforeEachModule((Module m) {
          m.bind(CompilerConfig, toValue:
              new CompilerConfig.withOptions(elementProbeEnabled: false));
        });

        it('should not store ElementProbe with Elements', async(() {
          _.compile('<div><simple>innerText</simple></div>');
          microLeap();
          _.rootScope.apply();
          var simpleElement = _.rootElement.querySelector('simple');
          expect(simpleElement).toHaveText('INNER(innerText)');

          expect(() => ngProbe(simpleElement))
              .toThrowWith(message: "Could not find a probe for the node 'simple' nor its parents");

          var shadowRoot = simpleElement.shadowRoot;

          // If there is no shadow root, skip this.
          if (compilerType != 'transcluding') {
            expect(() => ngProbe(shadowRoot))
                .toThrowWith(message: "Could not find a probe for the node 'Instance of 'ShadowRoot'' nor its parents");
          }
        }));
      });

      it('should create a simple component', async((VmTurnZone zone) {
        _.rootScope.context['name'] = 'OUTTER';
        var element = _.compile(r'<div>{{name}}:<simple>{{name}}</simple></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('OUTTER:INNER(OUTTER)');
      }));

      it('should create a component that can access parent scope', async((VmTurnZone zone) {
        _.rootScope.context['fromParent'] = "should not be used";
        _.rootScope.context['val'] = "poof";
        var element = _.compile('<parent-expression from-parent=val></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside poof');
      }));

      it('should behave nicely if a mapped attribute is missing', async((VmTurnZone zone) {
        var element = _.compile('<parent-expression></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside ');
      }));

      it('should behave nicely if a mapped attribute evals to null', async((VmTurnZone zone) {
        _.rootScope.context['val'] = null;
        var element = _.compile('<parent-expression fromParent=val></parent-expression>');

        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('inside ');
      }));

      it('should not pass null to a inner directives', async((Logger logger) {
        _.compile('<div>'
                    '<once-inside ng-repeat="x in nn" v="b"></once-inside>'
                  '</div>');

        _.rootScope.context['nn'] = [1];
        _.rootScope.apply();
        microLeap();

        _.rootScope.context['nn'].add(2);
        _.rootScope.apply();
        microLeap();

        expect(logger.contains(null)).toBeFalsy();
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
        }).toThrowWith(message: "Unknown mapping 'foo\' for attribute 'attr'.");
      }));

      it('should support formatters in attribute expressions', async(() {
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
        }).toThrowWith(message: "Expression '+(1, 2)' is not assignable in mapping '@1+2' for attribute 'attr'.");
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

      it('should "publish" controller to injector under provided module', () {
        _.compile(r'<div publish-types></div>');
        expect(PublishModuleAttrDirective._injector.get(PublishModuleAttrDirective)).
        toBe(PublishModuleAttrDirective._injector.get(PublishModuleDirectiveSuperType));
      });

      it('should expose PublishModuleDirectiveSuperType as PublishModuleDirectiveSuperType', () {
        _.compile(r'<div publish-types probe="publishModuleProbe"></div>');
        Probe probe = _.rootScope.context['publishModuleProbe'];
        var directive = probe.injector.get(PublishModuleDirectiveSuperType);
        expect(directive is PublishModuleAttrDirective).toBeTruthy();
      });

      it('should allow repeaters over controllers', async((Logger logger) {
        _.compile(r'<log ng-repeat="i in [1, 2]"></log>');
        _.rootScope.apply();
        microLeap();

        expect(logger.length).toEqual(2);
      }));

      it('should inject the correct Injectors - Directive and ComponentDirective', async(() {
        _.compile('<cmp-inj></cmp-inj>');
        _.rootScope.apply();
        microLeap();
        // assertions are in the component constructor.
      }));

      describe('lifecycle', () {
        beforeEachModule((Module module) {
          var httpBackend = new MockHttpBackend();

          module
            ..bind(HttpBackend, toValue: httpBackend)
            ..bind(MockHttpBackend, toValue: httpBackend);
        });

        it('should fire onShadowRoot method', async((Compiler compile, Logger logger, MockHttpBackend backend) {
          backend.whenGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/some/template.url').respond(200, '<div>WORKED</div>');
          var scope = _.rootScope.createChild({});
          scope.context['isReady'] = 'ready';
          scope.context['logger'] = logger;
          scope.context['once'] = null;
          var elts = es('<attach-detach attr-value="{{isReady}}" expr-value="isReady" once-value="once">{{logger("inner")}}</attach-detach>');
          compile(elts, _.injector.get(DirectiveMap))(scope, null, elts);
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

          expect(() {
            microLeap();
            backend.flush();
            microLeap();
          }).not.toThrow();

          expect(logger).toEqual(['templateLoaded', _.rootScope.context['shadowRoot']]);
          logger.clear();

          scope.destroy();
          expect(logger).toEqual(['detach']);
          expect(elts).toHaveText('WORKED');
        }));

        it('should should not call attach after scope is destroyed', async((Compiler compile, Logger logger, MockHttpBackend backend) {
          backend.whenGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/foo.html').respond('<div>WORKED</div>');
          var elts = es('<simple-attach></simple-attach>');
          var scope = _.rootScope.createChild({});
          compile(elts, _.injector.get(DirectiveMap))(scope, null, elts);
          expect(logger).toEqual(['SimpleAttachComponent']);
          scope.destroy();

          _.rootScope.apply();
          microLeap();

          expect(logger).toEqual(['SimpleAttachComponent']);
        }));

        it('should call attach after mappings have been set', async((Logger logger) {
          _.compile('<attach-with-attr attr="a" oneway="1+1"></attach-with-attr>');

          _.rootScope.apply();
          microLeap();

          expect(logger).toEqual(['attr', 'oneway', 'attach']);
        }));

        it('should inject compenent element as the dom.Element', async((Logger log, TestBed _, MockHttpBackend backend) {
          backend.whenGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/foo.html').respond('<div>WORKED</div>');
          _.compile('<log-element></log-element>');
          Element element = _.rootElement;
          expect(log).toEqual([element, element,
            // If we don't have a shadowRoot, this is an invalid check
            element.shadowRoot != null ? element.shadowRoot : log[2]]);
        }));
      });

      describe('invalid components', () {
        it('should throw a useful error message for missing selectors', () {
          Module module = new Module()
              ..bind(DirectiveMap)
              ..bind(MissingSelector);
          var injector = _.injector.createChild([module]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);
          expect(() {
              c(es('<div></div>'), injector.get(DirectiveMap));
          }).toThrowWith(message: 'Missing selector annotation for MissingSelector');
        });


        it('should throw a useful error message for invalid selector', () {
          Module module = new Module()
            ..bind(DirectiveMap)
            ..bind(InvalidSelector);
          var injector = _.injector.createChild([module]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);

          expect(() {
            c(es('<div></div>'), directives);
          }).toThrowWith(message: 'Unknown selector format \'buttonbar button\' for InvalidSelector');
        });
      });

      describe('useShadowDom option', () {
        beforeEachModule((Module m) {
          m.bind(ShadowyComponent);
          m.bind(TranscludingComponent);
        });

        it('should create shadowy components', async((Logger log) {
          _.compile('<shadowy></shadowy>');
          expect(log).toEqual(['shadowy']);
          expect(_.rootElement.shadowRoot).toBeNotNull();
        }));

        it('should create transcluding components', async((Logger log) {
          _.compile('<transcluding></transcluding>');
          expect(log).toEqual(['transcluding']);
          expect(_.rootElement.shadowRoot).toBeNull();
        }));

        it('should correctly interpolate shadowless components inside shadowy', async(() {
          var element = _.compile('<outer-shadowless>outer-text</outer-shadowless>');
          microLeap();
          _.rootScope.apply();
          expect(element).toHaveText('inner-text');
        }));

        it('should create other components with the default strategy', async((ComponentFactory factory) {
          _.compile('<simple></simple>');
          if (factory is TranscludingComponentFactory) {
            expect(_.rootElement.shadowRoot).toBeNull();
          } else {
            expect(factory is ShadowDomComponentFactory).toBeTruthy();
            expect(_.rootElement.shadowRoot).toBeNotNull();
          }
        }));

        describe('expando memory', () {
          if (compilerType == 'no-elementProbe') return;

          Expando expando;

          beforeEach((Expando _expando) => expando = _expando);

          ['shadowy', 'transcluding'].forEach((selector) {
            it('should release expando when a node is freed ($selector)', async(() {
              _.rootScope.context['flag'] = true;
              _.compile('<div><div ng-if=flag><$selector>x</$selector></div></div>');
              microLeap(); _.rootScope.apply();
              var element = _.rootElement.querySelector('$selector');
              if (element.shadowRoot != null) {
                element = element.shadowRoot;
              }
              expect(expando[element]).not.toEqual(null);
              _.rootScope.context['flag'] = false;
              microLeap(); _.rootScope.apply();
              expect(expando[element]).toEqual(null);
            }));
          });
        });
      });

      describe('bindings', () {
        it('should set a one-time binding with the correct value', (Logger logger) {
          _.compile(r'<div one-time="v"></div>');

          _.rootScope.context['v'] = 1;

          var context = _.rootScope.context;
          _.rootScope.watch('3+4', (v, _) => context['v'] = v);

          // In the 1st digest iteration:
          //   v will be set to 7
          //   OneTimeDecorator.value will be set to 1
          // In the 2nd digest iteration:
          //   OneTimeDecorator.value will be set to 7
          _.rootScope.apply();

          expect(logger).toEqual([1, 7]);
        });

        it('should keep one-time binding until it is set to non-null', (Logger logger) {
          _.compile(r'<div one-time="v"></div>');
          _.rootScope.context['v'] = null;
          _.rootScope.apply();
          expect(logger).toEqual([null]);

          _.rootScope.context['v'] = 7;
          _.rootScope.apply();
          expect(logger).toEqual([null, 7]);

          // Check that the binding is removed.
          _.rootScope.context['v'] = 8;
          _.rootScope.apply();
          expect(logger).toEqual([null, 7]);
        });

        it('should remove the one-time binding only if it stablizied to null', (Logger logger) {
          _.compile(r'<div one-time="v"></div>');

          _.rootScope.context['v'] = 1;

          var context = _.rootScope.context;
          _.rootScope.watch('3+4', (v, _) => context['v'] = null);

          _.rootScope.apply();
          expect(logger).toEqual([1, null]);

          // Even though there was a null in the unstable model, we shouldn't remove the binding
          context['v'] = 8;
          _.rootScope.apply();
           expect(logger).toEqual([1, null, 8]);

          // Check that the binding is removed.
          _.rootScope.context['v'] = 9;
          _.rootScope.apply();
          expect(logger).toEqual([1, null, 8]);
        });


      });
    });


    describe('controller scoping', () {
      it('should make controllers available to sibling and child controllers', async((Logger log) {
        _.compile('<tab local><pane local></pane><pane local></pane></tab>');
        microLeap();

        expect(log.result()).toEqual('TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0; PaneComponent-2; LocalAttrDirective-0');
      }));

      // TODO(rado): enable when the feature is accepted.
      xit('should break injection at component injectors', async((Logger log) {
        _.compile('<parent><child-tmp-cmp><child></child></child-tmp-cmp></parent>');
        microLeap();
        // The child in the light dom should receive parent,
        // while the child from the template should receive the app level null parent.
        expect(log.result()).toEqual('got parent; null parent');
      }));

      it('should use the correct parent injector', async((Logger log) {
        // Getting the parent offsets correct while descending the template is tricky.  If we get it wrong, this
        // test case will create too many TabComponents.

        _.compile('<div ng-bind="true"><div ignore-children></div><tab local><pane local></pane></tab>');
        microLeap();

        expect(log.result()).toEqual('Ignore; TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0');
      }));

      /*
        This test is dissabled becouse I (misko) thinks it has no real use case. It is easier
        to understand in terms of ng-repeat

          <tabs>
            <!-- ng-repeat -->
            <pane></pane>
          </tabs>

          Should pane be allowed to get a hold of ng-repeat? Right now ng-repeat injector is
          to the side and is not in any of the parents of the pane. Making an injector a
          parent of pane would put the ng-repeat between tabs and pane and it would break
          the DirectChild between tabs and pane.

          It is not clear to me (misko) that there is a use case for getting hold of the
          tranrscluding directive such a ng-repeat.
       */
      xit('should reuse controllers for transclusions', async((Logger log) {
        _.compile('<div simple-transclude-in-attach include-transclude>view</div>');
        microLeap();

        _.rootScope.apply();
        expect(log.result()).toEqual('IncludeTransclude; SimpleTransclude');
      }));

      it('should call scope setter on ScopeAware components', async((TestBed _, Logger log) {
        var element = _.compile('<scope-aware-cmp></scope-aware-cmp>');

        _.rootScope.apply();

        expect(log.result()).toEqual('Scope set');
      }));
    });


    describe('Decorator', () {
      it('should allow multiple directives with the same selector of different type', (DirectiveMap map) {
        _.compile('<div><div same-name="worked"></div></div>');
        _.rootScope.apply();
        SameNameTransclude transclude = _.rootScope.context['sameTransclude'];
        SameNameDecorator decorator = _.rootScope.context['sameDecorator'];

        expect(transclude.valueTransclude).toEqual('worked');
        expect(decorator.valueDecorator).toEqual('worked');
      });
    });

    describe('Injection accross application injection boundaries', () {
      it('should create directive injectors for elements only',
          async((TestBed _, Logger logger, CompilerConfig config) {
        if (!config.elementProbeEnabled) return;
        _.compile('<tab></tab>');
        var directiveInjector = ngInjector(_.rootElement);
        var lazyInjector = NgView.createChildInjectorWithReload(
            _.injector,
            [new Module()..bind(LazyPane)..bind(LazyPaneHelper)]);
        var dirMap = lazyInjector.get(DirectiveMap);
        ViewFactory viewFactory = _.compiler([new Element.tag('lazy-pane')], dirMap);
        var childScope = _.rootScope.createChild({});
        viewFactory(childScope, directiveInjector);
        expect(logger).toContain('LazyPane-0');
      }));
    });
  }));
}

@Component(
    selector: 'tab',
    visibility: Directive.DIRECT_CHILDREN_VISIBILITY)
class TabComponent {
  int id = 0;
  Logger log;
  LocalAttrDirective local;
  TabComponent(Logger this.log, LocalAttrDirective this.local, Scope scope) {
    log('TabComponent-${id++}');
    local.ping();
  }
}

@Component(
  selector: 'lazy-pane',
  visibility: Directive.CHILDREN_VISIBILITY
)
class LazyPane {
  int id = 0;
  LazyPane(Logger logger, LazyPaneHelper lph, Scope scope) {
    logger('LazyPane-${id++}');
  }
}

@Injectable()
class LazyPaneHelper {}

@Component(selector: 'pane')
class PaneComponent {
  TabComponent tabComponent;
  LocalAttrDirective localDirective;
  Logger log;
  PaneComponent(TabComponent this.tabComponent, LocalAttrDirective this.localDirective, Logger this.log, Scope scope) {
    log('PaneComponent-${tabComponent.id++}');
    localDirective.ping();
  }
}

@Decorator(
    selector: '[local]',
    visibility: Directive.LOCAL_VISIBILITY)
class LocalAttrDirective {
  int id = 0;
  Logger log;
  LocalAttrDirective(Logger this.log);
  ping() {
    log('LocalAttrDirective-${id++}');
  }
}

@Decorator(
    selector: 'parent',
    visibility: Directive.CHILDREN_VISIBILITY
)
class Parent {
  Parent(Logger log) {}
}


@Decorator(
    selector: 'child',
    visibility: Directive.CHILDREN_VISIBILITY
)
class Child {
  Child(Parent p, Logger log) {
    log(p == null ? 'null parent' : 'got parent');
  }
}

@Component(
    selector: 'child-tmp-cmp',
    template: '<child></child><content></content>'
)
class ChildTemplateComponent {
  ChildTemplateComponent() {}
}

@Decorator(
    selector: '[simple-transclude-in-attach]',
    visibility: Visibility.LOCAL,
    children: Directive.TRANSCLUDE_CHILDREN)
class SimpleTranscludeInAttachAttrDirective {
  SimpleTranscludeInAttachAttrDirective(ViewPort viewPort, BoundViewFactory boundViewFactory, Logger log, RootScope scope) {
    scope.runAsync(() {
      var view = boundViewFactory(scope);
      viewPort.insert(view);
      log('SimpleTransclude');
    });
  }
}

@Decorator(selector: '[include-transclude]')
class IncludeTranscludeAttrDirective {
  IncludeTranscludeAttrDirective(SimpleTranscludeInAttachAttrDirective simple, Logger log) {
    log('IncludeTransclude');
  }
}

@Decorator(selector: '[two-directives]')
class OneOfTwoDirectives {
  OneOfTwoDirectives(Logger log) {
    log('OneOfTwo');
  }
}

@Decorator(selector: '[two-directives]')
class TwoOfTwoDirectives {
  TwoOfTwoDirectives(Logger log) {
    log('TwoOfTwo');
  }
}

@Decorator(
    selector: '[ignore-children]',
    children: Directive.IGNORE_CHILDREN
)
class IgnoreChildrenDirective {
  IgnoreChildrenDirective(Logger log) {
    log('Ignore');
  }
}

class PublishModuleDirectiveSuperType {
}

@Decorator(
    selector: '[publish-types]',
    module: PublishModuleAttrDirective.module)
class PublishModuleAttrDirective implements PublishModuleDirectiveSuperType {
  static module(i) =>
      i.bind(PublishModuleDirectiveSuperType, toInstanceOf: PublishModuleAttrDirective);

  static DirectiveInjector _injector;
  PublishModuleAttrDirective(DirectiveInjector injector) {
    _injector = injector;
  }
}

@Component(
    selector: 'simple',
    template: r'{{name}}(<content></content>)')
class SimpleComponent {
  Scope scope;
  SimpleComponent(Scope this.scope) {
    scope.context['name'] = 'INNER';
  }
}

@Component(
    selector: 'multiple-content-tags',
    template: r'(<content select=".left"></content>, <content></content>)')
class MultipleContentTagsComponent {
  final Scope scope;
  MultipleContentTagsComponent(this.scope);
}

@Component(
  selector: 'shadowy',
  template: r'With shadow DOM',
  useShadowDom: true
)
class ShadowyComponent {
  ShadowyComponent(Logger log) {
    log('shadowy');
  }
}

@Component(
    selector: 'transcluding',
    template: r'Without shadow DOM',
    useShadowDom: false
)
class TranscludingComponent {
  TranscludingComponent(Logger log) {
    log('transcluding');
  }
}

@Component(
  selector: 'conditional-content',
  template: r'(<div ng-if="showLeft"><content select=".left"></content></div>, <content></content>)')
class ConditionalContentComponent {
  Scope scope;
  ConditionalContentComponent(this.scope);
}

@Component(
    selector: 'io',
    template: r'<content></content>',
    map: const {
        'attr': '@scope.context.attr',
        'expr': '<=>scope.context.expr',
        'oneway': '=>scope.context.oneway',
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

@Component(
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

@Component(
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

@Component(
    selector: 'incorrect-mapping',
    template: r'<content></content>',
    map: const { 'attr': 'foo' })
class IncorrectMappingComponent { }

@Component(
    selector: 'non-assignable-mapping',
    template: r'<content></content>',
    map: const { 'attr': '@1+2' })
class NonAssignableMappingComponent { }

@Component(
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

@Component(
    selector: 'parent-expression',
    template: '<div>inside {{fromParent()}}</div>',
    map: const {
      'from-parent': '&scope.context.fromParent',
    })
class ParentExpressionComponent {
  Scope scope;
  ParentExpressionComponent(Scope this.scope);
}

@Component(
    selector: 'publish-me',
    template: r'{{ctrlName.value}}',
    publishAs: 'ctrlName')
class PublishMeComponent {
  String value = 'WORKED';
}

@Component(
    selector: 'log',
    template: r'<content></content>',
    publishAs: 'ctrlName')
class LogComponent {
  LogComponent(Scope scope, Logger logger) {
    logger(scope);
  }
}

@Component(
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
class AttachDetachComponent implements AttachAware, DetachAware, ShadowRootAware {
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
  onShadowRoot(ShadowRoot shadowRoot) {
    scope.rootScope.context['shadowRoot'] = shadowRoot;
    logger(shadowRoot);
  }
}

@Component()
class MissingSelector {}

@Component(selector: 'buttonbar button')
class InvalidSelector {}

@Formatter(name:'hello')
class SayHelloFormatter {
  call(String str) {
    return 'Hello, $str!';
  }
}

@Component(
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

@Component(
    selector: 'simple-attach',
    templateUrl: 'foo.html')
class SimpleAttachComponent implements AttachAware, ShadowRootAware {
  Logger logger;
  SimpleAttachComponent(this.logger) {
    logger('SimpleAttachComponent');
  }
  attach() => logger('attach');
  onShadowRoot(_) => logger('onShadowRoot');
}

@Decorator(
    selector: 'attach-with-attr'
)
class AttachWithAttr implements AttachAware {
  Logger logger;
  AttachWithAttr(this.logger);
  attach() => logger('attach');
  @NgAttr('attr')
  set attr(v) => logger('attr');
  @NgOneWay('oneway')
  set oneway(v) => logger('oneway');
}

@Component(
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

@Decorator(
    selector: '[one-time]',
    map: const {
      'one-time': '=>!value'
})
class OneTimeDecorator {
  Logger log;
  OneTimeDecorator(this.log);
  set value(v) => log(v);
}

@Decorator(
  selector: '[same-name]',
  children: Directive.TRANSCLUDE_CHILDREN,
  map: const { '.': '@valueTransclude' }
)
class SameNameTransclude {
  var valueTransclude;
  SameNameTransclude(ViewPort port, ViewFactory factory, RootScope scope) {
    port.insertNew(factory);
    scope.context['sameTransclude'] = this;
  }
}

@Decorator(
    selector: '[same-name]',
    map: const { 'same-name': '@valueDecorator' }
)
class SameNameDecorator {
  var valueDecorator;
  SameNameDecorator(RootScope scope) {
    scope.context['sameDecorator'] = this;
  }
}

@Component(
    selector: 'scope-aware-cmp'
)
class ScopeAwareComponent implements ScopeAware {
  Logger log;
  ScopeAwareComponent(this.log) {}
  void set scope(Scope scope) {
    log('Scope set');
  }
}

@Component(
  selector: 'outer-shadowless',
  template: '<inner-shadowy>inner-text</inner-shadowy>',
  useShadowDom: false)
class OuterShadowless {}

@Component(
  selector: 'inner-shadowy',
  template: '<content></content>')
class InnerShadowy {}

@Component(
  selector: 'once-inside',
  template: '<div one-time="ctrl.ot"></div>',
  publishAs: 'ctrl'
)
class OnceInside {
  var ot;

  Logger log;
  @NgAttr("v")
  set v(x) { log(x); ot = "($x)"; }
  OnceInside(Logger this.log) { log('!'); }
}

@Component(
    selector: 'cmp-inj')
class InjectorDependentComponent {
  DirectiveInjector i;
  ComponentDirectiveInjector cdi;
  InjectorDependentComponent(this.i, this.cdi) {
    expect(i).toBeAnInstanceOf(DirectiveInjector);
    expect(cdi).toBeAnInstanceOf(ComponentDirectiveInjector);
    expect(cdi.parent).toBe(i);
  }
}


@Component(
    selector: 'outer-with-div',
    template: 'OUTER(<simple><div><content select=".left"></content></div></simple>)'
)
class OuterWithDivComponent {
  final Scope scope;
  OuterWithDivComponent(this.scope);
}

@Component(
    selector: 'outer',
    template: 'OUTER(<inner><content></content></inner>)'
)
class OuterComponent {
  final Scope scope;
  OuterComponent(this.scope);
}

@Component(
    selector: 'inner',
    template: 'INNER(<innerinner><content></content></innerinner>)'
)
class InnerComponent {
  final Scope scope;
  InnerComponent(this.scope);
}

@Component(
    selector: 'innerinner',
    template: 'INNERINNER(<content select=".left"></content>,<content select=".right"></content>)'
)
class InnerInnerComponent {
  InnerInnerComponent() {}
}

@Component(
    selector: 'template-url-component',
    templateUrl: 'template.html'
)
class TemplateUrlComponent {
}

_shadowScope(element){
  if (element.shadowRoot != null) {
    return ngProbe(element.shadowRoot).scope;
  } else {
    return ngProbe(element).directives[0].scope;
  }
}
