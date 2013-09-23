library generator;

import 'dart_code_gen.dart';
import '../../parser/parser_library.dart';

class ParserGenerator {
  DynamicParser _parser;
  NestedPrinter _p;
  List<String> _expressions;
  Map<String, boolean> _printedFunctions = {};
  GetterSetterGenerator _getters;

  ParserGenerator(DynamicParser this._parser, NestedPrinter this._p,
                  GetterSetterGenerator this._getters);

  generateParser(List<String> expressions) {
    _expressions = expressions;
    _printParserFunctions();
    _printTestMain();
  }

  String generateDart(String expression) {
    var tokens = _lexer(expression);
  }

  _printParserFunctions() {
    _printFunctions();
    _p(_getters.functions);
  }

  _printFunctions() {
    _p('var evalError = (text, [s]) => text;');
    _p('var _FUNCTIONS = {');
    _p.indent();
    _expressions.forEach((exp) => _printFunction(exp));
    _p.dedent();
    _p('};\n');
//'1': new Expression((scope, [locals]) => 1)
  }

  Code VALUE_CODE = new Code("value");

  _printFunction(String exp) {
    if (_printedFunctions.containsKey(exp)) return;
    _printedFunctions[exp] = true;
    Code codeExpression = safeCode(exp);

    _p('\'${escape(exp)}\': new Expression(');
    _p.indent();
    if (codeExpression.simpleGetter != null) {
      _p(codeExpression.simpleGetter);
    } else {
      _p('(scope, [locals]) {');
      _p.indent();
      _functionBody(exp, codeExpression);
      _p.dedent();
      _p('}');
    }
    if (codeExpression.assignable) {
      _p(', (scope, value, [locals]) { ');
      _p.indent();
      _p('${codeExpression.assign(VALUE_CODE).returnExp()}');
      _p.dedent();
      _p('}');
    }
    _p.dedent();
    _p('),');
  }

  Code safeCode(String exp) {
    try {
      return _parser(exp);
    } catch (e) {
      if ("$e".contains('Parser Error') ||
      "$e".contains('Lexer Error') ||
      "$e".contains('Unexpected end of expression')) {
        return  new Code.returnOnly("throw '${escape(e)}';");
      } else {
        rethrow;
      }
    }
  }

  _functionBody(exp, Code codeExpression) {
    _p(codeExpression.returnExp());
  }

  _printTestMain() {
    _p("""
genEvalError(msg) { throw msg; }

functions() => new StaticParserFunctions(_FUNCTIONS);

""");
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
    assert(s != null);
    assert(indentString != null);
    print("$indentString$s");
  }

  indent() {
    indentString += '  ';
  }
  dedent() {
    indentString = indentString.replaceFirst('  ', '');
  }
}
