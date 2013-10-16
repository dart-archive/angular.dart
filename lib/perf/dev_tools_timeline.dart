part of angular.perf;

class DevToolsTimelineProfiler extends Profiler {
  final dom.Console console = dom.window.console;
  String prefix = '';

  int startTimer(String name, [String extraData]) {
    console.time('$prefix$name');
    prefix = '$prefix  ';
  }

  void stopTimer(dynamic name) {
    prefix = prefix.length > 0 ? prefix.substring(0, prefix.length - 2) : prefix;
    console.timeEnd('$prefix$name');
  }

  void markTime(String name, [String extraData]) {
    console.timeStamp('$prefix$name');
  }
}
