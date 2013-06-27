library ng_log;

//TODO(misko): merge with Logger
class Log {
  List<String> output = [];
  call(s) { output.add(s); }
  String result() => output.join('; ');
}

main() {}
