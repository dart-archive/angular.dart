import 'package:di/di.dart';
import 'package:angular/parser_library.dart';

class Code {
  String exp;
  Code(this.exp);

  returnExp() => "return $exp;";
}

class CodeExpressionFactory {
  _op(fn) => fn;

  binaryFn(left, fn, right) =>
    new Code("${left.exp} ${_op(fn)} ${right.exp}");

  unaryFn(fn, right) => new Code("${_op(fn)}${right.exp}");
  assignment(left, right, evalError) { throw "assignment"; }
  multipleStatements(statements) { throw "mS"; }
  functionCall(fn, fnName, argsFn, evalError) { throw "func"; }
  arrayDeclaration(elementFns) { throw "arrayDecl"; }
  objectIndex(obj, indexFn, evalError) { throw "objectIndex"; }
  fieldAccess(object, field) { throw "fieldAccess"; }
  object(keyValues) { throw "object"; }
  profiled(value, perf, text) => value; // no profiling for now
  fromOperator(op) => new Code(_op(op));
  getterSetter(key) { throw "getterSetter"; }
  value(v) => new Code(v);
  zero() => new Code(0);
}

class ParserGenerator {
  Parser _parser;
  NestedPrinter _p;
  List<String> _expressions;

  ParserGenerator(Parser this._parser, NestedPrinter this._p);

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
    var codeExpression = _parser(exp);
    _p(codeExpression.returnExp());
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
  Module module = new Module()
    ..type(ExpressionFactory, CodeExpressionFactory);

  Injector injector = new Injector([module]);

  injector.get(ParserGenerator).generateParser([
      "1", "-1", "+1",
      "!true",
      "3*4/2%5", "3+6-2", ]);
}
