part of angular.watch_group;


/**
 * RULES:
 *  - ASTs are reusable. Don't store scope/instance refs there
 *  - Parent knows about children, not the other way around.
 */
abstract class AST {
  static final String _CONTEXT = '#';
  final String expression;
  Expression parsedExp; // The parsed version of expression.
  AST(expression)
      : expression = expression.startsWith('#.')
          ? expression.substring(2)
          : expression
  {
    assert(expression!=null);
  }
  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
    Map<String, WatchRecord<_Handler>> cache]);
  String toString() => expression;
}

/**
 * SYNTAX: _context_
 *
 * This represent the initial _context_ for evaluation.
 */
class ContextReferenceAST extends AST {
  ContextReferenceAST(): super(AST._CONTEXT);
  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => new _ConstantWatchRecord(watchGroup, expression, context);
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

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => new _ConstantWatchRecord(watchGroup, expression, constant);
}

/**
 * SYNTAX: lhs.name.
 *
 * This is the '.' dot operator.
 */
class FieldReadAST extends AST {
  AST lhs;
  final String name;

  FieldReadAST(lhs, name)
      : lhs = lhs,
        name = name,
        super('$lhs.$name');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) =>
          watchGroup.addFieldWatch(lhs, name, expression, context, userData, cache);
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
      : name = name, argsAST = argsAST, super('$name(${_argList(argsAST)})');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => watchGroup.addFunctionWatch(fn, argsAST, const {}, expression, true,
          context, userData, cache);
}

/**
 *
 */
class FormatterAST extends AST {

  List<AST> args;
  String name;

  FormatterAST(name, args): name = name, args = args, super('$name(${_argList(args)})');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) {
    if(userData is! FormatterMap) throw "userData must be of type FormatterMap.";
    Function formatterFunction = userData(name);
    var fn = new _FormatterWrapper(formatterFunction, args.length);
    return watchGroup.addFunctionWatch(fn, args, const {}, expression, true, context, userData, cache);
  }


}

/**
 * SYNTAX: fn(arg0, arg1, ...)
 *
 * Invoke a pure function. Pure means that the function has no state, and
 * therefore it needs to be re-computed only if its args change.
 */
class ClosureAST extends AST {
  final String name;
  final /* dartbug.com/16401 Function */ fn;
  final List<AST> argsAST;

  ClosureAST(name, this.fn, argsAST)
      : argsAST = argsAST,
        name = name,
        super('$name(${_argList(argsAST)})');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => watchGroup.addFunctionWatch(fn, argsAST, const {}, expression,
          false, context, userData, cache);
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
        super('$lhsAST.$name(${_argList(argsAST)})');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => watchGroup.addMethodWatch(lhsAST, name, argsAST, namedArgsAST,
          expression, context, userData, cache);
}


class CollectionAST extends AST {
  final AST valueAST;
  CollectionAST(valueAST)
      : valueAST = valueAST,
        super('#collection($valueAST)');

  WatchRecord<_Handler> setupWatch(WatchGroup watchGroup, [dynamic context, dynamic userData,
      Map<String, WatchRecord<_Handler>> cache]) => watchGroup.addCollectionWatch(valueAST, context, userData, cache);
}

String _argList(List<AST> items) => items.join(', ');

/**
 * The name is a bit oxymoron, but it is essentially the NullObject pattern.
 *
 * This allows children to set a handler on this Record and then let it write
 * the initial constant value to the forwarding Record.
 */
class _ConstantWatchRecord extends WatchRecord<_Handler> {
  final currentValue;
  final _Handler handler;

  _ConstantWatchRecord(WatchGroup watchGroup, String expression, currentValue)
      : currentValue = currentValue,
        handler = new _ConstantHandler(watchGroup, expression, currentValue);

  bool check() => false;
  void remove() => null;

  get field => null;
  get previousValue => null;
  get object => null;
  set object(_) => null;
  get nextChange => null;
}

class _FormatterWrapper extends FunctionApply {
  final Function formatterFn;
  final List args;
  final List<Watch> argsWatches;
  _FormatterWrapper(this.formatterFn, length):
  args = new List(length),
  argsWatches = new List(length);

  apply(List values) {
    for (var i=0; i < values.length; i++) {
      var value = values[i];
      var lastValue = args[i];
      if (!identical(value, lastValue)) {
        if (value is CollectionChangeRecord) {
          args[i] = (value as CollectionChangeRecord).iterable;
        } else if (value is MapChangeRecord) {
          args[i] = (value as MapChangeRecord).map;
        } else {
          args[i] = value;
        }
      }
    }
    var value = Function.apply(formatterFn, args);
    if (value is Iterable) {
      // Since formatters are pure we can guarantee that this well never change.
      // By wrapping in UnmodifiableListView we can hint to the dirty checker
      // and short circuit the iterator.
      value = new UnmodifiableListView(value);
    }
    return value;
  }
}

