library angular.core.parser.dynamic_parser_impl;

import 'package:angular/core/parser/parser.dart' show ParserBackend;
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/core/parser/syntax.dart';
import 'package:angular/core/parser/characters.dart';

class DynamicParserImpl {
  final ParserBackend backend;
  final String input;
  final List<Token> tokens;
  int index = 0;

  DynamicParserImpl(Lexer lexer, this.backend, String input)
      : this.input = input, tokens = lexer.call(input);

  Token get peek => index < tokens.length ? tokens[index] : Token.EOF;

  parseChain() {
    bool isChain = false;
    while (optionalCharacter($SEMICOLON)) {
      isChain = true;
    }
    List expressions = [];
    while (index < tokens.length) {
      if (peek.isCharacter($RPAREN) ||
          peek.isCharacter($RBRACE) ||
          peek.isCharacter($RBRACKET)) {
        error('Unconsumed token $peek');
      }
      var expr = parseFilter();
      expressions.add(expr);
      while (optionalCharacter($SEMICOLON)) {
        isChain = true;
      }
      if (isChain && expr is Filter) {
        error('Cannot have a filter in a chain');
      }
    }
    return (expressions.length == 1)
        ? expressions.first
        : backend.newChain(expressions);
  }

  parseFilter() {
    var result = parseExpression();
    while (optionalOperator('|')) {
      String name = expectIdentifierOrKeyword();
      List arguments = [];
      while (optionalCharacter($COLON)) {
        // TODO(kasperl): Is this really supposed to be expressions?
        arguments.add(parseExpression());
      }
      result = backend.newFilter(result, name, arguments);
    }
    return result;
  }

  parseExpression() {
    int start = peek.index;
    var result = parseConditional();
    while (peek.isOperator('=')) {
      if (!backend.isAssignable(result)) {
        int end = (index < tokens.length) ? peek.index : input.length;
        String expression = input.substring(start, end);
        error('Expression $expression is not assignable');
      }
      expectOperator('=');
      result = backend.newAssign(result, parseConditional());
    }
    return result;
  }

  parseConditional() {
    int start = peek.index;
    var result = parseLogicalOr();
    if (optionalOperator('?')) {
      var yes = parseExpression();
      if (!optionalCharacter($COLON)) {
        int end = (index < tokens.length) ? peek.index : input.length;
        String expression = input.substring(start, end);
        error('Conditional expression $expression requires all 3 expressions');
      }
      var no = parseExpression();
      result = backend.newConditional(result, yes, no);
    }
    return result;
  }

  parseLogicalOr() {
    // '||'
    var result = parseLogicalAnd();
    while (optionalOperator('||')) {
      result = backend.newBinaryLogicalOr(result, parseLogicalAnd());
    }
    return result;
  }

  parseLogicalAnd() {
    // '&&'
    var result = parseEquality();
    while (optionalOperator('&&')) {
      result = backend.newBinaryLogicalAnd(result, parseEquality());
    }
    return result;
  }

  parseEquality() {
    // '==','!='
    var result = parseRelational();
    while (true) {
      if (optionalOperator('==')) {
        result = backend.newBinaryEqual(result, parseRelational());
      } else if (optionalOperator('!=')) {
        result = backend.newBinaryNotEqual(result, parseRelational());
      } else {
        return result;
      }
    }
  }

  parseRelational() {
    // '<', '>', '<=', '>='
    var result = parseAdditive();
    while (true) {
      if (optionalOperator('<')) {
        result = backend.newBinaryLessThan(result, parseAdditive());
      } else if (optionalOperator('>')) {
        result = backend.newBinaryGreaterThan(result, parseAdditive());
      } else if (optionalOperator('<=')) {
        result = backend.newBinaryLessThanEqual(result, parseAdditive());
      } else if (optionalOperator('>=')) {
        result = backend.newBinaryGreaterThanEqual(result, parseAdditive());
      } else {
        return result;
      }
    }
  }

  parseAdditive() {
    // '+', '-'
    var result = parseMultiplicative();
    while (true) {
      if (optionalOperator('+')) {
        result = backend.newBinaryPlus(result, parseMultiplicative());
      } else if (optionalOperator('-')) {
        result = backend.newBinaryMinus(result, parseMultiplicative());
      } else {
        return result;
      }
    }
  }

  parseMultiplicative() {
    // '*', '%', '/', '~/'
    var result = parsePrefix();
    while (true) {
      if (optionalOperator('*')) {
        result = backend.newBinaryMultiply(result, parsePrefix());
      } else if (optionalOperator('%')) {
        result = backend.newBinaryModulo(result, parsePrefix());
      } else if (optionalOperator('/')) {
        result = backend.newBinaryDivide(result, parsePrefix());
      } else if (optionalOperator('~/')) {
        result = backend.newBinaryTruncatingDivide(result, parsePrefix());
      } else {
        return result;
      }
    }
  }

  parsePrefix() {
    if (optionalOperator('+')) {
      // TODO(kasperl): This is different than the original parser.
      return backend.newPrefixPlus(parsePrefix());
    } else if (optionalOperator('-')) {
      return backend.newPrefixMinus(parsePrefix());
    } else if (optionalOperator('!')) {
      return backend.newPrefixNot(parsePrefix());
    } else {
      return parseAccessOrCallMember();
    }
  }

  parseAccessOrCallMember() {
    var result = parsePrimary();
    while (true) {
      if (optionalCharacter($PERIOD)) {
        String name = expectIdentifierOrKeyword();
        if (optionalCharacter($LPAREN)) {
          List arguments = parseExpressionList($RPAREN);
          expectCharacter($RPAREN);
          result = backend.newCallMember(result, name, arguments);
        } else {
          result = backend.newAccessMember(result, name);
        }
      } else if (optionalCharacter($LBRACKET)) {
        var key = parseExpression();
        expectCharacter($RBRACKET);
        result = backend.newAccessKeyed(result, key);
      } else if (optionalCharacter($LPAREN)) {
        List arguments = parseExpressionList($RPAREN);
        expectCharacter($RPAREN);
        result = backend.newCallFunction(result, arguments);
      } else {
        return result;
      }
    }
  }

  parsePrimary() {
    if (optionalCharacter($LPAREN)) {
      var result = parseFilter();
      expectCharacter($RPAREN);
      return result;
    } else if (peek.isKeywordNull || peek.isKeywordUndefined) {
      advance();
      return backend.newLiteralNull();
    } else if (peek.isKeywordTrue) {
      advance();
      return backend.newLiteralBoolean(true);
    } else if (peek.isKeywordFalse) {
      advance();
      return backend.newLiteralBoolean(false);
    } else if (optionalCharacter($LBRACKET)) {
      List elements = parseExpressionList($RBRACKET);
      expectCharacter($RBRACKET);
      return backend.newLiteralArray(elements);
    } else if (peek.isCharacter($LBRACE)) {
      return parseObject();
    } else if (peek.isIdentifier) {
      return parseAccessOrCallScope();
    } else if (peek.isNumber) {
      num value = peek.toNumber();
      advance();
      return backend.newLiteralNumber(value);
    } else if (peek.isString) {
      String value = peek.toString();
      advance();
      return backend.newLiteralString(value);
    } else if (index >= tokens.length) {
      throw 'Unexpected end of expression: $input';
    } else {
      error('Unexpected token $peek');
    }
  }

  parseAccessOrCallScope() {
    String name = expectIdentifierOrKeyword();
    if (!optionalCharacter($LPAREN)) return backend.newAccessScope(name);
    List arguments = parseExpressionList($RPAREN);
    expectCharacter($RPAREN);
    return backend.newCallScope(name, arguments);
  }

  parseObject() {
    List<String> keys = [];
    List values = [];
    expectCharacter($LBRACE);
    if (!optionalCharacter($RBRACE)) {
      do {
        String key = expectIdentifierOrKeywordOrString();
        keys.add(key);
        expectCharacter($COLON);
        values.add(parseExpression());
      } while (optionalCharacter($COMMA));
      expectCharacter($RBRACE);
    }
    return backend.newLiteralObject(keys, values);
  }

  List parseExpressionList(int terminator) {
    List result = [];
    if (!peek.isCharacter(terminator)) {
      do {
        result.add(parseExpression());
       } while (optionalCharacter($COMMA));
    }
    return result;
  }

  bool optionalCharacter(int code) {
    if (peek.isCharacter(code)) {
      advance();
      return true;
    } else {
      return false;
    }
  }

  bool optionalOperator(String operator) {
    if (peek.isOperator(operator)) {
      advance();
      return true;
    } else {
      return false;
    }
  }

  void expectCharacter(int code) {
    if (optionalCharacter(code)) return;
    error('Missing expected ${new String.fromCharCode(code)}');
  }

  void expectOperator(String operator) {
    if (optionalOperator(operator)) return;
    error('Missing expected operator $operator');
  }

  String expectIdentifierOrKeyword() {
    if (!peek.isIdentifier && !peek.isKeyword) {
      error('Unexpected token $peek, expected identifier or keyword');
    }
    String result = peek.toString();
    advance();
    return result;
  }

  String expectIdentifierOrKeywordOrString() {
    if (!peek.isIdentifier && !peek.isKeyword && !peek.isString) {
      error('Unexpected token $peek, expected identifier, keyword, or string');
    }
    String result = peek.toString();
    advance();
    return result;
  }

  void advance() {
    index++;
  }

  void error(message) {
    String location = (index < tokens.length)
        ? 'at column ${tokens[index].index + 1} in'
        : 'the end of the expression';
    throw 'Parser Error: $message $location [$input]';
  }
}
