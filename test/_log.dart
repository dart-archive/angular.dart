library ng_log;

import "package:angular/angular.dart";

//TODO(misko): merge with Logger
class Log {
  List<String> output = [];
  call(s) { output.add(s); }
  String result() => output.join('; ');
}

class LogAttrDirective {
  static var $priority = 0;
  Log log;
  LogAttrDirective(Log this.log, NodeAttrs attrs) {
    log(attrs[this] == "" ? "LOG" : attrs[this]);
  }
}

main() {}
