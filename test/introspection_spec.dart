library introspection_spec;

import '_specs.dart';
import 'dart:js' as js;
import 'package:angular/angular_dynamic.dart';

void main() {
  describe('introspection', () {
    it('should retrieve ElementProbe', (TestBed _) {
      _.compile('<div ng-bind="true"></div>');
      ElementProbe probe = ngProbe(_.rootElement);
      expect(probe.injector.parent).toBe(_.injector);
      expect(ngInjector(_.rootElement).parent).toBe(_.injector);
      expect(probe.directives[0] is NgBindDirective).toBe(true);
      expect(ngDirectives(_.rootElement)[0] is NgBindDirective).toBe(true);
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

    it('should select elements in the root shadow root', () {
      var div = new Element.html('<div></div>');
      var shadowRoot = div.createShadowRoot();
      shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';
      expect(toHtml(ngQuery(div, 'li'))).toEqual('<li>stash</li><li>secret</li>');
    });

    // Does not work in dart2js.  deboer is investigating.
    it('should be available from Javascript', () {
      // The probe only works if there is a directive.
      var elt = $('<div ng-app id=ngtop ng-bind="\'introspection FTW\'"></div>')[0];
      // Make it possible to find the element from JS
      document.body.append(elt);
      (ngDynamicApp()..element = elt).run();

      expect(js.context['ngProbe']).toBeDefined();
      expect(js.context['ngScope']).toBeDefined();
      expect(js.context['ngInjector']).toBeDefined();
      expect(js.context['ngQuery']).toBeDefined();

      expect(js.context['ngProbe'].apply([js.context['ngtop']])).toBeDefined();
    });
  });
}
