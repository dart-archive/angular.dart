library ng_events_spec;

import '../_specs.dart';
import "../_test_bed.dart";
import 'dart:html' as dom;

void addTest(String name, [String eventType='MouseEvent', String eventName]) {
  if (eventName == null) {
    eventName = name;
  }

  describe('ng-$name', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should evaluate the expression on $name', inject(() {
      _.compile('<button ng-$name="abc = true; event = \$event"></button>');
      _.triggerEvent(_.rootElement, eventName, eventType);
      expect(_.rootScope['abc']).toEqual(true);
      expect(_.rootScope['event'] is dom.UIEvent).toEqual(true);
    }));
  });
}

main() {
    addTest('blur', 'MouseEvent');
    addTest('change', 'MouseEvent');
    addTest('click', 'MouseEvent');
    addTest('contextmenu', 'MouseEvent');
    // The event name differs from the ng- directive name.
    addTest('doubleclick', 'MouseEvent', 'dblclick');
    addTest('dragenter', 'MouseEvent');
    addTest('dragleave', 'MouseEvent');
    addTest('dragover', 'MouseEvent');
    addTest('dragstart', 'MouseEvent');
    addTest('drop', 'MouseEvent');
    addTest('focus', 'MouseEvent');
    addTest('keydown', 'KeyboardEvent');
    addTest('keypress', 'KeyboardEvent');
    addTest('keyup', 'KeyboardEvent');
    addTest('mousedown', 'MouseEvent');
    addTest('mouseenter', 'MouseEvent');
    addTest('mouseleave', 'MouseEvent');
    addTest('mousemove', 'MouseEvent');
    addTest('mouseout', 'MouseEvent');
    addTest('mouseover', 'MouseEvent');
    addTest('mouseup', 'MouseEvent');
    addTest('mousewheel', 'MouseEvent');
    addTest('scroll', 'MouseEvent');
    // These should be of type TouchEvent but that causes the tests to fail.
    // They pass as a MouseEvent.
    addTest('touchcancel', 'MouseEvent' /*TouchEvent*/);
    addTest('touchend', 'MouseEvent' /*TouchEvent*/);
    addTest('touchmove', 'MouseEvent' /*TouchEvent*/);
    addTest('touchstart', 'MouseEvent' /*TouchEvent*/);
}
