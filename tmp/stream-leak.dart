import "dart:async";


main() {
  var handleIndirect = (e) => e.a + e.b + e.c;
  var streamC = new StreamController(sync:true);
  var stream = streamC.stream..listen(handleIndirect);
  for(var i = 0; i < 1000000000; i++) {
    streamC.add(new Container('arg1', 'arg2', 'arg3'));
  }
}

class Container {
  var a;
  var b;
  var c;

  Container(this.a, this.b, this.c);
}
