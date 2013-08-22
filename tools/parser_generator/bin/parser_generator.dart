import 'package:di/di.dart';
import 'package:angular/parser_library.dart';

class ParserGenerator {
  Lexer _lexer;
  NestedPrinter _p;
  List<String> _expressions;

  ParserGenerator(Lexer this._lexer, NestedPrinter this._p);

  generateParser(List<String> expressions) {
    _expressions = expressions;
    _printParser();
    _printTestMain();
  }

  String generateDart(String expression) {
    var tokens = _lexer(expression);
  }

  _printParser() {
    _printFunctions();
    _p('class GeneratedParser implements Parser {');
    _p.indent();
    _printParserClass();
    _p.dedent();
    _p('}');
  }

  _printFunctions() {
    _p('var _FUNCTIONS = {');
    _p.indent();
    _expressions.forEach((exp) => _printFunction(exp));
    _p.dedent();
    _p('};');
  //'1': new Expression((scope, [locals]) => 1)
  }

  _printFunction(exp) {
    _p('\'$exp\': new Expression((scope, [locals]) {');
    _p.indent();
    _functionBody(exp);
    _p.dedent();
    _p('}),');
  }

  _functionBody(exp) {
    var tokens = _lexer(exp);
    _p('return 1;');
  }

  _printParserClass() {
    _p(r"""GeneratedParser(Profiler x);
call(String t) {
  if (!_FUNCTIONS.containsKey(t)) {
    dump("Expression $t is not supported be GeneratedParser");
  }

  return _FUNCTIONS[t];
}""");
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
    if (s[0] == '\n') s.replaceFirst('\n', '');
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
