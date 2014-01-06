library generator;

import 'dart_code_gen.dart';
import '../../core/parser/parser_library.dart';
import '../../core/parser/new_syntax.dart' as new_parser;
import 'source.dart';

class SourcePrinter {
  printSrc(src) {
    print(src);
  }
}

class ParserGenerator {
  DynamicParser _parser;
  Map<String, bool> _printedFunctions = {};
  GetterSetterGenerator _getters;
  SourceBuilder _ = new SourceBuilder();
  SourcePrinter _prt;
  final new_parser.Parser _newParser;

  ParserGenerator(this._parser, this._getters, this._prt, this._newParser);

  generateParser(Iterable<String> expressions) {
    _prt..printSrc("genEvalError(msg) { throw msg; }")
      ..printSrc("functions(FilterLookup filters) => "
                 "new StaticParserFunctions(buildEval(filters), buildAssign(filters));")
      ..printSrc('var evalError = (text, [s]) => text;')
      ..printSrc("");


    // Compute the function maps.
    MapSource eval = new MapSource();
    MapSource assign = new MapSource();
    expressions.forEach((exp) {
      generateCode(exp, eval, assign);
    });

    // Generate the code.
    generateBuildFunction('buildEval', eval);
    generateBuildFunction('buildAssign', assign);
    NewDartCodeGen.getters.values.forEach(_prt.printSrc);
    NewDartCodeGen.holders.values.forEach(_prt.printSrc);
    NewDartCodeGen.setters.values.forEach(_prt.printSrc);
  }

  void generateBuildFunction(String name, MapSource map) {
    BodySource src = new BodySource();
    src(_.stmt('return ', map));
    _prt.printSrc("Map<String, Function> $name(FilterLookup filters) {$src}\n");
  }

  void generateCode(String exp, MapSource eval, MapSource assign) {
    String escaped = _.str(exp);
    try {
      new_parser.Expression e = _newParser.parse(exp);
      if (e is new_parser.Assignable) {
        assign('$escaped: ${getCode(e, true)}');
      }
      eval('$escaped: ${getCode(e, false)}');
    } catch (e) {
      if ("$e".contains('Parser Error') ||
          "$e".contains('Lexer Error') ||
          "$e".contains('Unexpected end of expression')) {
        eval('$escaped: "${escape(e.toString())}"');
      } else {
        rethrow;
      }
    }
  }

  static String getCode(new_parser.Expression e, bool assign) {
    String args = assign ? "scope, value" : "scope";
    String code = NewDartCodeGen.generateForExpression(e, assign);
    return (e is new_parser.Chain) ? "($args) { $code }" : "($args) => $code";
  }
}
