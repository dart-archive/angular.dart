import "_specs.dart";

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
      expect($interpolate('{{undefined}}').eval(null)).toEqual('');
      expect($interpolate('{{undefined+undefined}}').eval(null)).toEqual('');
      expect($interpolate('{{null}}').eval(null)).toEqual('');
      expect($interpolate('{{a.b}}').eval(null)).toEqual('');
    }));

    it('should jsonify objects', inject((Interpolate $interpolate) {
      expect($interpolate('{{ {} }}').eval(null)).toEqual('{}');
      expect($interpolate('{{ true }}').eval(null)).toEqual('true');
      expect($interpolate('{{ false }}').eval(null)).toEqual('false');
    }));

    it('should rethrow exceptions', inject((Interpolate $interpolate, Scope $rootScope) {
      $rootScope.err = () {
        throw 'oops';
      };
      expect(() {
        $interpolate('{{err()}}').eval($rootScope);
      }).toThrow(r"$interpolate error! Can't interpolate: {{err()}}");
    }));

    it('should return interpolation function', inject((Interpolate $interpolate, Scope $rootScope) {
      $rootScope.name = 'Misko';
      var fn = $interpolate('Hello {{name}}!');
      expect(fn.eval($rootScope)).toEqual('Hello Misko!');
      expect(fn.eval($rootScope)).toEqual('Hello Misko!');
    }));


    it('should ignore undefined model', inject((Interpolate $interpolate) {
      expect($interpolate("Hello {{'World' + foo}}").eval(null)).toEqual('Hello World');
    }));


    it('should ignore undefined return value', inject((Interpolate $interpolate, Scope $rootScope) {
      $rootScope.foo = () => null;
      expect($interpolate("Hello {{'World' + foo()}}").eval($rootScope)).toEqual('Hello World');
    }));

    it('should use toString to conver objects to string', inject((Interpolate $interpolate, Scope $rootScope) {
      $rootScope.obj = new ToStringableObject();
      expect($interpolate("Hello, {{obj}}!").eval($rootScope)).toEqual('Hello, World!');
    }));


    describe('parseBindings', () {
      it('should Parse Text With No Bindings', inject((Interpolate $interpolate) {
        var parts = $interpolate("a").parts;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("a");
      }));

      it('should Parse Empty Text', inject((Interpolate $interpolate) {
        var parts = $interpolate("").parts;
        expect(parts.length).toEqual(1);
        expect(parts[0]).toEqual("");
      }));

      it('should Parse Inner Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}C").parts;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual("a");
        expect(parts[1].exp).toEqual("b");
        expect(parts[1].eval({'b':123})).toEqual(123);
        expect(parts[2]).toEqual("C");
      }));

      it('should Parse Ending Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("a{{b}}").parts;
        expect(parts.length).toEqual(2);
        expect(parts[0]).toEqual("a");
        expect(parts[1].exp).toEqual("b");
        expect(parts[1].eval({'b':123})).toEqual(123);
      }));

      it('should Parse Begging Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}c").parts;
        expect(parts.length).toEqual(2);
        expect(parts[0].exp).toEqual("b");
        expect(parts[1]).toEqual("c");
      }));

      it('should Parse Loan Binding', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}").parts;
        expect(parts.length).toEqual(1);
        expect(parts[0].exp).toEqual("b");
      }));

      it('should Parse Two Bindings', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}{{c}}").parts;
        expect(parts.length).toEqual(2);
        expect(parts[0].exp).toEqual("b");
        expect(parts[1].exp).toEqual("c");
      }));

      it('should Parse Two Bindings With Text In Middle', inject((Interpolate $interpolate) {
        var parts = $interpolate("{{b}}x{{c}}").parts;
        expect(parts.length).toEqual(3);
        expect(parts[0].exp).toEqual("b");
        expect(parts[1]).toEqual("x");
        expect(parts[2].exp).toEqual("c");
      }));

      it('should Parse Multiline', inject((Interpolate $interpolate) {
        var parts = $interpolate('"X\nY{{A\n+B}}C\nD"').parts;
        expect(parts.length).toEqual(3);
        expect(parts[0]).toEqual('"X\nY');
        expect(parts[1].exp).toEqual('A\n+B');
        expect(parts[2]).toEqual('C\nD"');
      }));
    });
  });
}
