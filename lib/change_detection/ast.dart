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
      expression = '$name(${argsAST.map((a) => a.expression).join(', ')})';

  WatchRecord<_Handler> setupWatch(WatchGroup scope) {
    return scope.addFunctionWatch(fn, argsAST, expression);
  }
}
