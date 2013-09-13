import "_specs.dart";

// Types must be declared on the top level. Ugh.
@NgDirective(selector: 'some')
class SomeDirective { }

@NgDirective(selector: '[another]')
class AnotherAttrDirective { }

@NgDirective(transclude: true, selector: '[transclude]')
class TranscludeDirective {
}

@NgDirective(selector: 'with-default-shadow-root-options')
class WithDefaultShadowRootOptionsComponent {
}

@NgComponent(
    selector: 'with-custom-shadow-root-options',
    applyAuthorStyles: true,
    resetStyleInheritance: true
)
class WithCustomShadowRootOptionsComponent {
}

main() {
  describe('directive factory', () {
    it('should guess the directive name correctly', () {
      Directive factory = new Directive(SomeDirective);
      expect(factory.$selector).toEqual('some');
    });

    it('should guess the attr directive name correctly', () {
      Directive factory = new Directive(AnotherAttrDirective);
      expect(factory.$selector).toEqual('[another]');
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
