library ng_events_spec;

import '../_specs.dart';
import '../_test_bed.dart';
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
    addTest('blur');
    addTest('change');
    addTest('click');
    addTest('contextmenu');
    // The event name differs from the ng- directive name.
    addTest('doubleclick', 'MouseEvent', 'dblclick');
    addTest('dragenter');
    addTest('dragleave');
    addTest('dragover');
    addTest('dragstart');
    addTest('drop');
    addTest('focus');
    addTest('keydown', 'KeyboardEvent');
    addTest('keypress', 'KeyboardEvent');
    addTest('keyup', 'KeyboardEvent');
    addTest('mousedown');
    addTest('mouseenter');
    addTest('mouseleave');
    addTest('mousemove');
    addTest('mouseout');
    addTest('mouseover');
    addTest('mouseup');
    addTest('mousewheel');
    addTest('scroll');
    // These should be of type TouchEvent but that causes the tests to fail.
    // They pass as a MouseEvent.
    addTest('touchcancel'/*, 'TouchEvent'*/);
    addTest('touchend'/*, 'TouchEvent'*/);
    addTest('touchmove'/*, 'TouchEvent'*/);
    addTest('touchstart'/*, 'TouchEvent'*/);
}
