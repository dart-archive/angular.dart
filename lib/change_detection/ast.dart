part of angular.watch_group;


/**
 * RULES:
 *  - ASTs are reusable. Don't store scope/instance refs there
 *  - Parent knows about children, not the other way around.
 */
abstract class AST {
  String get expression;
  WatchRecord<_Handler> setupWatch(WatchGroup scope);
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  WatchRecord<_Handler> setupWatch(WatchGroup scope) =>
      new _ConstantWatchRecord(scope.context);
  String get expression => null;
}

/**
 * SYNTAX: lhs.name.
 *
 * This is the '.' dot operator.
 */
class FieldReadAST extends AST {
  AST lhs;
  final String name;
  final String expression;

  FieldReadAST(lhs, name):
      lhs = lhs,
      name = name,
      expression = lhs.expression == null ? name : '${lhs.expression}.$name';

  WatchRecord<_Handler> setupWatch(WatchGroup scope) {
    return scope.addFieldWatch(lhs, name, expression);
  }
}

class FunctionAST extends AST {
  final String name;
  final Function fn;
  final List<AST> argsAST;
  final String expression;

  FunctionAST(name, this.fn, argsAST):
      argsAST = argsAST,
      name = name,
      expression = '$name(${_argList(argsAST)})';

  WatchRecord<_Handler> setupWatch(WatchGroup scope) {
    return scope.addFunctionWatch(fn, argsAST, expression);
  }
}

class MethodAST extends AST {
  final AST lhsAST;
  final String name;
  final List<AST> argsAST;
  final String expression;

  MethodAST(lhsAST, name, argsAST):
    lhsAST = lhsAST,
    name = name,
    argsAST = argsAST,
    expression = '${lhsAST.expression}.$name(${_argList(argsAST)})';

  WatchRecord<_Handler> setupWatch(WatchGroup scope) {
    return scope.addMethodWatch(lhsAST, name, argsAST, expression);
  }

}

_argList(List<AST> items) => items.map((a) => a.expression).join(', ');

/**
 * The name is a bit oxymoron, but it is essentially the NullObject pattern.
 *
 * This allows children to set a handler on this ChangeRecord and then let it write the initial
 * constant value to the forwarding ChangeRecord.
 */
class _ConstantWatchRecord extends WatchRecord<_Handler> {
  final currentValue;
  final _Handler handler = new _NullHandler();

  _ConstantWatchRecord(this.currentValue);

  ChangeRecord<_Handler> check() => null;
  void remove() => null;

  get field => null;
  get previousValue => null;
  get object => null;
  set object(_) => null;
  get nextChange => null;
}
