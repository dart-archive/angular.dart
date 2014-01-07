library angular.core.parser;

import 'package:angular/core/module.dart';
import 'package:angular/core/parser/new_eval.dart' as new_parser;

part 'dynamic_parser.dart';
part 'static_parser.dart';

typedef dynamic LocalsWrapper(dynamic context, dynamic locals);

// Placeholder for DI.
// The parser you are looking for is DynamicParser
abstract class Parser {
  Expression call(String text);
}

class BoundExpression {
  var _context;
  LocalsWrapper _localsWrapper;
  Expression expression;

  BoundExpression(this._context, this.expression, this._localsWrapper);
  _localContext(locals) {
    if (locals != null) {
      if (_localsWrapper == null) {
          throw new StateError("Locals $locals provided, but no LocalsWrapper strategy.");
      }
      return _localsWrapper(_context, locals);
    }
    return _context;
  }

  call([locals]) => expression.eval(_localContext(locals));
  assign(value, [locals]) => expression.assign(_localContext(locals), value);
}

class Expression implements ParserAST {
  final ParsedGetter eval;
  final ParsedSetter assign;

  String exp;
  List parts;

  // Expressions that represent field accesses have a couple of
  // extra fields. We use that to generate an optimized closure
  // for calling fields of objects without having to load the
  // field separately.
  Expression fieldHolder;
  String fieldName;
  bool get isFieldAccess => fieldHolder != null;

  Expression(ParsedGetter this.eval, [ParsedSetter this.assign]);

  bind(context, [localsWrapper]) => new BoundExpression(context, this, localsWrapper);

  get assignable => assign != null;
}

@NgInjectableService()
class GetterSetter {
  Function getter(String key) => null;
  Function setter(String key) => null;
}
