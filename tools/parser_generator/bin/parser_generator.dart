import 'package:di/di.dart';
import 'package:angular/parser_library.dart';

class ParserGenerator {
  Lexer _lexer;
  ParserGenerator(Lexer this._lexer);

  String generateParser(List<String> expressions) {
    return null;
  }
  String generateDart(String expression) {
    var tokens = _lexer(expression);
  }
}

main() {
  Injector injector = new Injector();

  injector.get(ParserGenerator).generateDart("2 + 3");

  print("""
class GeneratedParser implements Parser {
  GeneratedParser(Profiler x);
  call(String t) { return new Expression((_, [__]) => 1); }
}

generatedMain() {
  describe(\'generated parser\', () {
    beforeEach(module((AngularModule module) {
      module.type(Parser, GeneratedParser);
    }));
    main();
  });
}""");

}
