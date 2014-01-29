library angular.scope2;

import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/core/parser/syntax.dart';
import 'package:angular/core/parser/utils.dart';
import 'package:angular/angular.dart';
import 'dart:collection';

class Scope2 {
  final Parser _parser;
  final WatchGroup _watchGroup;
  final ExpressionVisitor visitor = new ExpressionVisitor();
  Object context;

  Scope2(Object this.context, this._parser, this._watchGroup);

  watch(String expression, ReactionFn reactionFn) {
    AST ast = visitor.visit(_parser.call(expression));
    assert(ast != null);
    return _watchGroup.watch(ast, reactionFn);
  }

  digest() => _watchGroup.detectChanges();
}

class ExpressionVisitor implements Visitor {
  static final ContextReferenceAST contextRef = new ContextReferenceAST();
  AST ast;

  visit(Expression exp) {
    exp.accept(this);
    assert(ast != null);
    return ast;
  }

  AST _mapToAst(Expression expression) => visit(expression);
  List<AST> _toAst(List<Expression> expressions) => expressions.map(_mapToAst).toList();

  visitCallScope(CallScope exp)       => ast = new MethodAST(contextRef, exp.name, _toAst(exp.arguments));
  visitCallMember(CallMember exp)     => ast = new MethodAST(visit(exp.object), exp.name, _toAst(exp.arguments));

  visitAccessScope(AccessScope exp)   => ast = new FieldReadAST(contextRef, exp.name);
  visitAccessMember(AccessMember exp) => ast = new FieldReadAST(visit(exp.object), exp.name);
  visitBinary(Binary exp)             => ast = new PureFunctionAST(exp.operation,
                                                                   _operationToFunction(exp.operation),
                                                                   [visit(exp.left), visit(exp.right)]);
  visitPrefix(Prefix exp)             => ast = new PureFunctionAST(exp.operation,
                                                                   _operationToFunction(exp.operation),
                                                                   [visit(exp.expression)]);
  visitConditional(Conditional exp)   => ast = new PureFunctionAST('?:', _operation_ternary,
                                                                   [visit(exp.condition), visit(exp.yes), visit(exp.no)]);
  visitAccessKeyed(AccessKeyed exp)   => ast = new PureFunctionAST('[]', _operation_bracket,
                                                                   [visit(exp.object), visit(exp.key)]);

  visitLiteralPrimitive(LiteralPrimitive exp) => ast = new ConstantAST(exp.value);
  visitLiteralString(LiteralString exp)       => ast = new ConstantAST(exp.value);

  visitLiteralArray(LiteralArray exp) {
    List<AST> items = _toAst(exp.elements);
    ast = new PureFunctionAST('[${items.join(', ')}]', new _ArrayFn(), items);
  }

  visitLiteralObject(LiteralObject exp) {
    List<String> keys = exp.keys;
    List<AST> values = _toAst(exp.values);
    assert(keys.length == values.length);
    List<String> kv = [];
    for(var i = 0; i < keys.length; i++) {
      kv.add('${keys[i]}: ${values[i]}');
    }
    ast = new PureFunctionAST('{${kv.join(', ')}}', new _MapFn(keys), values);
  }

  visitFilter(Filter exp) {
    Function filterFunction = exp.function;
    List<AST> args = [new CollectionAST(visit(exp.expression))];
    args.addAll(_toAst(exp.arguments).map((ast) => new CollectionAST(ast)));
    ast = new PureFunctionAST('|${exp.name}', new _FilterWrapper(exp.function, args.length), args);
  }

  // TODO(misko): this is a corner case. Choosing not to implement for now.
  visitCallFunction(CallFunction exp) => _notSupported("function's returing functions");
  visitAssign(Assign exp) => _notSupported('assignement');
  visitLiteral(Literal exp) => _notSupported('literal');
  visitExpression(Expression exp) => _notSupported('?');
  visitChain(Chain exp) => _notSupported(';');

  _notSupported(String name) {
    throw new StateError("Can not watch expression containing '$name'.");
  }
}

_operationToFunction(String operation) {
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
_operation_subtract(left, right)               => left - right;
_operation_multiply(left, right)               => left * right;
_operation_divide(left, right)                 => left / right;
_operation_divide_int(left, right)             => left ~/ right;
_operation_remainder(left, right)              => left % right;
_operation_equals(left, right)                 => left == right;
_operation_not_equals(left, right)             => left != right;
_operation_less_then(left, right)              => left < right;
_operation_greater_then(left, right)           => left > right;
_operation_less_or_equals_then(left, right)    => left <= right;
_operation_greater_or_equals_then(left, right) => left >= right; 
_operation_power(left, right)                  => left ^ right;
_operation_bitwise_and(left, right)            => left & right;
// TODO(misko): these should short circuit the evaluation.
_operation_logical_and(left, right)            => toBool(left) && toBool(left);
_operation_logical_or(left, right)             => toBool(left) || toBool(right);

_operation_ternary(condition, yes, no) => toBool(condition) ? yes : no;
_operation_bracket(obj, key) => obj == null ? null : obj[key];

class _ArrayFn extends FunctionApply {
  apply(List args) => args;
}

class _MapFn extends FunctionApply {
  final Map map = {};
  final List<String> keys;

  _MapFn(this.keys);

  apply(List values) {
    assert(values.length == keys.length);
    for(var i = 0; i < keys.length; i++) {
      map[keys[i]] = values[i];
    }
    return map;
  }
}

class _FilterWrapper extends FunctionApply {
  final Function filterFn;
  final List args;
  final List<Watch> argsWatches;
  _FilterWrapper(this.filterFn, length):
      args = new List(length),
      argsWatches = new List(length);

  apply(List values) {
    for(var i=0; i < values.length; i++) {
      var value = values[i];
      var lastValue = args[i];
      if (!identical(value, lastValue)) {
       if (value is CollectionChangeRecord) {
         args[i] = (value as CollectionChangeRecord).iterable;
       } else {
         args[i] = value;
       }
      }
    }
    var value = Function.apply(filterFn, args);
    if (value is Iterable) {
      // Since filters are pure we can guarantee that this well never change.
      // By wrapping in UnmodifiableListView we can hint to the dirty checker and
      // short circuit the iterator.
      value = new UnmodifiableListView(value);
    }
    return value;
  }
}
