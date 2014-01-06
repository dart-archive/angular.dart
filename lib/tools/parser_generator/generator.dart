library generator;

import 'dart_code_gen.dart';
import '../../core/parser/new_syntax.dart';

class SourcePrinter {
  printSrc(src) {
    print(src);
  }
}

class ParserGenerator {
  final Parser _parser;
  final SourcePrinter _printer;
  ParserGenerator(this._parser, this._printer);

  void print(object) {
    _printer.printSrc('$object');
  }

  generateParser(Iterable<String> expressions) {
    print("genEvalError(msg) { throw msg; }");
    print("functions(FilterLookup filters) => "
          "new StaticParserFunctions(buildEval(filters), buildAssign(filters));");
    print('var evalError = (text, [s]) => text;');
    print("");

    // Compute the function maps.
    Map eval = {};
    Map assign = {};
    expressions.forEach((exp) {
      generateCode(exp, eval, assign);
    });

    // Generate the code.
    generateBuildFunction('buildEval', eval);
    generateBuildFunction('buildAssign', assign);
    DartCodeGen.getters.values.forEach(print);
    DartCodeGen.holders.values.forEach(print);
    DartCodeGen.setters.values.forEach(print);
  }

  void generateBuildFunction(String name, Map map) {
    String mapLiteral = map.keys.map((e) => '    "$e": ${map[e]}').join(',\n');
    print("Map<String, Function> $name(FilterLookup filters) {");
    print("  return {\n$mapLiteral\n  };");
    print("}");
    print("");
  }

  void generateCode(String exp, Map eval, Map assign) {
    String escaped = escape(exp);
    try {
      Expression e = _parser.parse(exp);
      if (e is Assignable) {
        assign[escaped] = getCode(e, true);
      }
      eval[escaped] = getCode(e, false);
    } catch (e) {
      if ("$e".contains('Parser Error') ||
          "$e".contains('Lexer Error') ||
          "$e".contains('Unexpected end of expression')) {
        eval[escaped] = '"${escape(e.toString())}"';
      } else {
        rethrow;
      }
    }
  }

  static String getCode(Expression e, bool assign) {
    String args = assign ? "scope, value" : "scope";
    String code = DartCodeGen.generateForExpression(e, assign);
    if (e is Chain) {
      code = code.replaceAll('\n', '\n      ');
      return "($args) {\n      $code\n    }";
    } else {
      return "($args) => $code";
    }
  }
}
