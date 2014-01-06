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
                 "new StaticParserFunctions(buildExpressions(filters));")
      ..printSrc('var evalError = (text, [s]) => text;')
      ..printSrc("");

    BodySource body = new BodySource();
    MapSource map = new MapSource();

    // determine the order.
    expressions.forEach((exp) {
      String code = safeCode(exp);
      map('${_.str(exp)}: (scope) $code');
    });
    body(_.stmt('return ', map));
    _prt..printSrc("Map<String, Expression> buildExpressions(FilterLookup filters) ${body}")
      ..printSrc("\n");

    NewDartCodeGen.getters.values.forEach((e) => _prt.printSrc(e));
    NewDartCodeGen.setters.values.forEach((e) => _prt.printSrc(e));
  }

  String safeCode(String exp) {
    try {
      new_parser.Expression e = _newParser.parse(exp);
      String code = NewDartCodeGen.generateForExpression(e);
      return (e is new_parser.Chain) ? "{ $code }" : "=> $code";
    } catch (e) {
      if ("$e".contains('Parser Error') ||
          "$e".contains('Lexer Error') ||
          "$e".contains('Unexpected end of expression')) {
        return "=> throw '${escape(e.toString())}'";
      } else {
        rethrow;
      }
    }
  }
}
