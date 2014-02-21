library angular.perf.mirror;

import '_perf.dart';
import 'dart:mirrors';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() {
  var c = new _Obj(1);
  InstanceMirror im = reflect(c);
  Symbol symbol = const Symbol('a');
  _Watch head = new _Watch();
  _Watch current = head;
  GetterCache getterCache = new GetterCache({});
  var detector = new DirtyCheckingChangeDetector<String>(getterCache);
  for(var i=1; i < 10000; i++) {
    _Watch next = new _Watch();
    current = (current.next = new _Watch());
    detector.watch(c, 'a', '');
  }

  var dirtyCheck = () {
    _Watch current = head;
    while(current != null) {
      if (!identical(current.lastValue, current.im.getField(current.symbol).reflectee)) {
        throw "We should not get here";
      }
      current = current.next;
    }
  };

  var dirtyCheckFn = () {
    _Watch current = head;
    while(current != null) {
      if (!identical(current.lastValue, current.getter(current.object))) {
        throw "We should not get here";
      }
      current = current.next;
    }
  };

  xtime('fieldRead', () => im.getField(symbol).reflectee );
  xtime('Object.observe', dirtyCheck);
  xtime('Object.observe fn()', dirtyCheckFn);
  time('ChangeDetection', detector.collectChanges);
}

class _Watch {
  dynamic lastValue = 1;
  _Watch next;
  String location;
  dynamic object = new _Obj(1);
  InstanceMirror im;
  Symbol symbol = const Symbol('a');
  Function getter = (s) => s.a;

  _Watch() {
    im = reflect(object);
  }
}

class _Obj {
  var a;

  _Obj(this.a);
}
