library lexer_spec;

import '../../_specs.dart';

class LexerExpect extends Expect {
  LexerExpect(actual) : super(actual);
  toBeToken(int index, String text) {
    expect(actual is Token).toEqual(true);
    expect(actual.index).toEqual(index);
    expect(actual.text).toEqual(text);
  }
}
expect(actual) => new LexerExpect(actual);

main() {
  describe('lexer', () {
    Lexer lex;
    beforeEach(inject((Lexer lexer) {
      lex = lexer;
    }));

    // New test case
    it('should tokenize a simple identifier', () {
      var tokens = lex("j");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, 'j');
    });

    // New test case
    it('should tokenize a dotted identifier', () {
      var tokens = lex("j.k");
      expect(tokens.length).toEqual(3);
      expect(tokens[0]).toBeToken(0, 'j');
      expect(tokens[1]).toBeToken(1, '.');
      expect(tokens[2]).toBeToken(2, 'k');
    });

    it('should tokenize an operator', () {
      var tokens = lex('j-k');
      expect(tokens.length).toEqual(3);
      expect(tokens[1]).toBeToken(1, '-');
    });

    it('should tokenize an indexed operator', () {
      var tokens = lex('j[k]');
      expect(tokens.length).toEqual(4);
      expect(tokens[1]).toBeToken(1, '[');
    });

    it('should tokenize numbers', () {
      var tokens = lex('88');
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, '88');
    });

    it('should tokenize numbers within index ops', () {
      expect(lex('a[22]')[2]).toBeToken(2, '22');
    });

    it('should tokenize simple quoted strings', () {
      expect(lex('"a"')[0]).toBeToken(0, '"a"');
    });

    it('should tokenize quoted strings with escaped quotes', () {
      expect(lex('"a\\""')[0]).toBeToken(0, '"a\\""');
    });

    it('should tokenize a string', () {
      var tokens = lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'j');

      i++;
      expect(tokens[i]).toBeToken(1, '-');

      i++;
      expect(tokens[i]).toBeToken(2, 'a');

      i++;
      expect(tokens[i]).toBeToken(3, '.');

      i++;
      expect(tokens[i]).toBeToken(4, 'bc');

      i++;
      expect(tokens[i]).toBeToken(6, '[');

      i++;
      expect(tokens[i]).toBeToken(7, '22');

      i++;
      expect(tokens[i]).toBeToken(9, ']');

      i++;
      expect(tokens[i]).toBeToken(10, '+');

      i++;
      expect(tokens[i]).toBeToken(11, '1.3');

      i++;
      expect(tokens[i]).toBeToken(14, '|');

      i++;
      expect(tokens[i]).toBeToken(15, 'f');

      i++;
      expect(tokens[i]).toBeToken(16, ':');

      i++;
      expect(tokens[i]).toBeToken(17, '\'a\\\'c\'');

      i++;
      expect(tokens[i]).toBeToken(23, ':');

      i++;
      expect(tokens[i]).toBeToken(24, '"d\\"e"');
    });

    it('should tokenize undefined', () {
      var tokens = lex("undefined");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'undefined');
      expect(tokens[i].value).toEqual(null);
    });

    it('should ignore whitespace', () {
      var tokens = lex("a \t \n \r b");
      expect(tokens[0].text).toEqual('a');
      expect(tokens[1].text).toEqual('b');
    });

    it('should tokenize quoted string', () {
      var str = "['\\'', \"\\\"\"]";
      var tokens = lex(str);

      expect(tokens[1].index).toEqual(1);
      expect(tokens[1].value).toEqual("'");

      expect(tokens[3].index).toEqual(7);
      expect(tokens[3].value).toEqual('"');
    });

    it('should tokenize escaped quoted string', () {
      var str = '"\\"\\n\\f\\r\\t\\v\\u00A0"';
      var tokens = lex(str);

      expect(tokens[0].value).toEqual('"\n\f\r\t\v\u00A0');
    });

    it('should tokenize unicode', () {
      var tokens = lex('"\\u00A0"');
      expect(tokens.length).toEqual(1);
      expect(tokens[0].value).toEqual('\u00a0');
    });

    it('should tokenize relation', () {
      var tokens = lex("! == != < > <= >=");
      expect(tokens[0].text).toEqual('!');
      expect(tokens[1].text).toEqual('==');
      expect(tokens[2].text).toEqual('!=');
      expect(tokens[3].text).toEqual('<');
      expect(tokens[4].text).toEqual('>');
      expect(tokens[5].text).toEqual('<=');
      expect(tokens[6].text).toEqual('>=');
    });

    it('should tokenize statements', () {
      var tokens = lex("a;b;");
      expect(tokens[0].text).toEqual('a');
      expect(tokens[1].text).toEqual(';');
      expect(tokens[2].text).toEqual('b');
      expect(tokens[3].text).toEqual(';');
    });

    it('should tokenize function invocation', () {
      var tokens = lex("a()");
      expect(tokens[0]).toBeToken(0, 'a');
      expect(tokens[1]).toBeToken(1, '(');
      expect(tokens[2]).toBeToken(2, ')');
    });

    it('should tokenize simple method invocations', () {
      var tokens = lex("a.method()");
      expect(tokens[2]).toBeToken(2, 'method');
    });

    it('should tokenize method invocation', () {
      var tokens = lex("a.b.c (d) - e.f()");
      expect(tokens[0]).toBeToken(0, 'a');
      expect(tokens[1]).toBeToken(1, '.');
      expect(tokens[2]).toBeToken(2, 'b');
      expect(tokens[3]).toBeToken(3, '.');
      expect(tokens[4]).toBeToken(4, 'c');
      expect(tokens[5]).toBeToken(6, '(');
      expect(tokens[6]).toBeToken(7, 'd');
      expect(tokens[7]).toBeToken(8, ')');
      expect(tokens[8]).toBeToken(10, '-');
      expect(tokens[9]).toBeToken(12, 'e');
      expect(tokens[10]).toBeToken(13, '.');
      expect(tokens[11]).toBeToken(14, 'f');
      expect(tokens[12]).toBeToken(15, '(');
      expect(tokens[13]).toBeToken(16, ')');
    });

    it('should tokenize number', () {
      var tokens = lex("0.5");
      expect(tokens[0].value).toEqual(0.5);
    });

    // NOTE(deboer): NOT A LEXER TEST
    //    it('should tokenize negative number', () {
    //      var tokens = lex("-0.5");
    //      expect(tokens[0].value).toEqual(-0.5);
    //    });

    it('should tokenize number with exponent', () {
      var tokens = lex("0.5E-10");
      expect(tokens.length).toEqual(1);
      expect(tokens[0].value).toEqual(0.5E-10);
      tokens = lex("0.5E+10");
      expect(tokens[0].value).toEqual(0.5E+10);
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
      var tokens = lex(".5");
      expect(tokens[0].value).toEqual(0.5);
    });

    it('should throw error on invalid unicode', () {
      expect(() {
        lex("'\\u1''bla'");
      }).toThrow("Lexer Error: Invalid unicode escape [\\u1''b] at column 2 in expression ['\\u1''bla']");
    });
  });
}
