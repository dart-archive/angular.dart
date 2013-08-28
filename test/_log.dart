library ng_log;

import "package:angular/angular.dart";

//TODO(misko): merge with Logger
class Log {
  List<String> output = [];
  call(s) { output.add(s); }
  String result() => output.join('; ');
}

@NgDirective(
    selector: '[log]',
    map: const {
      'log': '@.message'
    }
)
class LogAttrDirective {
  Log log;
  String message;
  LogAttrDirective(Log this.log);
  attach() => log(message == '' ? 'LOG' : message);
}

main() {}
