library generator;

import 'dart_code_gen.dart';
import '../../core/parser/parser_library.dart';
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

  ParserGenerator(this._parser, this._getters, this._prt);

  generateParser(Iterable<String> expressions) {
    _prt..printSrc("genEvalError(msg) { throw msg; }")
      ..printSrc("functions(FilterLookup filters) => "
                 "new StaticParserFunctions(buildExpressions(filters));")
      ..printSrc('var evalError = (text, [s]) => text;')
      ..printSrc("");
    BodySource body = new BodySource();
    MapSource map = new MapSource();

    // deterimine the order.
    expressions.forEach((exp) {
      var code = safeCode(exp);
      map('${_.str(exp)}: ${_.ref(code)}');
    });
    // now do it in actual order
    _.codeRefs.forEach((code) {
      body(_.stmt('Expression ${_.ref(code)} = ', code.toSource(_)));
    });
    body(_.stmt('return ', map));
    _prt..printSrc("Map<String, Expression> buildExpressions(FilterLookup filters) ${body}")
      ..printSrc("\n")
      ..printSrc(_getters.functions);
  }

  Code safeCode(String exp) {
    try {
      return _parser(exp);
    } catch (e) {
      if ("$e".contains('Parser Error') ||
      "$e".contains('Lexer Error') ||
      "$e".contains('Unexpected end of expression')) {
        return  new ThrowCode("'${escape(e.toString())}';");
      } else {
        rethrow;
      }
    }
  }

}
