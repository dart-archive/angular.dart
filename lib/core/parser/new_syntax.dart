library angular.core.new_parser.new_syntax;

import 'package:angular/core/parser/new_unparser.dart' show Unparser;
export 'package:angular/core/parser/new_parser.dart';

abstract class Visitor {
  visit(Expression expression)
      => expression.accept(this);

  visitExpression(Expression expression)
      => null;
  visitChain(Chain expression)
      => visitExpression(expression);
  visitFilter(Filter expression)
      => visitExpression(expression);

  visitAssign(Assign expression)
      => visitExpression(expression);
  visitConditional(Conditional expression)
      => visitExpression(expression);

  visitAccessScope(AccessScope expression)
      => visitExpression(expression);
  visitAccessMember(AccessMember expression)
      => visitExpression(expression);
  visitAccessKeyed(AccessKeyed expression)
      => visitExpression(expression);

  visitCallScope(CallScope expression)
      => visitExpression(expression);
  visitCallFunction(CallFunction expression)
      => visitExpression(expression);
  visitCallMember(CallMember expression)
      => visitExpression(expression);

  visitBinary(Binary expression)
      => visitExpression(expression);

  visitPrefix(Prefix expression)
      => visitExpression(expression);

  visitLiteral(Literal expression)
      => visitExpression(expression);
  visitLiteralPrimitive(LiteralPrimitive expression)
      => visitLiteral(expression);
  visitLiteralString(LiteralString expression)
      => visitLiteral(expression);
  visitLiteralArray(LiteralArray expression)
      => visitLiteral(expression);
  visitLiteralObject(LiteralObject expression)
      => visitLiteral(expression);
}

abstract class Expression {
  accept(Visitor visitor);
  String toString() => Unparser.unparse(this);
}

abstract class Assignable implements Expression {
}

class Chain extends Expression {
  final List<Expression> expressions;
  Chain(this.expressions);
  accept(Visitor visitor) => visitor.visitChain(this);
}

class Filter extends Expression {
  final Expression expression;
  final String name;
  final List<Expression> arguments;
  Filter(this.expression, this.name, this.arguments);
  accept(Visitor visitor) => visitor.visitFilter(this);
}

class Assign extends Expression {
  final Expression target;
  final Expression value;
  Assign(this.target, this.value);
  accept(Visitor visitor) => visitor.visitAssign(this);
}

class Conditional extends Expression {
  final Expression condition;
  final Expression yes;
  final Expression no;
  Conditional(this.condition, this.yes, this.no);
  accept(Visitor visitor) => visitor.visitConditional(this);
}

class AccessScope extends Expression implements Assignable {
  final String name;
  AccessScope(this.name);
  accept(Visitor visitor) => visitor.visitAccessScope(this);
}

class AccessMember extends Expression implements Assignable {
  final Expression object;
  final String name;
  AccessMember(this.object, this.name);
  accept(Visitor visitor) => visitor.visitAccessMember(this);
}

class AccessKeyed extends Expression implements Assignable {
  final Expression object;
  final Expression key;
  AccessKeyed(this.object, this.key);
  accept(Visitor visitor) => visitor.visitAccessKeyed(this);
}

class CallScope extends Expression {
  final String name;
  final List<Expression> arguments;
  CallScope(this.name, this.arguments);
  accept(Visitor visitor) => visitor.visitCallScope(this);
}

class CallFunction extends Expression {
  final Expression function;
  final List<Expression> arguments;
  CallFunction(this.function, this.arguments);
  accept(Visitor visitor) => visitor.visitCallFunction(this);
}

class CallMember extends Expression {
  final Expression object;
  final String name;
  final List<Expression> arguments;
  CallMember(this.object, this.name, this.arguments);
  accept(Visitor visitor) => visitor.visitCallMember(this);
}

class Binary extends Expression {
  final String operation;
  final Expression left;
  final Expression right;
  Binary(this.operation, this.left, this.right);
  accept(Visitor visitor) => visitor.visitBinary(this);
}

class Prefix extends Expression {
  final String operation;
  final Expression expression;
  Prefix(this.operation, this.expression);
  accept(Visitor visitor) => visitor.visitPrefix(this);
}

abstract class Literal extends Expression {
}

class LiteralPrimitive extends Literal {
  final value;
  LiteralPrimitive(this.value);
  accept(Visitor visitor) => visitor.visitLiteralPrimitive(this);
}

class LiteralString extends Literal {
  final String value;
  LiteralString(this.value);
  accept(Visitor visitor) => visitor.visitLiteralString(this);
}

class LiteralArray extends Literal {
  final List<Expression> elements;
  LiteralArray(this.elements);
  accept(Visitor visitor) => visitor.visitLiteralArray(this);
}

class LiteralObject extends Literal {
  final List<String> keys;
  final List<Expression> values;
  LiteralObject(this.keys, this.values);
  accept(Visitor visitor) => visitor.visitLiteralObject(this);
}
