library angular.perf.mirror;

import '_perf.dart';
import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() {
  var c = new Obj(1);
  InstanceMirror im = reflect(c);
  Symbol symbol = new Symbol('a');
  Watch head = new Watch();
  Watch current = head;
  var detector = new DirtyCheckingChangeDetector<String, String>();
  for(var i=1; i < 10000; i++) {
    Watch next = new Watch();
    current = (current.next = new Watch());
    detector.watch(c, 'a', '', '');
  }

  var dirtyCheck = () {
    Watch current = head;
    while(current != null) {
      if (!identical(current.lastValue, current.im.getField(current.symbol).reflectee)) {
        throw "We should not get here";
      }
      current = current.next;
    }
  };

  var dirtyCheckFn = () {
    Watch current = head;
    while(current != null) {
      if (!identical(current.lastValue, current.getter(current.object))) {
        throw "We should not get here";
      }
      current = current.next;
    }
  };

  time('fieldRead', () => im.getField(symbol).reflectee );
  time('Object.observe', dirtyCheck);
  time('Object.observe fn()', dirtyCheckFn);
  time('ChangeDetection', detector.collectChanges);
}

class Watch {
  dynamic lastValue = 1;
  Watch next;
  String location;
  dynamic object = new Obj(1);
  InstanceMirror im;
  Symbol symbol = new Symbol('a');
  Function getter = (s) => s.a;

  Watch() {
    im = reflect(object);
  }
}

class Obj {
  var a;

  Obj(this.a);
}
