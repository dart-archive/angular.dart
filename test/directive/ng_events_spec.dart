library ng_events_spec;

import '../_specs.dart';
import 'dart:html' as dom;

void addTest(String name, [String eventType='MouseEvent', String eventName, exclusive=false]) {
  if (eventName == null) {
    eventName = name;
  }

  var describeBody = () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should evaluate the expression on $name', () {
      _.compile('<button ng-$name="abc = true; event = \$event"></button>');
      _.triggerEvent(_.rootElement, eventName, eventType);
      expect(_.rootScope.context['abc']).toEqual(true);
      expect(_.rootScope.context['event'] is dom.UIEvent).toEqual(true);
    });
  };

  if (exclusive) {
    ddescribe('ng-$name', describeBody);
  } else {
    describe('ng-$name', describeBody);
  }
}

void aaddTest(String name, [String eventType='MouseEvent', String eventName]) {
  addTest(name, eventType, eventName, true);
}

main() {
    addTest('abort');
    addTest('beforecopy');
    addTest('beforecopy');
    addTest('beforecut');
    addTest('beforepaste');
    addTest('blur');
    addTest('change');
    addTest('click');
    addTest('contextmenu');
    addTest('copy');
    addTest('cut');
    // The event name differs from the ng- directive name.
    addTest('doubleclick', 'MouseEvent', 'dblclick');
    addTest('drag');
    addTest('dragend');
    addTest('dragenter');
    addTest('dragleave');
    addTest('dragover');
    addTest('dragstart');
    addTest('drop');
    addTest('error');
    addTest('focus');
    //addTest('fullscreenchange');
    //addTest('fullscreenerror');
    addTest('input');
    addTest('invalid');
    addTest('keydown', 'KeyboardEvent');
    addTest('keypress', 'KeyboardEvent');
    addTest('keyup', 'KeyboardEvent');
    addTest('load');
    addTest('mousedown');
    addTest('mouseenter');
    addTest('mouseleave');
    addTest('mousemove');
    addTest('mouseout');
    addTest('mouseover');
    addTest('mouseup');
    addTest('mousewheel', 'MouseEvent', 'wheel');
    addTest('paste');
    addTest('reset');
    addTest('scroll');
    addTest('search');
    addTest('select');
    addTest('selectstart');
    //addTest('speechchange');
    addTest('submit');
    // These should be of type TouchEvent but that causes the tests to fail.
    // They pass as a MouseEvent.
    //addTest('touchcancel'/*, 'TouchEvent'*/);
    addTest('touchenter'/*, 'TouchEvent'*/);
    addTest('touchleave'/*, 'TouchEvent'*/);
    addTest('touchend'/*, 'TouchEvent'*/);
    addTest('touchmove'/*, 'TouchEvent'*/);
    addTest('touchstart'/*, 'TouchEvent'*/);
    // Disabled due to http://dartbug.com/17990
    //addTest('transitionend');
}
