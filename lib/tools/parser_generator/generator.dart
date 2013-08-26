library generator;

import 'dart_code_gen.dart';
import '../../parser/parser_library.dart';

class ParserGenerator {
  Parser _parser;
  NestedPrinter _p;
  List<String> _expressions;
  GetterSetterGenerator _getters;

  ParserGenerator(Parser this._parser, NestedPrinter this._p,
                  GetterSetterGenerator this._getters);

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
    _p(_getters.functions);
  }

  _printFunctions() {
    _p('var _FUNCTIONS = {');
    _p.indent();
    _expressions.forEach((exp) => _printFunction(exp));
    _p.dedent();
    _p('};');
//'1': new Expression((scope, [locals]) => 1)
  }

  Code VALUE_CODE = new Code("value");

  _printFunction(String exp) {
    Code codeExpression = safeCode(exp);

    _p('\'${escape(exp)}\': new Expression((scope, [locals]) {');
    _p.indent();
    _functionBody(exp, codeExpression);
    _p.dedent();

    if (codeExpression.assignable) {
      _p('}, (scope, value, [locals]) { ${codeExpression.assign(VALUE_CODE).returnExp()} }),');
    } else {
      _p('}),');
    }
  }

  Code safeCode(String exp) {
    try {
      return _parser(exp);
    } catch (e) {
      if ("$e".contains('Parser Error') ||
      "$e".contains('Unexpected end of expression')) {
        return  new Code.returnOnly("throw r'$e';");
      } else {
        rethrow;
      }
    }
  }

  _functionBody(exp, codeExpression) {
    _p('String exp = \'${escape(exp)}\';');
    _p('evalError(s, [stack]) => parserEvalError(s, exp, stack);');
    _p('try {');
    _p.indent();


    _p(codeExpression.returnExp());

    _p.dedent();
    _p("""} catch (e, s) {
  if ("\$e".contains("Eval Error")) rethrow;
  throw parserEvalError(\'Caught \$e\', exp, s);
}""");
  }

  _printParserClass() {
    _p(r"""GeneratedParser(Profiler x);
call(String t) {
  if (!_FUNCTIONS.containsKey(t)) {
    dump(":XNAY:$t:XNAY:");
    //dump("Expression $t is not supported be GeneratedParser");
  }

  return _FUNCTIONS[t];
}""");
  }

  _printTestMain() {
    _p("""
    genEvalError(msg) { throw msg; }

    generatedMain() {
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
