import 'package:di/di.dart';
import 'package:angular/parser_library.dart';

class ParserGenerator {
  Lexer _lexer;
  NestedPrinter _p;
  ParserGenerator(Lexer this._lexer, NestedPrinter this._p);

  generateParser(List<String> expressions) {
    _printParser();
    _printTestMain();
  }

  String generateDart(String expression) {
    var tokens = _lexer(expression);
  }

  _printParser() {
    _p('class GeneratedParser implements Parser {');
    _p.indent();
    _printParserClass();
    _p.dedent();
    _p('}');
  }

  _printParserClass() {
    _p('GeneratedParser(Profiler x);');
    _p('call(String t) { return new Expression((_, [__]) => 1); }');
  }

  _printTestMain() {
    _p("""generatedMain() {
  describe(\'generated parser\', () {
    beforeEach(module((AngularModule module) {
      module.type(Parser, GeneratedParser);
    }));
    main();
  });
}""");
  }
}

class NestedPrinter {
  String indentString = '';
  call(String s) {
    var lines = s.split('\n');
    lines.forEach((l) { _oneLine(l); });
  }

  _oneLine(String s) {
    print("$indentString$s");
  }

  indent() {
    indentString += '  ';
  }
  dedent() {
    indentString = indentString.replaceFirst('  ', '');
  }
}

main() {
  Injector injector = new Injector();

  injector.get(ParserGenerator).generateParser(["1"]);
}
