library ng_a_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() {
  isBrowser(String pattern) => window.navigator.userAgent.contains(pattern);

  describe('ADirective', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);
    
    compile(html) {
      _.compile(html);
      _.injector.get(Element).append(_.rootElement);
    }

    it('should bind click listener when href zero length string', (Scope scope) {
      compile('<a href="" on-click="abc = 4; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(4);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
    });

    it('should bind click listener when href empty', (Scope scope) {
      compile('<a href on-click="abc = 5; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(5);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
    });

    it('should not bind click listener to non empty href', (Scope scope) {
      // NOTE(deboer): In Firefox, after the dispatchEvent, the location.href
      // value does not update synchronously.  I do not know how to test this.
      if (isBrowser('Firefox')) return;

      window.location.href = '#something';
      compile('<a href="#"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(window.location.href.endsWith("#")).toEqual(true);
    });

    it('should not cancel click with non-empty interpolated href', (Scope scope) {
      // NOTE(deboer): In Firefox, after the dispatchEvent, the location.href
      // value does not update synchronously.  I do not know how to test this.
      if (isBrowser('Firefox')) return;

      compile('<a href="{{url}}" on-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(true);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
      window.location.href = '#';
      _.rootScope.context['url'] = '#url';
      _.rootScope.apply();
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(window.location.href.endsWith("#url")).toEqual(true);
    });
  });
}
