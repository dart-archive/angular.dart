library angular.core.parser.eval;

import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/module.dart';

export 'package:angular/core/parser/eval_access.dart';
export 'package:angular/core/parser/eval_calls.dart';

class Chain extends syntax.Chain {
  Chain(List<syntax.Expression> expressions) : super(expressions);
  eval(scope, [FilterMap filters]) {
    var result;
    for (int i = 0; i < expressions.length; i++) {
      var last = expressions[i].eval(scope, filters);
      if (last != null) result = last;
    }
    return result;
  }
}

class Filter extends syntax.Filter {
  final List allArguments;
  Filter(syntax.Expression expression, String name, List<syntax.Expression> arguments,
         List<syntax.Expression> this.allArguments)
      : super(expression, name, arguments);

  eval(scope, [FilterMap filters]) =>
      Function.apply(filters(name), evalList(scope, allArguments, filters));
}

class Assign extends syntax.Assign {
  Assign(syntax.Expression target, value) : super(target, value);
  eval(scope, [FilterMap filters]) =>
      target.assign(scope, value.eval(scope, filters));
}

class Conditional extends syntax.Conditional {
  Conditional(syntax.Expression condition,
              syntax.Expression yes, syntax.Expression no): super(condition, yes, no);
  eval(scope, [FilterMap filters]) => toBool(condition.eval(scope))
      ? yes.eval(scope)
      : no.eval(scope);
}

class PrefixNot extends syntax.Prefix {
  PrefixNot(syntax.Expression expression) : super('!', expression);
  eval(scope, [FilterMap filters]) => !toBool(expression.eval(scope));
}

class Binary extends syntax.Binary {
  Binary(String operation, syntax.Expression left, syntax.Expression right):
      super(operation, left, right);
  eval(scope, [FilterMap filters]) {
    var left = this.left.eval(scope);
    switch (operation) {
      case '&&': return toBool(left) && toBool(this.right.eval(scope));
      case '||': return toBool(left) || toBool(this.right.eval(scope));
    }
    var right = this.right.eval(scope);
    switch (operation) {
      case '+'  : return autoConvertAdd(left, right);
      case '-'  : return left - right;
      case '*'  : return left * right;
      case '/'  : return left / right;
      case '~/' : return left ~/ right;
      case '%'  : return left % right;
      case '==' : return left == right;
      case '!=' : return left != right;
      case '<'  : return left < right;
      case '>'  : return left > right;
      case '<=' : return left <= right;
      case '>=' : return left >= right;
      case '^'  : return left ^ right;
      case '&'  : return left & right;
    }
    throw new EvalError('Internal error [$operation] not handled');
  }
}

class LiteralPrimitive extends syntax.LiteralPrimitive {
  LiteralPrimitive(dynamic value) : super(value);
  eval(scope, [FilterMap filters]) => value;
}

class LiteralString extends syntax.LiteralString {
  LiteralString(String value) : super(value);
  eval(scope, [FilterMap filters]) => value;
}

class LiteralArray extends syntax.LiteralArray {
  LiteralArray(List<syntax.Expression> elements) : super(elements);
  eval(scope, [FilterMap filters]) =>
      elements.map((e) => e.eval(scope, filters)).toList();
}

class LiteralObject extends syntax.LiteralObject {
  LiteralObject(List<String> keys, List<syntax.Expression>values) : super(keys, values);
  eval(scope, [FilterMap filters]) =>
      new Map.fromIterables(keys, values.map((e) => e.eval(scope, filters)));
}
