library angular.perf.mirror;

import '_perf.dart';
import 'dart:mirrors';

main() {
  var c = new Obj(1);
  InstanceMirror im = reflect(c);
  Symbol symbol = new Symbol('a');

  var r = new Row();

  time('fieldRead', () => im.getField(symbol).reflectee );
  time('dirtyCheck', () => !identical(r.im.getField(r.symbol).reflectee, r.lastValue) );
  time('dirtyCheck.gc', () {
    new List(5).join('');
    return !identical(r.im.getField(r.symbol).reflectee, r.lastValue);
  });
}

class Obj {
  var a;

  Obj(this.a);
}

class Row {
  var im = reflect(new Obj(1  ));
  var symbol = new Symbol('a');
  var lastValue;
}

