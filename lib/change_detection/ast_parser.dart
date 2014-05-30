library angular.change_detection.ast_parser;

import 'dart:collection';

import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/formatter.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/core/parser/utils.dart';

class _FunctionChain {
  final Function fn;
  _FunctionChain _next;

  _FunctionChain(fn()): fn = fn {
    assert(fn != null);
  }
}

class AstParser {
  final Parser _parser;
  int _id = 0;
  final ExpressionVisitor _visitor;

  AstParser(this._parser, ClosureMap closureMap)
      : _visitor = new ExpressionVisitor(closureMap);

  AST call(String input, {FormatterMap formatters,
                          bool collection: false }) {
    _visitor.formatters = formatters;
    AST contextRef = _visitor.contextRef;
    try {
      var exp = _parser(input);
      return collection ? _visitor.visitCollection(exp) : _visitor.visit(exp);
    } finally {
      _visitor.contextRef = contextRef;
      _visitor.formatters = null;
    }
  }
}

class ExpressionVisitor implements syntax.Visitor {
  static final ContextReferenceAST scopeContextRef = new ContextReferenceAST();
  final ClosureMap _closureMap;
  AST contextRef = scopeContextRef;


  ExpressionVisitor(this._closureMap);

  AST ast;
  FormatterMap formatters;

  AST visit(syntax.Expression exp) {
    exp.accept(this);
    assert(ast != null);
    try {
      return ast;
    } finally {
      ast = null;
    }
  }

  AST visitCollection(syntax.Expression exp) => new CollectionAST(visit(exp));
  AST _mapToAst(syntax.Expression expression) => visit(expression);

  List<AST> _toAst(List<syntax.Expression> expressions) =>
      expressions.map(_mapToAst).toList();

  Map<Symbol, AST> _toAstMap(Map<String, syntax.Expression> expressions) {
    if (expressions.isEmpty) return const {};
    Map<Symbol, AST> result = new Map<Symbol, AST>();
    expressions.forEach((String name, syntax.Expression expression) {
      result[_closureMap.lookupSymbol(name)] = _mapToAst(expression);
    });
    return result;
  }

  void visitCallScope(syntax.CallScope exp) {
    List<AST> positionals = _toAst(exp.arguments.positionals);
    Map<Symbol, AST> named = _toAstMap(exp.arguments.named);
    ast = new MethodAST(contextRef, exp.name, positionals, named);
  }
  void visitCallMember(syntax.CallMember exp) {
    List<AST> positionals = _toAst(exp.arguments.positionals);
    Map<Symbol, AST> named = _toAstMap(exp.arguments.named);
    ast = new MethodAST(visit(exp.object), exp.name, positionals, named);
  }
  void visitAccessScope(syntax.AccessScope exp) {
    ast = new FieldReadAST(contextRef, exp.name);
  }
  void visitAccessMember(syntax.AccessMember exp) {
    ast = new FieldReadAST(visit(exp.object), exp.name);
  }
  void visitBinary(syntax.Binary exp) {
    ast = new PureFunctionAST(exp.operation,
                              _operationToFunction(exp.operation),
                              [visit(exp.left), visit(exp.right)]);
  }
  void visitPrefix(syntax.Prefix exp) {
    ast = new PureFunctionAST(exp.operation,
                              _operationToFunction(exp.operation),
                              [visit(exp.expression)]);
  }
  void visitConditional(syntax.Conditional exp) {
    ast = new PureFunctionAST('?:', _operation_ternary,
                              [visit(exp.condition), visit(exp.yes),
                              visit(exp.no)]);
  }
  void visitAccessKeyed(syntax.AccessKeyed exp) {
    ast = new ClosureAST('[]', _operation_bracket,
                             [visit(exp.object), visit(exp.key)]);
  }
  void visitLiteralPrimitive(syntax.LiteralPrimitive exp) {
    ast = new ConstantAST(exp.value);
  }
  void visitLiteralString(syntax.LiteralString exp) {
    ast = new ConstantAST(exp.value);
  }
  void visitLiteralArray(syntax.LiteralArray exp) {
    List<AST> items = _toAst(exp.elements);
    ast = new PureFunctionAST('[${items.join(', ')}]', new ArrayFn(), items);
  }

  void visitLiteralObject(syntax.LiteralObject exp) {
    List<String> keys = exp.keys;
    List<AST> values = _toAst(exp.values);
    assert(keys.length == values.length);
    var kv = <String>[];
    for (var i = 0; i < keys.length; i++) {
      kv.add('${keys[i]}: ${values[i]}');
    }
    ast = new PureFunctionAST('{${kv.join(', ')}}', new MapFn(keys), values);
  }

  void visitFormatter(syntax.Formatter exp) {
    if (formatters == null) {
      throw new Exception("No formatters have been registered");
    }
    Function formatterFunction = formatters(exp.name);
    List<AST> args = [visitCollection(exp.expression)];
    args.addAll(_toAst(exp.arguments).map((ast) => new CollectionAST(ast)));
    ast = new PureFunctionAST('|${exp.name}',
        new _FormatterWrapper(formatterFunction, args.length), args);
  }

  // TODO(misko): this is a corner case. Choosing not to implement for now.
  void visitCallFunction(syntax.CallFunction exp) {
    _notSupported("function's returing functions");
  }
  void visitAssign(syntax.Assign exp) {
    _notSupported('assignement');
  }
  void visitLiteral(syntax.Literal exp) {
    _notSupported('literal');
  }
  void visitExpression(syntax.Expression exp) {
    _notSupported('?');
  }
  void visitChain(syntax.Chain exp) {
    _notSupported(';');
  }

  void  _notSupported(String name) {
    throw new StateError("Can not watch expression containing '$name'.");
  }
}

Function _operationToFunction(String operation) {
  switch(operation) {
    case '!'  : return _operation_negate;
    case '+'  : return _operation_add;
    case '-'  : return _operation_subtract;
    case '*'  : return _operation_multiply;
    case '/'  : return _operation_divide;
    case '~/' : return _operation_divide_int;
    case '%'  : return _operation_remainder;
    case '==' : return _operation_equals;
    case '!=' : return _operation_not_equals;
    case '<'  : return _operation_less_then;
    case '>'  : return _operation_greater_then;
    case '<=' : return _operation_less_or_equals_then;
    case '>=' : return _operation_greater_or_equals_then;
    case '^'  : return _operation_power;
    case '&'  : return _operation_bitwise_and;
    case '&&' : return _operation_logical_and;
    case '||' : return _operation_logical_or;
    default: throw new StateError(operation);
  }
}

_operation_negate(value)                       => !toBool(value);
_operation_add(left, right)                    => autoConvertAdd(left, right);
_operation_subtract(left, right)               => (left != null && right != null) ? left - right : (left != null ? left : (right != null ? 0 - right : 0));
_operation_multiply(left, right)               => (left == null || right == null) ? null : left * right;
_operation_divide(left, right)                 => (left == null || right == null) ? null : left / right;
_operation_divide_int(left, right)             => (left == null || right == null) ? null : left ~/ right;
_operation_remainder(left, right)              => (left == null || right == null) ? null : left % right;
_operation_equals(left, right)                 => left == right;
_operation_not_equals(left, right)             => left != right;
_operation_less_then(left, right)              => (left == null || right == null) ? null : left < right;
_operation_greater_then(left, right)           => (left == null || right == null) ? null : left > right;
_operation_less_or_equals_then(left, right)    => (left == null || right == null) ? null : left <= right;
_operation_greater_or_equals_then(left, right) => (left == null || right == null) ? null : left >= right;
_operation_power(left, right)                  => (left == null || right == null) ? null : left ^ right;
_operation_bitwise_and(left, right)            => (left == null || right == null) ? null : left & right;
// TODO(misko): these should short circuit the evaluation.
_operation_logical_and(left, right)            => toBool(left) && toBool(right);
_operation_logical_or(left, right)             => toBool(left) || toBool(right);

_operation_ternary(condition, yes, no) => toBool(condition) ? yes : no;
_operation_bracket(obj, key) => obj == null ? null : obj[key];

class ArrayFn extends FunctionApply {
  // TODO(misko): figure out why do we need to make a copy?
  apply(List args) => new List.from(args);
}

class MapFn extends FunctionApply {
  final List<String> keys;

  MapFn(this.keys);

  Map apply(List values) {
    // TODO(misko): figure out why do we need to make a copy instead of reusing instance?
    assert(values.length == keys.length);
    return new Map.fromIterables(keys, values);
  }
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
