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
      expect(interpolate('Hello {{name}}!').expression)
          .toEqual('"Hello "+(name|stringify)+"!"');
      expect(interpolate('a{{b}}C').expression)
          .toEqual('"a"+(b|stringify)+"C"');
      expect(interpolate('a{{b}}').expression).toEqual('"a"+(b|stringify)');
      expect(interpolate('{{a}}b').expression).toEqual('(a|stringify)+"b"');
      expect(interpolate('{{b}}').expression).toEqual('(b|stringify)');
      expect(interpolate('{{b}}+{{c}}').expression)
          .toEqual('(b|stringify)+"+"+(c|stringify)');
      expect(interpolate('{{b}}x{{c}}').expression)
          .toEqual('(b|stringify)+"x"+(c|stringify)');
    });

    it('should return expression bindings', (Interpolate interpolate) {
      expect(interpolate('Hello {{name}}').bindingExpressions).toEqual(['name']);
      expect(interpolate('a{{b}}C').bindingExpressions)
          .toEqual(['b']);
      expect(interpolate('{{b}}x{{c}}').bindingExpressions).toEqual(['b', 'c']);
    });

    it('should Parse Multiline', (Interpolate interpolate) {
      expect(interpolate("X\nY{{A\n+B}}C\nD").expression)
      .toEqual('"X\nY"+(A\n+B|stringify)+"C\nD"');
    });

    it('should escape double quotes', (Interpolate interpolate) {
      expect(interpolate(r'"{{a}}').expression).toEqual(r'"\""+(a|stringify)');
      expect(interpolate(r'\"{{a}}').expression).toEqual(r'"\\\""+(a|stringify)');
    });
  });
}
