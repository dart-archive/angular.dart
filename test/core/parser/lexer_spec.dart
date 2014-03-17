library lexer_spec;

import '../../_specs.dart';

class LexerExpect extends Expect {
  LexerExpect(actual) : super(actual);

  toBeToken(int index) {
    expect(actual is Token).toEqual(true);
    expect(actual.index).toEqual(index);
  }

  toBeCharacterToken(int index, String character) {
    toBeToken(index);
    expect(character.length).toEqual(1);
    expect(actual.isCharacter(character.codeUnitAt(0))).toEqual(true);
  }

  toBeIdentifierToken(int index, String text) {
    toBeToken(index);
    expect(actual.isIdentifier).toEqual(true);
    expect(actual.toString()).toEqual(text);
  }

  toBeKeywordUndefinedToken(int index) {
    toBeToken(index);
    expect(actual.isKeywordUndefined).toEqual(true);
  }

  toBeOperatorToken(int index, String operator) {
    toBeToken(index);
    expect(actual.isOperator(operator)).toEqual(true);
  }

  toBeStringToken(int index, String input, String value) {
    toBeToken(index);
    expect(actual.isString).toEqual(true);
    StringToken token = actual;
    expect(token.input).toEqual(input);
    expect(token.toString()).toEqual(value);
  }

  toBeNumberToken(int index, num value) {
    toBeToken(index);
    expect(actual.isNumber).toEqual(true);
    NumberToken token = actual;
    expect(token.toNumber()).toEqual(value);
  }
}

expect(actual) => new LexerExpect(actual);

main() {
  describe('lexer', () {
    Lexer lex;
    beforeEach((Lexer lexer) {
      lex = lexer;
    });

    // New test case
    it('should tokenize a simple identifier', () {
      List<Token> tokens = lex("j");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeIdentifierToken(0, 'j');
    });

    // New test case
    it('should tokenize a dotted identifier', () {
      List<Token> tokens = lex("j.k");
      expect(tokens.length).toEqual(3);
      expect(tokens[0]).toBeIdentifierToken(0, 'j');
      expect(tokens[1]).toBeCharacterToken(1, '.');
      expect(tokens[2]).toBeIdentifierToken(2, 'k');
    });

    it('should tokenize an operator', () {
      List<Token> tokens = lex('j-k');
      expect(tokens.length).toEqual(3);
      expect(tokens[1]).toBeOperatorToken(1, '-');
    });

    it('should tokenize an indexed operator', () {
      List<Token> tokens = lex('j[k]');
      expect(tokens.length).toEqual(4);
      expect(tokens[1]).toBeCharacterToken(1, '[');
    });

    it('should tokenize numbers', () {
      List<Token> tokens = lex('88');
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeNumberToken(0, 88);
    });

    it('should tokenize numbers within index ops', () {
      expect(lex('a[22]')[2]).toBeNumberToken(2, 22);
    });

    it('should tokenize simple quoted strings', () {
      expect(lex('"a"')[0]).toBeStringToken(0, '"a"', 'a');
    });

    it('should tokenize quoted strings with escaped quotes', () {
      expect(lex('"a\\""')[0]).toBeStringToken(0, '"a\\""', 'a"');
    });

    it('should tokenize a string', () {
      List<Token> tokens = lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
      expect(tokens[0]).toBeIdentifierToken(0, 'j');
      expect(tokens[1]).toBeOperatorToken(1, '-');
      expect(tokens[2]).toBeIdentifierToken(2, 'a');
      expect(tokens[3]).toBeCharacterToken(3, '.');
      expect(tokens[4]).toBeIdentifierToken(4, 'bc');
      expect(tokens[5]).toBeCharacterToken(6, '[');
      expect(tokens[6]).toBeNumberToken(7, 22);
      expect(tokens[7]).toBeCharacterToken(9, ']');
      expect(tokens[8]).toBeOperatorToken(10, '+');
      expect(tokens[9]).toBeNumberToken(11, 1.3);
      expect(tokens[10]).toBeOperatorToken(14, '|');
      expect(tokens[11]).toBeIdentifierToken(15, 'f');
      expect(tokens[12]).toBeCharacterToken(16, ':');
      expect(tokens[13]).toBeStringToken(17, "'a\\'c'", "a'c");
      expect(tokens[14]).toBeCharacterToken(23, ':');
      expect(tokens[15]).toBeStringToken(24, '"d\\"e"', 'd"e');
    });

    it('should tokenize undefined', () {
      List<Token> tokens = lex("undefined");
      expect(tokens[0]).toBeKeywordUndefinedToken(0);
    });

    it('should ignore whitespace', () {
      List<Token> tokens = lex("a \t \n \r b");
      expect(tokens[0]).toBeIdentifierToken(0, 'a');
      expect(tokens[1]).toBeIdentifierToken(8, 'b');
    });

    it('should tokenize quoted string', () {
      var str = "['\\'', \"\\\"\"]";
      List<Token> tokens = lex(str);
      expect(tokens[1]).toBeStringToken(1, "'\\''", "'");
      expect(tokens[3]).toBeStringToken(7, '"\\""', '"');
    });

    it('should tokenize escaped quoted string', () {
      var str = '"\\"\\n\\f\\r\\t\\v\\u00A0"';
      List<Token> tokens = lex(str);
      expect(tokens.length).toEqual(1);
      expect(tokens[0].toString()).toEqual('"\n\f\r\t\v\u00A0');
    });

    it('should tokenize unicode', () {
      List<Token> tokens = lex('"\\u00A0"');
      expect(tokens.length).toEqual(1);
      expect(tokens[0].toString()).toEqual('\u00a0');
    });

    it('should tokenize relation', () {
      List<Token> tokens = lex("! == != < > <= >=");
      expect(tokens[0]).toBeOperatorToken(0, '!');
      expect(tokens[1]).toBeOperatorToken(2, '==');
      expect(tokens[2]).toBeOperatorToken(5, '!=');
      expect(tokens[3]).toBeOperatorToken(8, '<');
      expect(tokens[4]).toBeOperatorToken(10, '>');
      expect(tokens[5]).toBeOperatorToken(12, '<=');
      expect(tokens[6]).toBeOperatorToken(15, '>=');
    });

    it('should tokenize statements', () {
      List<Token> tokens = lex("a;b;");
      expect(tokens[0]).toBeIdentifierToken(0, 'a');
      expect(tokens[1]).toBeCharacterToken(1, ';');
      expect(tokens[2]).toBeIdentifierToken(2, 'b');
      expect(tokens[3]).toBeCharacterToken(3, ';');
    });

    it('should tokenize function invocation', () {
      List<Token> tokens = lex("a()");
      expect(tokens[0]).toBeIdentifierToken(0, 'a');
      expect(tokens[1]).toBeCharacterToken(1, '(');
      expect(tokens[2]).toBeCharacterToken(2, ')');
    });

    it('should tokenize simple method invocations', () {
      List<Token> tokens = lex("a.method()");
      expect(tokens[2]).toBeIdentifierToken(2, 'method');
    });

    it('should tokenize method invocation', () {
      List<Token> tokens = lex("a.b.c (d) - e.f()");
      expect(tokens[0]).toBeIdentifierToken(0, 'a');
      expect(tokens[1]).toBeCharacterToken(1, '.');
      expect(tokens[2]).toBeIdentifierToken(2, 'b');
      expect(tokens[3]).toBeCharacterToken(3, '.');
      expect(tokens[4]).toBeIdentifierToken(4, 'c');
      expect(tokens[5]).toBeCharacterToken(6, '(');
      expect(tokens[6]).toBeIdentifierToken(7, 'd');
      expect(tokens[7]).toBeCharacterToken(8, ')');
      expect(tokens[8]).toBeOperatorToken(10, '-');
      expect(tokens[9]).toBeIdentifierToken(12, 'e');
      expect(tokens[10]).toBeCharacterToken(13, '.');
      expect(tokens[11]).toBeIdentifierToken(14, 'f');
      expect(tokens[12]).toBeCharacterToken(15, '(');
      expect(tokens[13]).toBeCharacterToken(16, ')');
    });

    it('should tokenize number', () {
      List<Token> tokens = lex("0.5");
      expect(tokens[0]).toBeNumberToken(0, 0.5);
    });

    // NOTE(deboer): NOT A LEXER TEST
    //    it('should tokenize negative number', () {
    //      List<Token> tokens = lex("-0.5");
    //      expect(tokens[0]).toBeNumberToken(0, -0.5);
    //    });

    it('should tokenize number with exponent', () {
      List<Token> tokens = lex("0.5E-10");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeNumberToken(0, 0.5E-10);
      tokens = lex("0.5E+10");
      expect(tokens[0]).toBeNumberToken(0, 0.5E+10);
    });

    it('should throws exception for invalid exponent', () {
      expect(() {
        lex("0.5E-");
      }).toThrow('Lexer Error: Invalid exponent at column 4 in expression [0.5E-]');

      expect(() {
        lex("0.5E-A");
      }).toThrow('Lexer Error: Invalid exponent at column 4 in expression [0.5E-A]');
    });

    it('should tokenize number starting with a dot', () {
      List<Token> tokens = lex(".5");
      expect(tokens[0]).toBeNumberToken(0, 0.5);
    });

    it('should throw error on invalid unicode', () {
      expect(() {
        lex("'\\u1''bla'");
      }).toThrow("Lexer Error: Invalid unicode escape [\\u1''b] at column 2 in expression ['\\u1''bla']");
    });
  });
}
