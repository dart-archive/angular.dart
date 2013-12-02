part of angular.core.parser;

class StaticParserFunctions {
  StaticParserFunctions(Map this.functions);

  Map<String, dynamic> functions;
}

@NgInjectableService()
class StaticParser implements Parser {
  Map<String, dynamic> _functions;
  Parser _fallbackParser;

  StaticParser(StaticParserFunctions functions,
               DynamicParser this._fallbackParser) {
    assert(functions != null);
    _functions = functions.functions;
  }

  call(String exp) {
    if (exp == null) exp = "";
    if (!_functions.containsKey(exp)) {
      //print("Expression [$exp] is not supported in static parser");
      return _fallbackParser.call(exp);
    }
    return _functions[exp];
  }

  primaryFromToken(Token token, parserError) {
    throw 'Not Implemented';
  }
}
