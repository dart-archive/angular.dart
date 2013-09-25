library ng_a_spec;

import '../_specs.dart';
import '../_test_bed.dart';
import 'dart:html' as dom;

main() {
  describe('ADirective', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should bind click listener when href zero length string', inject((Scope scope) {
      _.compile('<a href="" ng-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope['abc']).toEqual(true);
      expect(_.rootScope['event'] is dom.UIEvent).toEqual(true);
    }));

    it('should bind click listener when href empty', inject((Scope scope) {
      _.compile('<a href ng-click="abc = true; event = \$event"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(_.rootScope['abc']).toEqual(true);
      expect(_.rootScope['event'] is dom.UIEvent).toEqual(true);
    }));

    it('should not bind click listener to non empty href', inject((Scope scope) {
      _.compile('<a href="#"></a>');
      _.triggerEvent(_.rootElement, 'click', 'MouseEvent');
      expect(window.location.href.endsWith("#")).toEqual(true);
    }));
  });
}
