library angular.core.parser.eval_calls;

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/module.dart';


class CallScope extends syntax.CallScope {
  final MethodClosure function;
  CallScope(name, this.function, arguments)
      : super(name, arguments);

  eval(scope, [FilterMap filters]) {
    var positionals = arguments.positionals;
    var posArgs = new List(positionals.length);
    for(var i = 0; i < positionals.length; i++) {
      posArgs[i] = positionals[i].eval(scope, filters);
    }
    var namedArgs = {};
    arguments.named.forEach((name, Expression exp) {
      namedArgs[name] = exp.eval(scope, filters);
    });
    if (function == null) {
      _throwUndefinedFunction(name);
    }
    return function(scope, posArgs, namedArgs);
  }
}

class CallMember extends syntax.CallMember {
  final MethodClosure function;
  CallMember(object, this.function, name, arguments)
      : super(object, name, arguments)
  {
    if (function == null) {
      _throwUndefinedFunction(name);
    }
  }

  eval(scope, [FilterMap filters]) {
    var positionals = arguments.positionals;
    var posArgs = new List(positionals.length);
    for(var i = 0; i < positionals.length; i++) {
      posArgs[i] = positionals[i].eval(scope, filters);
    }
    var namedArgs = {};
    arguments.named.forEach((name, Expression exp) {
      namedArgs[name] = exp.eval(scope, filters);
    });
    return function(object.eval(scope, filters), posArgs, namedArgs);
  }
}

class CallFunction extends syntax.CallFunction {
  CallFunction(function, arguments) : super(function, arguments);
  eval(scope, [FilterMap filters]) {
    var function  = this.function.eval(scope, filters);
    if (function is! Function) {
      throw new EvalError('${this.function} is not a function');
    } else {
      List positionals = evalList(scope, arguments.positionals, filters);
      if (arguments.named.isNotEmpty) {
        var named = new Map<Symbol, dynamic>();
        arguments.named.forEach((String name, value) {
          named[new Symbol(name)] = value.eval(scope, filters);
        });
        return Function.apply(function, positionals, named);
      } else {
        return relaxFnApply(function, positionals);
      }
    }
  }
}


_throwUndefinedFunction(name) {
  throw "Undefined function $name";
}
