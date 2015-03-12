library utils_spec;

import '_specs.dart';
import 'package:angular/utils.dart';

main() {
  describe('relaxFnApply', () {
    it('should work with 6 arguments', () {
      var sixArgs = [1, 1, 2, 3, 5, 8];
      expect(relaxFnApply(() => "none", sixArgs)).toEqual("none");
      expect(relaxFnApply((a) => a, sixArgs)).toEqual(1);
      expect(relaxFnApply((a, b) => a + b, sixArgs)).toEqual(2);
      expect(relaxFnApply((a, b, c) => a + b + c, sixArgs)).toEqual(4);
      expect(relaxFnApply((a, b, c, d) => a + b + c + d, sixArgs)).toEqual(7);
      expect(relaxFnApply((a, b, c, d, e) => a + b + c + d + e, sixArgs)).toEqual(12);
    });

    it('should work with 0 arguments', () {
      var noArgs = [];
      expect(relaxFnApply(() => "none", noArgs)).toEqual("none");
      expect(relaxFnApply(([a]) => a, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b]) => b, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c]) => c, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d]) => d, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d, e]) => e, noArgs)).toEqual(null);
    });

    it('should fail with not enough arguments', () {
      expect(() {
        relaxFnApply((required, alsoRequired) => "happy", [1]);
      }).toThrowWith(message: 'Unknown function type, expecting 0 to 5 args.');
    });
  });

  describe('camelCase', () {
    it('should ignore non camelCase', () {
      expect(camelCase('regular')).toEqual('regular');
    });

    it('should convert snake-case', () {
      expect(camelCase('snake-case')).toEqual('snakeCase');
    });

    it('should lowercase strings', () {
      expect(camelCase('Caps-first')).toEqual('capsFirst');
    });

    it('should work on empty string', () {
      expect(camelCase('')).toEqual('');
    });
  });
}

