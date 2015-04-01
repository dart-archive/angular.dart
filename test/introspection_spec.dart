library introspection_spec;

import '_specs.dart';
import 'dart:js' as js;
import 'package:angular/application_factory.dart';
import 'dart:html';

void main() {
  describe('introspection', () {
    describe('ngQuery', () {
      toHtml(List list) => list.map((e) => e.outerHtml).join('');

      it('should select elements using CSS selector', () {
        var div = new Element.html('<div><p><span></span></p></div>');
        var span = div.querySelector('span');
        var shadowRoot = span.createShadowRoot();
        shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';

        expect(toHtml(ngQuery(div, 'li')))
            .toEqual('<li>stash</li><li>secret</li>');
        expect(toHtml(ngQuery(div, 'li', 'stash'))).toEqual('<li>stash</li>');
        expect(toHtml(ngQuery(div, 'li', 'secret'))).toEqual('<li>secret</li>');
        expect(toHtml(ngQuery(div, 'li', 'xxx'))).toEqual('');
      });

      it('should select elements in the root shadow root', () {
        var div = new Element.html('<div></div>');
        var shadowRoot = div.createShadowRoot();
        shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';
        expect(toHtml(ngQuery(div, 'li')))
            .toEqual('<li>stash</li><li>secret</li>');
      });
    });

    describe('ngProbe', () {
      it('should retrieve ElementProbe', (TestBed _) {
        _.compile('<div ng-bind="foo"></div>');

        ElementProbe probe = ngProbe(_.rootElement);

        expect(probe.injector.get(Injector)).toBe(_.injector);
        expect(ngInjector(_.rootElement).get(Injector)).toBe(_.injector);
        expect(probe.directives[0] is NgBind).toBe(true);
        expect(ngDirectives(_.rootElement)[0] is NgBind).toBe(true);
        expect(probe.scope).toBe(_.rootScope);
        expect(ngScope(_.rootElement)).toBe(_.rootScope);
        expect(probe.bindingExpressions).toEqual(['foo']);
      });

      it('should select probe using CSS selector', (TestBed _) {
        _.compile('<div ng-show="true">WORKS</div>');
        document.body.append(_.rootElement);

        ElementProbe probe = ngProbe('[ng-show]');

        expect(probe).toBeDefined();
        expect(probe.injector.get(NgShow) is NgShow).toEqual(true);
        _.rootElement.remove();
      });

      it('should return the correct binding expression for mustache interpolation',
          (TestBed _) {
        _.compile('<div my-attr="{{foobar}}"></div>');

        ElementProbe probe = ngProbe(_.rootElement);

        expect(probe.injector.get(Injector)).toBe(_.injector);

        expect(ngInjector(_.rootElement).get(Injector)).toBe(_.injector);
        expect(probe.bindingExpressions).toEqual(['foobar']);
      });

      it('should return the correct binding expressions for repeated bindings',
          (TestBed _) {
        _.compile('<div my-attr="{{foo}} then {{bar}}"></div>');

        ElementProbe probe = ngProbe(_.rootElement);

        expect(probe.injector.get(Injector)).toBe(_.injector);

        expect(ngInjector(_.rootElement).get(Injector)).toBe(_.injector);
        expect(probe.bindingExpressions).toEqual(['foo', 'bar']);
      });
    });

    describe('getTestability', () {
      for (bool elementProbeEnabled in [false, true]) {
        describe('elementProbeEnabled=$elementProbeEnabled', () {
          var elt;

          beforeEachModule((Module m) {
            m.bind(CompilerConfig,
                toValue: new CompilerConfig.withOptions(
                    elementProbeEnabled: elementProbeEnabled));
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
              expect(() => getTestability(elt)).toThrowWith(
                  message: "Could not find an ElementProbe for div.  This might happen "
                  "either because there is no Angular directive for that node OR "
                  "because your application is running with ElementProbes "
                  "disabled (CompilerConfig.elementProbeEnabled = false).");
            });
          }
        });
      }
    });

    describe('JavaScript testability', () {
      var elt, angular, ngtop, testability;

      beforeEach(() {
        elt = e('''<div ng-app id="ngtop">
                     <div id="a" ng-bind="\'introspection FTW\'"></div>
                     <div id="b" my-attr="{{attrMustache}}"></div>
                     <div id="c">{{textMustache}}</div>
                     <div id="d">hi {{repeat}} this is {{repeat}}</div>
                     <div id="e">{{first}} then {{second}}</div>
                     <input id="1" ng-model="myModel"/>
                  </div>''');
        // Make it possible to find the element from JS
        document.body.append(elt);
        (applicationFactory()..element = elt).run();
        angular = js.context['angular'];
        // Polymer does not support accessing named elements directly (e.g. window.ngtop)
        // so we need to use getElementById to support Polymer's shadow DOM polyfill.
        ngtop = document.getElementById('ngtop');
        testability = angular['getTestability'].apply([ngtop]);
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

        expect(js.context['ngProbe'].apply([document.getElementById('a')]))
            .toBeDefined();

        expect(testability).toBeDefined();
      });

      it('should expose allowAnimations', () {
        allowAnimations(allowed) =>
            testability['allowAnimations'].apply([allowed]);
        expect(allowAnimations(false)).toEqual(true);
        expect(allowAnimations(false)).toEqual(false);
        expect(allowAnimations(true)).toEqual(false);
        expect(allowAnimations(true)).toEqual(true);
      });

      describe('bindings', () {
        it('should find bindings', () {
          // exactMatch should fail.
          var bindingNodes =
              testability['findBindings'].apply(['introspection', true]);
          expect(bindingNodes.length).toEqual(0);

          // substring search (default) should succeed.
          // exactMatch should default to false.
          bindingNodes = testability['findBindings'].apply(['introspection']);
          expect(bindingNodes.length).toEqual(1);
          bindingNodes =
              testability['findBindings'].apply(['introspection', false]);
          expect(bindingNodes.length).toEqual(1);

          // and so should exact search with the correct query.
          bindingNodes =
              testability['findBindings'].apply(["'introspection FTW'", true]);
          expect(bindingNodes.length).toEqual(1);
        });

        it('should find ng-bind bindings', () {
          var bindingElems =
              testability['findBindings'].apply(['introspection FTW']);
          expect(bindingElems.length).toEqual(1);
          expect(bindingElems[0]).toEqual(document.getElementById('a'));
        });

        it('should find attribute mustache bindings', () {
          var bindingElems =
              testability['findBindings'].apply(['attrMustache']);
          expect(bindingElems.length).toEqual(1);
          expect(bindingElems[0]).toEqual(document.getElementById('b'));
        });

        it('should find text mustache bindings', () {
          var bindingElems =
              testability['findBindings'].apply(['textMustache']);
          expect(bindingElems.length).toEqual(1);
          expect(bindingElems[0]).toEqual(document.getElementById('c'));
        });

        it('should find exact mustache bindings', () {
          var bindingAttrElems =
              testability['findBindings'].apply(['attrMustache', true]);
          expect(bindingAttrElems.length).toEqual(1);

          var bindingTextElems =
              testability['findBindings'].apply(['textMustache', true]);
          expect(bindingTextElems.length).toEqual(1);
        });

        it('should find repeated bindings and return only one element', () {
          var bindingElems = testability['findBindings'].apply(['repeat']);
          expect(bindingElems.length).toEqual(1);
          expect(bindingElems[0]).toEqual(document.getElementById('d'));
        });

        it('should find elements with more than one binding by either', () {
          var firstBindingElems = testability['findBindings'].apply(['first']);
          var secondBindingElems =
              testability['findBindings'].apply(['second']);
          expect(firstBindingElems.length).toEqual(1);
          expect(secondBindingElems.length).toEqual(1);
          expect(firstBindingElems[0]).toEqual(secondBindingElems[0]);
        });

        it('should return nodes instead of elements if requested', () {
          var bindingNodes =
              testability['findBindings'].apply(['textMustache', false, true]);
          expect(bindingNodes.length).toEqual(1);
          expect(bindingNodes[0])
              .toEqual(document.getElementById('c').firstChild);
        });
      });

      it('should find models', () {
        // exactMatch should fail.
        var modelNodes = testability['findModels'].apply(['my', true]);
        expect(modelNodes.length).toEqual(0);

        // substring search (default) should succeed.
        modelNodes = testability['findModels'].apply(['my']);
        expect(modelNodes.length).toEqual(1);
        expect(modelNodes[0]).toEqual(document.getElementById('1'));
      });
    });
  });
}
