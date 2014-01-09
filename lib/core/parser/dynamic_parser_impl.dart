library angular.core.parser.dynamic_parser_impl;

import 'package:angular/core/parser/parser.dart' show ParserBackend;
import 'package:angular/core/parser/lexer.dart';

class DynamicParserImpl {
  static Token EOF = new Token(-1, null);
  final ParserBackend backend;
  final String input;
  final List<Token> tokens;
  int index = 0;

  DynamicParserImpl(Lexer lexer, this.backend, String input)
      : this.input = input, tokens = lexer.call(input);

  Token get peek {
    return (index < tokens.length) ? tokens[index] : EOF;
  }

  parseChain() {
    while (optional(';'));
    List expressions = [];
    while (index < tokens.length) {
      if (peek.text == ')' || peek.text == '}' || peek.text == ']') {
        error('Unconsumed token ${peek.text}');
      }
      expressions.add(parseFilter());
      while (optional(';'));
    }
    return (expressions.length == 1)
        ? expressions.first
        : backend.newChain(expressions);
  }

  parseFilter() {
    var result = parseExpression();
    while (optional('|')) {
      String name = peek.text;  // TODO(kasperl): Restrict to identifier?
      advance();
      List arguments = [];
      while (optional(':')) {
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
    while (peek.text == '=') {
      if (!backend.isAssignable(result)) {
        int end = (index < tokens.length) ? peek.index : input.length;
        String expression = input.substring(start, end);
        error('Expression $expression is not assignable');
      }
      expect('=');
      result = backend.newAssign(result, parseConditional());
    }
    return result;
  }

  parseConditional() {
    int start = peek.index;
    var result = parseLogicalOr();
    if (optional('?')) {
      var yes = parseExpression();
      if (!optional(':')) {
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
    while (optional('||')) {
      result = backend.newBinaryLogicalOr(result, parseLogicalAnd());
    }
    return result;
  }

  parseLogicalAnd() {
    // '&&'
    var result = parseEquality();
    while (optional('&&')) {
      result = backend.newBinaryLogicalAnd(result, parseEquality());
    }
    return result;
  }

  parseEquality() {
    // '==','!='
    var result = parseRelational();
    while (true) {
      if (optional('==')) {
        result = backend.newBinaryEqual(result, parseRelational());
      } else if (optional('!=')) {
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
      if (optional('<')) {
        result = backend.newBinaryLessThan(result, parseAdditive());
      } else if (optional('>')) {
        result = backend.newBinaryGreaterThan(result, parseAdditive());
      } else if (optional('<=')) {
        result = backend.newBinaryLessThanEqual(result, parseAdditive());
      } else if (optional('>=')) {
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
      if (optional('+')) {
        result = backend.newBinaryPlus(result, parseMultiplicative());
      } else if (optional('-')) {
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
      if (optional('*')) {
        result = backend.newBinaryMultiply(result, parsePrefix());
      } else if (optional('%')) {
        result = backend.newBinaryModulo(result, parsePrefix());
      } else if (optional('/')) {
        result = backend.newBinaryDivide(result, parsePrefix());
      } else if (optional('~/')) {
        result = backend.newBinaryTruncatingDivide(result, parsePrefix());
      } else {
        return result;
      }
    }
  }

  parsePrefix() {
    if (optional('+')) {
      // TODO(kasperl): This is different than the original parser.
      return backend.newPrefixPlus(parsePrefix());
    } else if (optional('-')) {
      return backend.newPrefixMinus(parsePrefix());
    } else if (optional('!')) {
      return backend.newPrefixNot(parsePrefix());
    } else {
      return parseAccessOrCallMember();
    }
  }

  parseAccessOrCallMember() {
    var result = parsePrimary();
    while (true) {
      if (optional('.')) {
        // TODO(kasperl): Check that this is an identifier. Are keywords okay?
        String name = peek.text;
        advance();
        if (optional('(')) {
          List arguments = parseExpressionList(')');
          expect(')');
          result = backend.newCallMember(result, name, arguments);
        } else {
          result = backend.newAccessMember(result, name);
        }
      } else if (optional('[')) {
        var key = parseExpression();
        expect(']');
        result = backend.newAccessKeyed(result, key);
      } else if (optional('(')) {
        List arguments = parseExpressionList(')');
        expect(')');
        result = backend.newCallFunction(result, arguments);
      } else {
        return result;
      }
    }
  }

  parsePrimary() {
    if (optional('(')) {
      var result = parseFilter();
      expect(')');
      return result;
    } else if (optional('null') || optional('undefined')) {
      return backend.newLiteralNull();
    } else if (optional('true')) {
      return backend.newLiteralBoolean(true);
    } else if (optional('false')) {
      return backend.newLiteralBoolean(false);
    } else if (optional('[')) {
      List elements = parseExpressionList(']');
      expect(']');
      return backend.newLiteralArray(elements);
    } else if (peek.text == '{') {
      return parseObject();
    } else if (peek.key != null) {
      return parseAccessOrCallScope();
    } else if (peek.value != null) {
      var value = peek.value;
      advance();
      return (value is num)
          ? backend.newLiteralNumber(value)
          : backend.newLiteralString(value);
    } else if (index >= tokens.length) {
      throw 'Unexpected end of expression: $input';
    } else {
      error('Unexpected token ${peek.text}');
    }
  }

  parseAccessOrCallScope() {
    String name = peek.key;
    advance();
    if (!optional('(')) return backend.newAccessScope(name);
    List arguments = parseExpressionList(')');
    expect(')');
    return backend.newCallScope(name, arguments);
  }

  parseObject() {
    List<String> keys = [];
    List values = [];
    expect('{');
    if (peek.text != '}') {
      do {
        // TODO(kasperl): Stricter checking. Only allow identifiers
        // and strings as keys. Maybe also keywords?
        var value = peek.value;
        keys.add(value is String ? value : peek.text);
        advance();
        expect(':');
        values.add(parseExpression());
      } while (optional(','));
    }
    expect('}');
    return backend.newLiteralObject(keys, values);
  }

  List parseExpressionList(String terminator) {
    List result = [];
    if (peek.text != terminator) {
      do {
        result.add(parseExpression());
       } while (optional(','));
    }
    return result;
  }

  bool optional(text) {
    if (peek.text == text) {
      advance();
      return true;
    } else {
      return false;
    }
  }

  void expect(text) {
    if (peek.text == text) {
      advance();
    } else {
      error('Missing expected $text');
    }
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
