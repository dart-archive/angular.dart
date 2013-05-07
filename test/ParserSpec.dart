import '_specs.dart';

main() {
  describe('lexer', () {
    // New test case
    it('should tokenize a simple identifier', () {
      var tokens = Parser.lex("j");
      expect(tokens.length).toEqual(1);
      expect(tokens[0].index).toEqual(0);
      expect(tokens[0].text).toEqual('j');
    });

    // New test case
    it('should tokenize a dotted identifier', () {
      var tokens = Parser.lex("j.k");
      expect(tokens.length).toEqual(1);
      expect(tokens[0].index).toEqual(0);
      expect(tokens[0].text).toEqual('j.k');
    });

    it('should tokenize an operator', () {
      var tokens = Parser.lex('j-k');
      expect(tokens.length).toEqual(3);
      expect(tokens[1].index).toEqual(1);
      expect(tokens[1].text).toEqual('-');

    });

    xit('should tokenize an indexed operator', () {
      var tokens = Parser.lex('j[k]');
      expect(tokens.length).toEqual(4);
      expect(tokens[1].index).toEqual(1);
      expect(tokens[1].text).toEqual('[');
    });

    it('should tokenize a string', () {

      var tokens = Parser.lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
      var i = 0;
      expect(tokens[i].index).toEqual(0);
      expect(tokens[i].text).toEqual('j');

      i++;
      expect(tokens[i].index).toEqual(2);
      expect(tokens[i].text).toEqual('a.bc');

      i++;
      expect(tokens[i].index).toEqual(6);
      expect(tokens[i].text).toEqual('[');

      i++;
      expect(tokens[i].index).toEqual(7);
      expect(tokens[i].text).toEqual(22);

      i++;
      expect(tokens[i].index).toEqual(9);
      expect(tokens[i].text).toEqual(']');

      i++;
      expect(tokens[i].index).toEqual(10);
      expect(tokens[i].text).toEqual('+');

      i++;
      expect(tokens[i].index).toEqual(11);
      expect(tokens[i].text).toEqual(1.3);

      i++;
      expect(tokens[i].index).toEqual(14);
      expect(tokens[i].text).toEqual('|');

      i++;
      expect(tokens[i].index).toEqual(15);
      expect(tokens[i].text).toEqual('f');

      i++;
      expect(tokens[i].index).toEqual(16);
      expect(tokens[i].text).toEqual(':');

      i++;
      expect(tokens[i].index).toEqual(17);
      expect(tokens[i].string).toEqual("a'c");

      i++;
      expect(tokens[i].index).toEqual(23);
      expect(tokens[i].text).toEqual(':');

      i++;
      expect(tokens[i].index).toEqual(24);
      expect(tokens[i].string).toEqual('d"e');
    });
  });
}