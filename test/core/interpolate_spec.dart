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

    it('should suppress falsy objects', (Interpolate $interpolate) {
      expect($interpolate('{{undefined}}')([null])).toEqual('');
      expect($interpolate('{{undefined+undefined}}')([null])).toEqual('');
      expect($interpolate('{{null}}')([null])).toEqual('');
      expect($interpolate('{{a.b}}')([null])).toEqual('');
    });

    it('should jsonify objects', (Interpolate $interpolate) {
      expect($interpolate('{{ {} }}')([{}])).toEqual('{}');
      expect($interpolate('{{ true }}')([true])).toEqual('true');
      expect($interpolate('{{ false }}')([false])).toEqual('false');
    });


    it('should return interpolation function', (Interpolate $interpolate, Scope rootScope) {
      rootScope.context['name'] = 'Misko';
      var fn = $interpolate('Hello {{name}}!');
      expect(fn(['Misko'])).toEqual('Hello Misko!');
    });


    it('should ignore undefined model', (Interpolate $interpolate) {
      expect($interpolate("Hello {{'World' + foo}}")(['World'])).toEqual('Hello World');
    });


    it('should use toString to conver objects to string', (Interpolate $interpolate, Scope rootScope) {
      expect($interpolate("Hello, {{obj}}!")([new ToStringableObject()])).toEqual('Hello, World!');
    });


    describe('parseBindings', () {
      it('should Parse Text With No Bindings', (Interpolate $interpolate) {
        var parts = $interpolate("a").separators;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("a");
      });

      it('should Parse Empty Text', (Interpolate $interpolate) {
        var parts = $interpolate("").separators;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("");
      });

      it('should Parse Inner Binding', (Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}C").separators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("a");
        expect(parts[1]).toEqual("C");
      });

      it('should Parse Ending Binding', (Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}").separators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("a");
        expect(parts[1]).toEqual("");
      });

      it('should Parse Begging Binding', (Interpolate $interpolate) {
        var parts = $interpolate("{{b}}c").separators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("c");
      });

      it('should Parse Loan Binding', (Interpolate $interpolate) {
        var parts = $interpolate("{{b}}").separators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("");
      });

      it('should Parse Two Bindings', (Interpolate $interpolate) {
        var parts = $interpolate("{{b}}{{c}}").separators;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("");
        expect(parts[2]).toEqual("");
      });

      it('should Parse Two Bindings With Text In Middle', (Interpolate $interpolate) {
        var parts = $interpolate("{{b}}x{{c}}").separators;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("x");
        expect(parts[2]).toEqual("");
      });

      it('should Parse Multiline', (Interpolate $interpolate) {
        var parts = $interpolate('"X\nY{{A\n+B}}C\nD"').separators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual('"X\nY');
        expect(parts[1]).toEqual('C\nD"');
      });
    });
  });
}
