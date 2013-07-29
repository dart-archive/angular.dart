import "_specs.dart";

// Types must be declared on the top level. Ugh.
class SomeDirective { }
class AnotherAttrDirective { }

@NgDirective(transclude: true)
class TranscludeDirective {
}

class WithDefaultShadowRootOptionsComponent {
}

@NgComponent(
    applyAuthorStyles: true,
    resetStyleInheritance: true
)
class WithCustomShadowRootOptionsComponent {
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
      expect(factory.$transclude).toEqual(false);
    });

    it('should set \$transclude based on the directive type for transclude=true', () {
      Directive factory = new Directive(TranscludeDirective);
      expect(factory.$transclude).toEqual(true);
    });

    it('should default \$shadowRootOptions to false/false', () {
      Directive factory = new Directive(WithDefaultShadowRootOptionsComponent);
      expect(factory.$shadowRootOptions.applyAuthorStyles, isFalse);
      expect(factory.$shadowRootOptions.resetStyleInheritance, isFalse);
    });

    it('should override \$shadowRootOptions with values provided by component type', () {
      Directive factory = new Directive(WithCustomShadowRootOptionsComponent);
      expect(factory.$shadowRootOptions.applyAuthorStyles, isTrue);
      expect(factory.$shadowRootOptions.resetStyleInheritance, isTrue);
    });
  });
}
