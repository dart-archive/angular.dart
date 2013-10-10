library angular.perf.invoke;

import '_perf.dart';
import 'dart:async';

main() {
  var handleDirect = (a, b, c) => a;
  var wrap = new Wrap();
  var handleDirectNamed = ({a, b, c}) => a;
  var handleIndirect = (e) => e.a;
  var streamC = new StreamController(sync:true);
  var stream = streamC.stream..listen(handleIndirect);

  time('direct', () => handleDirect(1, 2, 3) );
  time('.call', () => wrap(1, 2, 3) );
  time('directNamed', () => handleDirectNamed(a:1, b:2, c:3) );
  time('indirect', () => handleIndirect(new Container(1, 2, 3)) );
  time('stream', () => streamC.add(new Container(1, 2, 3)));
}

class Container {
  var a;
  var b;
  var c;

  Container(this.a, this.b, this.c);
}

class Wrap {
  call(a, b, c) => a + b + c;
}
