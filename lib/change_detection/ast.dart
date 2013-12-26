part of angular.watch_group;


/**
 * RULES:
 *  - ASTs are reusable. Don't store scope/instance refs there
 *  - Parent knows about children, not the other way around.
 */
abstract class AST {
  String get expression;
  WatchRecord<_Handler> setupWatch(WatchGroup scope, Map<String, WatchRecord<_Handler>> cache);
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  WatchRecord<_Handler> setupWatch(WatchGroup scope, Map<String, WatchRecord<_Handler>> cache) =>
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

  WatchRecord<_Handler> setupWatch(WatchGroup scope, Map<String, WatchRecord<_Handler>> cache) {
    // recursively process left-hand-side.
    WatchRecord<_Handler> lhsWR = cache.putIfAbsent(lhs.expression, () => lhs.setupWatch(scope, cache));

    var handler = new _FieldHandler(expression, scope);

    // Create a ChangeRecord for the current field and assign the change record to the handler.
    //var watchRecord = scope._changeDetector.watch(null, name, handler); // TODO: LOD violation
    var watchRecord = scope.addFieldWatch(name, handler); // TODO: LOD violation
    handler.watchRecord = watchRecord;

    // We set a field forwarding handler on LHS. This will allow the change objects to propagate
    // to the current WatchRecord.
    lhsWR.handler.addForwardToHandler(handler);

    // propagate the value from the LHS to here
    handler.forwardValue(lhsWR.currentValue);
    return watchRecord;
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

  WatchRecord<_Handler> setupWatch(WatchGroup scope, Map<String, WatchRecord<_Handler>> cache) {
    // Convert the args from AST to WatchRecords
    Iterable<WatchRecord<_Handler>> argsWR = argsAST.map(
        (AST ast) => cache.putIfAbsent(ast.expression, () => ast.setupWatch(scope, cache))
    ).toList();

    _InvokeHandler invokeHandler = new _InvokeHandler(expression, scope); // TODO: move to _addEvalWatch
    EvalWatchRecord evalWatchRecord = scope.addEvalWatch(fn, name, invokeHandler, argsAST.length);
    invokeHandler.watchRecord = evalWatchRecord; // TODO: move to _addEvalWatch

    var i = 0;
    argsWR.forEach((WatchRecord<_Handler> record) {
      var argHandler = new _ArgHandler(evalWatchRecord, i++, scope);
      _ArgHandlerList._add(invokeHandler, argHandler);
      record.handler.addForwardToHandler(argHandler);
      argHandler.forwardValue(record.currentValue);
    });

    return evalWatchRecord;
  }
}
