library ng_a_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() {
  describe('ADirective', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should bind click listener when href zero length string', inject((Scope scope) {
      _.compile('<a href="" ng-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(true);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
    }));

    it('should bind click listener when href empty', inject((Scope scope) {
      _.compile('<a href ng-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(true);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
    }));

    it('should not bind click listener to non empty href', inject((Scope scope) {
      window.location.href = '#something';
      _.compile('<a href="#"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(window.location.href.endsWith("#")).toEqual(true);
    }));

    it('should not cancel click with non-empty interpolated href', inject((Scope scope) {
      _.compile('<a href="{{url}}" ng-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope.context['abc']).toEqual(true);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
      window.location.href = '#';
      _.rootScope.context['url'] = '#url';
      _.rootScope.apply();
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(window.location.href.endsWith("#url")).toEqual(true);
    }));
  });
}
