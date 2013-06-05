library ng_log;

class Log {
  List<String> output = [];
  call(s) { output.add(s); }
  String result() => output.join('; ');
}

main() {}
