library wtf_test_app;

import 'package:angular/tracing.dart' as trace;
import 'dart:js' show context;
import 'dart:html';

main() {
  trace.detectWTF(context);
  var _main = trace.createScope('main()');
  var _querySelector = trace.createScope('Node#querySelector()');
  var _divElement = trace.createScope('DivElement()');
  var _elementText = trace.createScope('Element#text');
  var _nodeAppend = trace.createScope('Node#append()');
  var scope = trace.enter(_main);
  var s = trace.enter(_querySelector);
  BodyElement body = window.document.querySelector('body');
  trace.leave(s);

  s = trace.enter(_divElement);
  var div = new DivElement();
  trace.leave(s);

  s = trace.enter(_elementText);
  div.text = 'Hello WTF! (enabled: ${trace.wtfEnabled})';
  trace.leave(s);

  s = trace.enter(_nodeAppend);
  body.append(div);
  trace.leave(s);
  trace.leave(scope);
}
