part of angular.core.parser;

class StaticParserFunctions {
  Map<String, Function> eval;
  Map<String, Function> assign;
  StaticParserFunctions(this.eval, this.assign);
}

@NgInjectableService()
class StaticParser implements Parser {
  Map<String, Function> _eval;
  Map<String, Function> _assign;
  Parser _fallbackParser;

  StaticParser(StaticParserFunctions functions,
               DynamicParser this._fallbackParser) {
    assert(functions != null);
    _eval = functions.eval;
    _assign = functions.assign;
  }

  call(String exp) {
    if (exp == null) exp = "";
    if (!_eval.containsKey(exp)) {
      //print("Expression [$exp] is not supported in static parser");
      return _fallbackParser.call(exp);
    }
    var eval = _eval[exp];
    if (eval is !Function) throw eval;
    Function assign = _assign[exp];
    return new Expression(eval, assign);
  }
}
