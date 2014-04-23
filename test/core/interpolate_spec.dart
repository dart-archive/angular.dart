library interpolate_spec;

import '../_specs.dart';

class ToStringableObject {
  toString() => 'World';
}

main() {
  describe('interpolate', () {

    it('should return undefined when there are no bindings and textOnly is set to true',
        (Interpolate interpolate) {
      expect(interpolate('some text', true)).toBe(null);
    });

    it('should return an expression', (Interpolate interpolate) {
      expect(interpolate('Hello {{name}}!'))
          .toEqual('"Hello "+(name|stringify)+"!"');
      expect(interpolate('a{{b}}C'))
          .toEqual('"a"+(b|stringify)+"C"');
      expect(interpolate('a{{b}}')).toEqual('"a"+(b|stringify)');
      expect(interpolate('{{a}}b')).toEqual('(a|stringify)+"b"');
      expect(interpolate('{{b}}')).toEqual('(b|stringify)');
      expect(interpolate('{{b}}+{{c}}'))
          .toEqual('(b|stringify)+"+"+(c|stringify)');
      expect(interpolate('{{b}}x{{c}}'))
          .toEqual('(b|stringify)+"x"+(c|stringify)');
    });

    it('should Parse Multiline', (Interpolate interpolate) {
      expect(interpolate("X\nY{{A\n+B}}C\nD"))
      .toEqual('"X\nY"+(A\n+B|stringify)+"C\nD"');
    });

    it('should escape double quotes', (Interpolate interpolate) {
      expect(interpolate(r'"{{a}}')).toEqual(r'"\""+(a|stringify)');
      expect(interpolate(r'\"{{a}}')).toEqual(r'"\\\""+(a|stringify)');
    });
  });
}