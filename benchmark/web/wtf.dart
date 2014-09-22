library wtf_test_app;

import 'package:angular/tracing.dart';
import 'dart:html';
import 'dart:js' show context;

main() {
  traceDetectWTF(context);
  var _main = traceCreateScope('main()');
  var _querySelector = traceCreateScope('Node#querySelector()');
  var _DivElement = traceCreateScope('DivElement()');
  var _ElementText = traceCreateScope('Element#text');
  var _NodeAppend = traceCreateScope('Node#append()');
  var scope = traceEnter(_main);
    var s = traceEnter(_querySelector);
    BodyElement body = window.document.querySelector('body');
    traceLeave(s);

    s = traceEnter(_DivElement);
    var div = new DivElement();
    traceLeave(s);

    s = traceEnter(_ElementText);
    div.text = 'Hello WTF! (enabled: ${traceEnabled})';
    traceLeave(s);

    s = traceEnter(_NodeAppend);
    body.append(div);
    traceLeave(s);
  traceLeave(scope);
}
