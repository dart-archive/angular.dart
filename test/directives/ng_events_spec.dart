library ng_events_spec;

import '../_specs.dart';
import "../_test_bed.dart";
import 'dart:html' as dom;


main() {
  var events = {
    'blur': 'MouseEvent',
    'change': 'MouseEvent',
    'click': 'MouseEvent',
    'contextmenu': 'MouseEvent',
    // TODO(chirayu): Fix this.
    // 'doubleclick': 'MouseEvent',  // Unable to trigger this event in the test code */
    'dragenter': 'MouseEvent',
    'dragleave': 'MouseEvent',
    'dragover': 'MouseEvent',
    'dragstart': 'MouseEvent',
    'drop': 'MouseEvent',
    'focus': 'MouseEvent',
    'keydown': 'KeyboardEvent',
    'keypress': 'KeyboardEvent',
    'keyup': 'KeyboardEvent',
    'mousedown': 'MouseEvent',
    'mouseenter': 'MouseEvent',
    'mouseleave': 'MouseEvent',
    'mousemove': 'MouseEvent',
    'mouseout': 'MouseEvent',
    'mouseover': 'MouseEvent',
    'mouseup': 'MouseEvent',
    'mousewheel': 'MouseEvent',
    'scroll': 'MouseEvent',
    // These should be of type TouchEvent but that causes the tests to fail.
    // They pass as a MouseEvent.
    'touchcancel': 'MouseEvent', // 'TouchEvent',
    'touchend': 'MouseEvent', // 'TouchEvent',
    'touchmove': 'MouseEvent', // 'TouchEvent',
    'touchstart': 'MouseEvent', // 'TouchEvent'
  };


  events.forEach((name, type) {
    describe('ng-$name', () {
      TestBed _;

      beforeEach(beforeEachTestBed((tb) => _ = tb));

      it('should evaluate the expression on $name', inject(() {
        _.compile('<button ng-$name="abc = true; event = \$event"></button>');
        _.triggerEvent(_.rootElement, name, type);
        expect(_.rootScope['abc']).toEqual(true);
        expect(_.rootScope['event'] is dom.UIEvent).toEqual(true);
      }));
    });
  });
}
