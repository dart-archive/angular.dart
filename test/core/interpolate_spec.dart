library interpolate_spec;

import '../_specs.dart';

class ToStringableObject {
  toString() => 'World';
}

main() {
  describe('\$interpolate', () {

    it('should return undefined when there are no bindings and textOnly is set to true',
        (Interpolate $interpolate) {
      expect($interpolate('some text', true)).toBe(null);
    });

    it('should return an expression', (Interpolate $interpolate) {
      expect($interpolate('Hello {{name}}!')).toEqual('"Hello "+(name)+"!"');
      expect($interpolate('a{{b}}C')).toEqual('"a"+(b)+"C"');
      expect($interpolate('a{{b}}')).toEqual('"a"+(b)');
      expect($interpolate('{{a}}b')).toEqual('""+(a)+"b"');
      expect($interpolate('{{a}}{{b}}')).toEqual('""+(a)+""+(b)');
      expect($interpolate('{{b}}')).toEqual('""+(b)');
      expect($interpolate('{{b}}+{{c}}')).toEqual('""+(b)+"+"+(c)');
      expect($interpolate('{{b}}x{{c}}')).toEqual('""+(b)+"x"+(c)');
    });

    it('should Parse Multiline', (Interpolate $interpolate) {
      expect($interpolate("X\nY{{A\n+B}}C\nD"))
          .toEqual('"X\nY"+(A\n+B)+"C\nD"');
    });

  });
}
