part of parser_library;

class StaticParserFunctions {
  StaticParserFunctions(Map this.functions);

  Map<String, dynamic> functions;
}

class StaticParser implements Parser {
  Map<String, dynamic> _functions;
  Parser _fallbackParser;

  StaticParser(StaticParserFunctions functions,
               DynamicParser this._fallbackParser) {
    _functions = functions.functions;
  }

  call(String exp) {
    if (!_functions.containsKey(exp)) {
      print("Expression [$exp] is not supported in static parser");
      return _fallbackParser.call(exp);
    }
    return _functions[exp];
  }
}
