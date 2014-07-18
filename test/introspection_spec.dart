library introspection_spec;

import '_specs.dart';
import 'dart:js' as js;
import 'package:angular/application_factory.dart';
import 'dart:html';

void main() {
  describe('introspection', () {
    it('should retrieve ElementProbe', (TestBed _) {
      _.compile('<div ng-bind="true"></div>');
      ElementProbe probe = ngProbe(_.rootElement);
      expect(probe.injector.get(Injector)).toBe(_.injector);
      expect(ngInjector(_.rootElement).get(Injector)).toBe(_.injector);
      expect(probe.directives[0] is NgBind).toBe(true);
      expect(ngDirectives(_.rootElement)[0] is NgBind).toBe(true);
      expect(probe.scope).toBe(_.rootScope);
      expect(ngScope(_.rootElement)).toBe(_.rootScope);
    });

    toHtml(List list) => list.map((e) => e.outerHtml).join('');

    it('should select elements using CSS selector', () {
      var div = new Element.html('<div><p><span></span></p></div>');
      var span = div.querySelector('span');
      var shadowRoot = span.createShadowRoot();
      shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';

      expect(toHtml(ngQuery(div, 'li'))).toEqual('<li>stash</li><li>secret</li>');
      expect(toHtml(ngQuery(div, 'li', 'stash'))).toEqual('<li>stash</li>');
      expect(toHtml(ngQuery(div, 'li', 'secret'))).toEqual('<li>secret</li>');
      expect(toHtml(ngQuery(div, 'li', 'xxx'))).toEqual('');
    });

    it('should select probe using CSS selector', (TestBed _) {
      _.compile('<div ng-show="true">WORKS</div>');
      document.body.append(_.rootElement);
      var div = new Element.html('<div><p><span></span></p></div>');
      var span = div.querySelector('span');
      var shadowRoot = span.createShadowRoot();
      shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';

      ElementProbe probe = ngProbe('[ng-show]');
      expect(probe).toBeDefined();
      expect(probe.injector.get(NgShow) is NgShow).toEqual(true);
      _.rootElement.remove();
    });

    it('should select elements in the root shadow root', () {
      var div = new Element.html('<div></div>');
      var shadowRoot = div.createShadowRoot();
      shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';
      expect(toHtml(ngQuery(div, 'li'))).toEqual('<li>stash</li><li>secret</li>');
    });

    describe('getTestability', () {
      for (bool elementProbeEnabled in [false, true]) {
        describe('elementProbeEnabled=$elementProbeEnabled', () {
          var elt;

          beforeEachModule((Module m) {
            m.bind(CompilerConfig, toValue:
                new CompilerConfig.withOptions(elementProbeEnabled: elementProbeEnabled));
          });

          beforeEach((TestBed _) {
            elt = _.compile('<div ng-bind="0"></div>');
            document.body.append(elt);
          });

          afterEach(() {
            elt.remove();
          });

          if (elementProbeEnabled) {
            it('should return a Testability object', () {
              expect(getTestability(elt)).toBeDefined();
            });
          } else {
            it('should throw an exception', () {
              expect(() => getTestability(elt)).toThrow(
                  "Could not find an ElementProbe for div.  This might happen "
                  "either because there is no Angular directive for that node OR "
                  "because your application is running with ElementProbes "
                  "disabled (CompilerConfig.elementProbeEnabled = false).");
            });
          }
        });
      }
    });

    describe('JavaScript bindings', () {
      var elt, angular, ngtop;

      beforeEach(() {
        elt = e('<div ng-app id="ngtop" ng-model="myModel">'
                    '<div ng-bind="\'introspection FTW\'"></div>'
                    '<div my-attr="{{attrMustache}}"></div>'
                    '<div>{{textMustache}}</div>'
                '</div>');
        // Make it possible to find the element from JS
        document.body.append(elt);
        (applicationFactory()..element = elt).run();
        angular = js.context['angular'];
        // Polymer does not support accessing named elements directly (e.g. window.ngtop)
        // so we need to use getElementById to support Polymer's shadow DOM polyfill.
        ngtop = document.getElementById('ngtop');
      });

      afterEach(() {
        elt.remove();
        elt = angular = ngtop = null;
      });

      // Does not work in dart2js.  deboer is investigating.
      it('should be available from Javascript', () {
        expect(js.context['ngProbe']).toBeDefined();
        expect(js.context['ngInjector']).toBeDefined();
        expect(js.context['ngScope']).toBeDefined();
        expect(js.context['ngQuery']).toBeDefined();
        expect(angular).toBeDefined();
        expect(angular['resumeBootstrap']).toBeDefined();
        expect(angular['getTestability']).toBeDefined();

        expect(js.context['ngProbe'].apply([ngtop])).toBeDefined();
      });

      // Issue #1219
      if (identical(1, 1.0) || !js.context['DART_VERSION'].toString().contains("version: 1.5.")) {
        describe(r'testability', () {

          var testability;

          beforeEach(() {
            testability = angular['getTestability'].apply([ngtop]);
          });

          it('should be available from Javascript', () {
            expect(testability).toBeDefined();
          });

          it('should expose allowAnimations', () {
            allowAnimations(allowed) => testability['allowAnimations'].apply([allowed]);
            expect(allowAnimations(false)).toEqual(true);
            expect(allowAnimations(false)).toEqual(false);
            expect(allowAnimations(true)).toEqual(false);
            expect(allowAnimations(true)).toEqual(true);
          });

          describe('bindings', () {
            it('should find exact bindings', () {
              // exactMatch should fail.
              var bindingNodes = testability['findBindings'].apply(['introspection', true]);
              expect(bindingNodes.length).toEqual(0);

              // substring search (default) should succeed.
              // exactMatch should default to false.
              bindingNodes = testability['findBindings'].apply(['introspection']);
              expect(bindingNodes.length).toEqual(1);
              bindingNodes = testability['findBindings'].apply(['introspection', false]);
              expect(bindingNodes.length).toEqual(1);

              // and so should exact search with the correct query.
              bindingNodes = testability['findBindings'].apply(["'introspection FTW'", true]);
              expect(bindingNodes.length).toEqual(1);
            });

            _assertBinding(String query) {
              var bindingNodes = testability['findBindings'].apply([query]);
              expect(bindingNodes.length).toEqual(1);
              var node = bindingNodes[0];
              var probe = js.context['ngProbe'].apply([node]);
              expect(probe).toBeDefined();
              var bindings = probe['bindings'];
              expect(bindings['length']).toEqual(1);
              expect(bindings[0].contains(query)).toBe(true);
            }

            it('should find ng-bind bindings', () => _assertBinding('introspection FTW'));
            it('should find attribute mustache bindings', () => _assertBinding('attrMustache'));
            it('should find text mustache bindings', () => _assertBinding('textMustache'));
          });

          it('should find models', () {
            // exactMatch should fail.
            var modelNodes = testability['findModels'].apply(['my', true]);
            expect(modelNodes.length).toEqual(0);

            // substring search (default) should succeed.
            modelNodes = testability['findModels'].apply(['my']);
            expect(modelNodes.length).toEqual(1);
            var divElement = modelNodes[0];
            expect(divElement is DivElement).toEqual(true);
            var probe = js.context['ngProbe'].apply([divElement]);
            expect(probe).toBeDefined();
            var models = probe['models'];
            expect(models['length']).toEqual(1);
            expect(models[0]).toEqual('myModel');
          });
        });
      }
    });
  });
}
