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
  describe('directive factory', () {
    it('should guess the directive name correctly', () {
      Directive factory = new Directive(SomeDirective);
      expect(factory.$name).toEqual('some');
    });

    it('should guess the attr directive name correctly', () {
      Directive factory = new Directive(AnotherAttrDirective);
      expect(factory.$name).toEqual('[another]');
    });

    it('should set \$transclude based on the directive type for undef transclude', () {
      Directive factory = new Directive(SomeDirective);
      expect(factory.$transclude).toEqual(null);
    });

    it('should set \$transclude based on the directive type for transclude=true', () {
      Directive factory = new Directive(TranscludeDirective);
      expect(factory.$transclude).toEqual("true");
    });

    it('should set \$transclude based on the directive type for transclude=null', () {
      Directive factory = new Directive(ExplicitNullTranscludeDirective);
      expect(factory.$transclude).toEqual(null);
    });
  });
}
