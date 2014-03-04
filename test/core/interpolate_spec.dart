library interpolate_spec;

import '../_specs.dart';

class ToStringableObject {
  toString() => 'World';
}

main() {
  describe('\$interpolate', () {

    it('should return undefined when there are no bindings and textOnly is set to true',
        inject((Interpolate $interpolate) {
      expect($interpolate('some text', true)).toBe(null);
    }));

    it('should suppress falsy objects', inject((Interpolate $interpolate) {
      expect($interpolate('{{undefined}}')([null])).toEqual('');
      expect($interpolate('{{undefined+undefined}}')([null])).toEqual('');
      expect($interpolate('{{null}}')([null])).toEqual('');
      expect($interpolate('{{a.b}}')([null])).toEqual('');
    }));

    it('should jsonify objects', inject((Interpolate $interpolate) {
      expect($interpolate('{{ {} }}')([{}])).toEqual('{}');
      expect($interpolate('{{ true }}')([true])).toEqual('true');
      expect($interpolate('{{ false }}')([false])).toEqual('false');
    }));


    it('should return interpolation function', inject((Interpolate $interpolate, Scope rootScope) {
      rootScope.context['name'] = 'Misko';
      var fn = $interpolate('Hello {{name}}!');
      expect(fn(['Misko'])).toEqual('Hello Misko!');
    }));


    it('should ignore undefined model', inject((Interpolate $interpolate) {
      expect($interpolate("Hello {{'World' + foo}}")(['World'])).toEqual('Hello World');
    }));


    it('should use toString to conver objects to string', inject((Interpolate $interpolate, Scope rootScope) {
      expect($interpolate("Hello, {{obj}}!")([new ToStringableObject()])).toEqual('Hello, World!');
    }));


    describe('parseBindings', () {
      it('should Parse Text With No Bindings', inject((Interpolate $interpolate) {
        var parts = $interpolate("a").seperators;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("a");
      }));

      it('should Parse Empty Text', inject((Interpolate $interpolate) {
        var parts = $interpolate("").seperators;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("");
      }));

      it('should Parse Inner Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}C").seperators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("a");
        expect(parts[1]).toEqual("C");
      }));

      it('should Parse Ending Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}").seperators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("a");
        expect(parts[1]).toEqual("");
      }));

      it('should Parse Begging Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}c").seperators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("c");
      }));

      it('should Parse Loan Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}").seperators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("");
      }));

      it('should Parse Two Bindings', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}{{c}}").seperators;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("");
        expect(parts[2]).toEqual("");
      }));

      it('should Parse Two Bindings With Text In Middle', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}x{{c}}").seperators;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual("");
        expect(parts[1]).toEqual("x");
        expect(parts[2]).toEqual("");
      }));

      it('should Parse Multiline', inject((Interpolate $interpolate) {
        var parts = $interpolate('"X\nY{{A\n+B}}C\nD"').seperators;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual('"X\nY');
        expect(parts[1]).toEqual('C\nD"');
      }));
    });
  });
}
