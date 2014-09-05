part of angular.change_detector;

/**
 * RULES:
 *  - ASTs are reusable. Don't store scope/instance refs there
 *  - Parent knows about children, not the other way around.
 */
abstract class AST {
  static final String _CONTEXT = '#';
  final String expression;
  var parsedExp; // The parsed version of expression.

  AST(expression)
      : expression = expression.startsWith('#.')
          ? expression.substring(2)
          : expression
  {
    assert(expression != null);
  }

  Record setupRecord(WatchGroup watchGroup);

  String toString() => expression;
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  ContextReferenceAST(): super(AST._CONTEXT);

  Record setupRecord(WatchGroup watchGroup) =>
      watchGroup.addConstantRecord(expression, watchGroup._context);
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ConstantAST extends AST {
  final constant;

  ConstantAST(constant, [String expression])
      : constant = constant,
        super(expression == null
            ? constant is String ? '"$constant"' : '$constant'
            : expression);

  Record setupRecord(WatchGroup watchGroup) => watchGroup.addConstantRecord(expression, constant);
}

/**
 * SYNTAX: lhs.name.
 *
 * This is the '.' dot operator.
 */
class FieldReadAST extends AST {
  AST lhsAST;
  final String name;

  FieldReadAST(lhsAST, name)
      : lhsAST = lhsAST,
        name = name,
        super('$lhsAST.$name');

  Record setupRecord(WatchGroup watchGroup) =>
      watchGroup.addFieldRecord(lhsAST, name, expression);
}

/**
 * SYNTAX: fn(arg0, arg1, ...)
 *
 * Invoke a pure function. Pure means that the function has no state, and
 * therefore it needs to be re-computed only if its args change.
 */
class PureFunctionAST extends AST {
  final String name;
  final /* dartbug.com/16401 Function */ fn;
  final List<AST> argsAST;

  PureFunctionAST(name, this.fn, argsAST)
      : argsAST = argsAST,
        name = name,
        super(_fnToString(name, argsAST));

  Record setupRecord(WatchGroup watchGroup) =>
      watchGroup.addFunctionRecord(fn, argsAST, const {}, expression, true);
}

/**
 * SYNTAX: fn(arg0, arg1, ...)
 *
 * Invoke a (non-pure) function.
 */
class ClosureAST extends AST {
  final String name;
  final /* dartbug.com/16401 Function */ fn;
  final List<AST> argsAST;

  ClosureAST(name, this.fn, argsAST)
      : argsAST = argsAST,
        name = name,
        super(_fnToString(name, argsAST));

  Record setupRecord(WatchGroup watchGroup) =>
      watchGroup.addFunctionRecord(fn, argsAST, const {}, expression, false);
}

/**
 * SYNTAX: lhs.method(arg0, arg1, ...)
 *
 * Invoke a method on [lhs] object.
 */
class MethodAST extends AST {
  final AST lhsAST;
  final String name;
  final List<AST> argsAST;
  final Map<Symbol, AST> namedArgsAST;

  MethodAST(lhsAST, name, argsAST, [this.namedArgsAST = const {}])
      : lhsAST = lhsAST,
        name = name,
        argsAST = argsAST,
        super('$lhsAST.${_fnToString(name, argsAST)}');

  Record setupRecord(WatchGroup watchGroup) =>
      watchGroup.addMethodRecord(lhsAST, name, argsAST, namedArgsAST, expression);
}

class CollectionAST extends AST {
  final AST valueAST;

  CollectionAST(valueAST)
      : valueAST = valueAST,
        super('#collection($valueAST)');

  Record setupRecord(WatchGroup watchGroup) => watchGroup.addCollectionRecord(this);
}

String _fnToString(String name, List<AST> items) => name + '(' + items.join(', ') + ')';



