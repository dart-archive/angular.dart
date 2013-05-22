import "_specs.dart";

// Types must be declared on the top level. Ugh.
class SomeDirective { }
class AnotherAttrDirective { }

main() {
  describe('directive factory', () {
    it('should guess the directive name correctly', () {
      DirectiveFactory factory = new DirectiveFactory(SomeDirective);
      expect(factory.$name).toEqual('some');
    });

    it('should guess the attr directive name correctly', () {
      DirectiveFactory factory = new DirectiveFactory(AnotherAttrDirective);
      expect(factory.$name).toEqual('[another]');
    });
  });
}
