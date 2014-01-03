library angular.core.new_parser;

import 'package:angular/core/module.dart' show FilterMap;
import 'package:angular/core/parser/parser_library.dart' show Lexer;
import 'package:angular/core/parser/new_syntax.dart';
import 'package:angular/core/parser/new_parser_impl.dart' show ParserImpl;

class Parser {
  final Lexer lexer;
  final ParserBackend backend;
  Parser(this.lexer, this.backend);

  parse(String input) {
    ParserImpl parser = new ParserImpl(lexer, backend, input);
    return parser.parseChain();
  }
}

class ParserBackend {
  bool isAssignable(var expression)
      => expression is Assignable;

  newChain(List expressions)
     => new Chain(expressions);
  newFilter(var expression, String name, List arguments)
     => new Filter(expression, name, arguments);

  newAssign(var target, var value)
     => new Assign(target, value);
  newConditional(var condition, var yes, var no)
     => new Conditional(condition, yes, no);

  newAccessScope(String name)
      => new AccessScope(name);
  newAccessMember(var object, String name)
      => new AccessMember(object, name);
  newAccessKeyed(var object, var key)
      => new AccessKeyed(object, key);

  newCallScope(String name, List arguments)
      => new CallScope(name, arguments);
  newCallFunction(var function, List arguments)
      => new CallFunction(function, arguments);
  newCallMember(var object, String name, List arguments)
      => new CallMember(object, name, arguments);

  newPrefix(String operation, var expression)
      => new Prefix(operation, expression);
  newPrefixPlus(var expression)
      => expression;
  newPrefixMinus(var expression)
      => newBinaryMinus(newLiteralZero(), expression);
  newPrefixNot(var expression)
      => newPrefix('!', expression);

  newBinary(String operation, var left, var right)
      => new Binary(operation, left, right);
  newBinaryPlus(var left, var right)
      => newBinary('+', left, right);
  newBinaryMinus(var left, var right)
      => newBinary('-', left, right);
  newBinaryMultiply(var left, var right)
      => newBinary('*', left, right);
  newBinaryDivide(var left, var right)
      => newBinary('/', left, right);
  newBinaryModulo(var left, var right)
      => newBinary('%', left, right);
  newBinaryTruncatingDivide(var left, var right)
      => newBinary('~/', left, right);
  newBinaryLogicalAnd(var left, var right)
      => newBinary('&&', left, right);
  newBinaryLogicalOr(var left, var right)
      => newBinary('||', left, right);
  newBinaryEqual(var left, var right)
      => newBinary('==', left, right);
  newBinaryNotEqual(var left, var right)
      => newBinary('!=', left, right);
  newBinaryLessThan(var left, var right)
      => newBinary('<', left, right);
  newBinaryGreaterThan(var left, var right)
      => newBinary('>', left, right);
  newBinaryLessThanEqual(var left, var right)
      => newBinary('<=', left, right);
  newBinaryGreaterThanEqual(var left, var right)
      => newBinary('>=', left, right);

  newLiteralPrimitive(var value)
      => new LiteralPrimitive(value);
  newLiteralArray(List elements)
      => new LiteralArray(elements);
  newLiteralObject(List<String> keys, List values)
      => new LiteralObject(keys, values);
  newLiteralNull()
      => newLiteralPrimitive(null);
  newLiteralZero()
      => newLiteralNumber(0);
  newLiteralBoolean(bool value)
      => newLiteralPrimitive(value);
  newLiteralNumber(num value)
      => newLiteralPrimitive(value);
  newLiteralString(String value)
      => new LiteralString(value);
}

class ParserBackendWithValidation extends ParserBackend {
  final FilterMap _filters;
  ParserBackendWithValidation(this._filters);
  newFilter(var expression, String name, List arguments) {
    Function filter = _filters(name);
    return super.newFilter(expression, name, arguments);
  }
}
