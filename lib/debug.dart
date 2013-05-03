library debug;

import 'package:js/js.dart' as js;
import 'dart:html';

dump(obj) {
  var log = STRINGIFY(obj);
  js.scoped(() {
    js.context.console.log(log);
  });
}

STRINGIFY(obj) {
  if (obj is List) {
    var out = [];
    obj.forEach((i) => out.add(STRINGIFY(i)));
    return '[${out.join(", ")}]';
  } else if (obj is Comment) {
    return '<!--${obj.text}-->';
  } else if (obj is Element) {
    return obj.outerHtml;
  } else if (obj is String) {
    return '"$obj"';
  } else {
    return obj.toString();
  }
}

main() {}
