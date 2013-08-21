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
    print(tokens);
  }
}

main() {
  Injector injector = new Injector();

  injector.get(ParserGenerator).generateDart("2 + 3");
}
