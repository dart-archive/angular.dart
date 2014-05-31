library compiler_spec;

import '../_specs.dart';


forBothCompilers(fn) {
  describe('walking compiler', () {
    beforeEachModule((Module m) {
      m.bind(Compiler, toImplementation: WalkingCompiler);
      return m;
    });
    fn();
  });

  describe('tagging compiler', () {
    beforeEachModule((Module m) {
      m.bind(Compiler, toImplementation: TaggingCompiler);
      return m;
    });
    fn();
  });
}

forAllCompilersAndComponentFactories(fn) {
  forBothCompilers(fn);

  describe('transcluding components', () {
    beforeEachModule((Module m) {
      m.bind(Compiler, toImplementation: TaggingCompiler);
      m.bind(ComponentFactory, toImplementation: TranscludingComponentFactory);

      return m;
    });
    fn();
  });
}

void main() {
  forBothCompilers(() =>
  describe('TranscludingComponentFactory', () {
    TestBed _;

    beforeEachModule((Module m) {
      return m
          ..bind(ComponentFactory, toImplementation: TranscludingComponentFactory)
          ..bind(SimpleComponent);
    });

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should correctly detach transcluded content when scope destroyed', async(() {
      var scope = _.rootScope.createChild({});
      var element = _.compile(r'<div><simple><span ng-if="true == true">trans</span></simple></div>', scope: scope);
      microLeap();
      _.rootScope.apply();
      expect(element).toHaveText('INNER(trans)');
      scope.destroy();
      expect(element).toHaveText('INNER()');
    }));
  }));

  forAllCompilersAndComponentFactories(() =>
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
          ..bind(MyController)
          ..bind(MyParentController)
          ..bind(MyChildController);
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

      it('should work with attrs, one-way, two-way and callbacks', async(() {
         _.compile('<div><io bind-attr="\'A\'" bind-expr="name" bind-ondone="done=true"></io></div>');

        _.rootScope.context['name'] = 'misko';
        microLeap();
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
          ..bind(PublishMeDirective)
          ..bind(LogComponent)
          ..bind(AttachDetachComponent)
          ..bind(SimpleAttachComponent)
          ..bind(SimpleComponent)
          ..bind(SometimesComponent)
          ..bind(ExprAttrComponent)
          ..bind(LogElementComponent)
          ..bind(SayHelloFormatter)
          ..bind(OneTimeDecorator);
      });

      it('should select on element', async(() {
        var element = _.compile(r'<div><simple></simple></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('INNER()');
      }));

      it('should tranclude correctly', async(() {
        var element = _.compile(r'<div><simple>trans</simple></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('INNER(trans)');
      }));

      it('should tranclude if content was not present initially', async(() {
        var element = _.compile(r'<div>And <sometimes sometimes=sometimes>jump</sometimes></div>');
        document.body.append(element);
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('And ');

        _.rootScope.context['sometimes'] = true;
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('And jump');
      }));

      it('should redistribute content when the content tag disappears', async(() {
        var element = _.compile(r'<div>And <sometimes sometimes=sometimes>jump</sometimes></div>');
        document.body.append(element);

        _.rootScope.context['sometimes'] = true;
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('And jump');

        _.rootScope.context['sometimes'] = false;
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('And ');

        _.rootScope.context['sometimes'] = true;
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('And jump');
      }));

      it('should safely remove transcluding components that transclude no content', async(() {
        _.rootScope.context['flag'] = true;
        _.compile('<div ng-if=flag><simple></simple></div>');
        microLeap(); _.rootScope.apply();
        _.rootScope.context['flag'] = false;
        microLeap(); _.rootScope.apply();
      }));

      it('should store ElementProbe with Elements', async(() {
        _.compile('<div><simple>innerText</simple></div>');
        microLeap();
        _.rootScope.apply();
        var simpleElement = _.rootElement.querySelector('simple');
        expect(simpleElement).toHaveText('INNER(innerText)');
        var simpleProbe = ngProbe(simpleElement);
        var simpleComponent = simpleProbe.injector.get(SimpleComponent);
        expect(simpleComponent.scope.context['name']).toEqual('INNER');
        var shadowRoot = simpleElement.shadowRoot;

        // If there is no shadow root, skip this.
        if (shadowRoot != null) {
          var shadowProbe = ngProbe(shadowRoot);
          expect(shadowProbe).toBeNotNull();
          expect(shadowProbe.element).toEqual(shadowRoot);
          expect(shadowProbe.parent.element).toEqual(simpleElement);
        }
      }));

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

      it('should publish component controller into the scope', async(() {
        var element = _.compile(r'<div><publish-me></publish-me></div>');
        microLeap();
        _.rootScope.apply();
        expect(element).toHaveText('WORKED');
      }));

      it('should publish directive controller into the scope', async((VmTurnZone zone) {
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

      it('should expose PublishModuleDirectiveSuperType as PublishModuleDirectiveSuperType', () {
        _.compile(r'<div publish-types probe="publishModuleProbe"></div>');
        var probe = _.rootScope.context['publishModuleProbe'];
        var directive = probe.injector.get(PublishModuleDirectiveSuperType);
        expect(directive is PublishModuleAttrDirective).toBeTruthy();
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
            ..bind(HttpBackend, toValue: httpBackend)
            ..bind(MockHttpBackend, toValue: httpBackend);
        });

        it('should fire onShadowRoot method', async((Compiler compile, Logger logger, MockHttpBackend backend) {
          backend.whenGET('some/template.url').respond(200, '<div>WORKED</div>');
          var scope = _.rootScope.createChild({});
          scope.context['isReady'] = 'ready';
          scope.context['logger'] = logger;
          scope.context['once'] = null;
          var elts = es('<attach-detach attr-value="{{isReady}}" expr-value="isReady" once-value="once">{{logger("inner")}}</attach-detach>');
          compile(elts, _.injector.get(DirectiveMap))(_.injector.createChild([new Module()..bind(Scope, toValue: scope)]), elts);
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

          microLeap();
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
          compile(elts, _.injector.get(DirectiveMap))(_.injector.createChild([new Module()..bind(Scope, toValue: scope)]), elts);
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
          backend.whenGET('foo.html').respond('<div>WORKED</div>');
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
              ..bind(MissingSelector);
          var injector = _.injector.createChild([module], forceNewInstances: [Compiler, DirectiveMap]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);
          expect(() {
              c(es('<div></div>'), injector.get(DirectiveMap));
          }).toThrow('Missing selector annotation for MissingSelector');
        });


        it('should throw a useful error message for invalid selector', () {
          Module module = new Module()
            ..bind(InvalidSelector);
          var injector = _.injector.createChild([module], forceNewInstances: [Compiler, DirectiveMap]);
          var c = injector.get(Compiler);
          var directives = injector.get(DirectiveMap);

          expect(() {
            c(es('<div></div>'), directives);
          }).toThrow('Unknown selector format \'buttonbar button\' for InvalidSelector');
        });
      });

      describe('useShadowDom option', () {
        beforeEachModule((Module m) {
          m.bind(ShadowyComponent);
          m.bind(ShadowlessComponent);
        });

        it('should create shadowy components', async((Logger log) {
          _.compile('<shadowy></shadowy>');
          expect(log).toEqual(['shadowy']);
          expect(_.rootElement.shadowRoot).toBeNotNull();
        }));

        it('should create shadowless components', async((Logger log) {
          _.compile('<shadowless></shadowless>');
          expect(log).toEqual(['shadowless']);
          expect(_.rootElement.shadowRoot).toBeNull();
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
          Expando expando;

          beforeEach(inject((Expando _expando) => expando = _expando));

          ['shadowy', 'shadowless'].forEach((selector) {
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

      it('should use the correct parent injector', async((Logger log) {
        // Getting the parent offsets correct while descending the template is tricky.  If we get it wrong, this
        // test case will create too many TabComponents.

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


    describe('Decorator', () {
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


@Controller(
  selector: '[my-parent-controller]',
  publishAs: 'my_parent')
class MyParentController {
  data() {
    return "my data";
  }
}

@Controller(
  selector: '[my-child-controller]',
  publishAs: 'my_child')
class MyChildController {}

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
    selector: '[simple-transclude-in-attach]',
    visibility: Directive.CHILDREN_VISIBILITY, children: Directive.TRANSCLUDE_CHILDREN)
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
  static Module _module = new Module()
      ..bind(PublishModuleDirectiveSuperType, toFactory: (i) => i.get(PublishModuleAttrDirective));
  static module() => _module;

  static Injector _injector;
  PublishModuleAttrDirective(Injector injector) {
    _injector = injector;
  }
}

@Component(
    selector: 'simple',
    template: r'{{name}}(<content>SHADOW-CONTENT</content>)')
class SimpleComponent {
  Scope scope;
  SimpleComponent(Scope this.scope) {
    scope.context['name'] = 'INNER';
  }
}

@Component(
    selector: 'simple2',
    template: r'{{name}}(<content>SHADOW-CONTENT</content>)')
class Simple2Component {
  Scope scope;
  Simple2Component(Scope this.scope) {
    scope.context['name'] = 'INNER';
  }
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
    selector: 'shadowless',
    template: r'Without shadow DOM',
    useShadowDom: false
)
class ShadowlessComponent {
  ShadowlessComponent(Logger log) {
    log('shadowless');
  }
}

@Component(
  selector: 'sometimes',
  template: r'<div ng-if="ctrl.sometimes"><content></content></div>',
  publishAs: 'ctrl')
class SometimesComponent {
  @NgTwoWay('sometimes')
  var sometimes;
}

@Component(
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

@Controller (
    selector: '[publish-me]',
    publishAs: 'ctrlName')
class PublishMeDirective {
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
  onShadowRoot(shadowRoot) {
    scope.rootScope.context['shadowRoot'] = shadowRoot;
    logger(shadowRoot);
  }
}

@Controller(
    selector: '[my-controller]',
    publishAs: 'myCtrl')
class MyController {
  MyController(Scope scope) {
    scope.context['name'] = 'MyController';
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
