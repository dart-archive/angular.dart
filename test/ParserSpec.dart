import '_specs.dart';

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
    // New test case
    it('should tokenize a simple identifier', () {
      var tokens = Parser.lex("j");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, 'j');
    });

    // New test case
    it('should tokenize a dotted identifier', () {
      var tokens = Parser.lex("j.k");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, 'j.k');
    });

    it('should tokenize an operator', () {
      var tokens = Parser.lex('j-k');
      expect(tokens.length).toEqual(3);
      expect(tokens[1]).toBeToken(1, '-');
    });

    it('should tokenize an indexed operator', () {
      var tokens = Parser.lex('j[k]');
      expect(tokens.length).toEqual(4);
      expect(tokens[1]).toBeToken(1, '[');
    });

    it('should tokenize numbers', () {
      var tokens = Parser.lex('88');
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, '88');
    });

    it('should tokenize numbers within index ops', () {
      expect(Parser.lex('a[22]')[2]).toBeToken(2, '22');
    });

    it('should tokenize simple quoted strings', () {
      expect(Parser.lex('"a"')[0]).toBeToken(0, '"a"');
    });

    it('should tokenize quoted strings with escaped quotes', () {
      expect(Parser.lex('"a\\""')[0]).toBeToken(0, '"a\\""');
    });

    it('should tokenize a string', () {
      var tokens = Parser.lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'j');

      i++;
      expect(tokens[i]).toBeToken(1, '-');

      i++;
      expect(tokens[i]).toBeToken(2, 'a.bc');

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
      var tokens = Parser.lex("undefined");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'undefined');
      expect(tokens[i].fn(null, null, null)).toEqual(null);
    });

  });
}