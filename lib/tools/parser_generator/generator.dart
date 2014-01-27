library generator;

import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/tools/parser_generator/dart_code_gen.dart';

class NullFilterMap implements FilterMap {
  call(name) => null;
  Type operator[](annotation) => null;
  forEach(fn) { }
  annotationsFor(type) => null;
}

class SourcePrinter {
  printSrc(src) {
    print(src);
  }
}

class ParserGenerator {
  final Parser _parser;
  final DartCodeGen _codegen;
  final SourcePrinter _printer;
  ParserGenerator(this._parser, this._codegen, this._printer);

  void print(object) {
    _printer.printSrc('$object');
  }

  generateParser(Iterable<String> expressions) {
    print("StaticParserFunctions functions(FilterLookup filters)");
    print("    => new StaticParserFunctions(");
    print("           buildEval(filters), buildAssign(filters));");
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
    _codegen.getters.helpers.values.forEach(print);
    _codegen.holders.helpers.values.forEach(print);
    _codegen.setters.helpers.values.forEach(print);
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
      Expression e = _parser(exp);
      if (e.isAssignable) assign[escaped] = getCode(e, true);
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

  String getCode(Expression e, bool assign) {
    String args = assign ? "scope, value" : "scope";
    String code = _codegen.generate(e, assign);
    if (e.isChain) {
      code = code.replaceAll('\n', '\n      ');
      return "($args) {\n      $code\n    }";
    } else {
      return "($args) => $code";
    }
  }
}
