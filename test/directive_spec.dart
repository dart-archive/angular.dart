import "_specs.dart";

// Types must be declared on the top level. Ugh.
class SomeDirective { }
class AnotherAttrDirective { }

class TranscludeDirective {
  static var $transclude = "true";
}

class ExplicitNullTranscludeDirective {
  static var $transclude = null;
}

main() {
  d escribe('directive factory', () {
    it('should guess the directive name correctly', () {
      DirectiveFactory factory = new DirectiveFactory(SomeDirective);
      expect(factory.$name).toEqual('some');
    });

    it('should guess the attr directive name correctly', () {
      DirectiveFactory factory = new DirectiveFactory(AnotherAttrDirective);
      expect(factory.$name).toEqual('[another]');
    });

    it('should set \$transclude based on the directive type for undef transclude', () {
      DirectiveFactory factory = new DirectiveFactory(SomeDirective);
      expect(factory.$transclude).toEqual(null);
    });

    it('should set \$transclude based on the directive type for transclude=true', () {
      DirectiveFactory factory = new DirectiveFactory(TranscludeDirective);
      expect(factory.$transclude).toEqual("true");
    });

    it('should set \$transclude based on the directive type for transclude=null', () {
      DirectiveFactory factory = new DirectiveFactory(ExplicitNullTranscludeDirective);
      expect(factory.$transclude).toEqual(null);
    });
  });
}
