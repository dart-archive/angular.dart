import "_specs.dart";

class ResetStyleInheritanceComponent {
  static String $template = '<div class="c">Reset me foo</div>';
  static var $shadowRootOptions = new ShadowRootOptions(false, true);
  static var lastTemplateLoader;
  ResetStyleInheritanceComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

class ApplyAuthorStyleComponent {
  static String $template = '<div>Style me foo</div>';
  static var $shadowRootOptions = new ShadowRootOptions(true);
  static var lastTemplateLoader;
  ApplyAuthorStyleComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

class DefaultOptionsComponent {
  static String $template = '<div class="c">Style me foo</div>';
  static var lastTemplateLoader;
  DefaultOptionsComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

main() {
  Compiler $compile;
  Injector injector;
  Scope $rootScope;
  DirectiveRegistry directives;

  beforeEach(module((AngularModule module) {
    module
    ..directive(ApplyAuthorStyleComponent)
    ..directive(ResetStyleInheritanceComponent)
    ..directive(DefaultOptionsComponent);
    return (Injector _injector) {
      injector = _injector;
      $compile = injector.get(Compiler);
      $rootScope = injector.get(Scope);
    };
  }));

  describe('shadow dom options', () {
    it('should respect the apply-author-style option', async(inject(() {
      var element = $(
          '<style>div { border: 3px solid green }</style>' +
          '<apply-author-style>not included</apply-author-style>' +
          '<default-options>not included</default-options>');
      element.forEach((elt) { document.body.append(elt); }); // we need the computed style.
      $compile(element)(injector, element);

      nextTurn();
      expect(element[1].shadowRoot.query('div').getComputedStyle().border).toContain('3px solid');
      // ""0px none"" is the default style.
      expect(element[2].shadowRoot.query('div').getComputedStyle().border).toContain('0px none');
    })));

    it('should respect the reset-style-inheritance option', async(inject(() {
      var element = $(
          '<style>body { font-size: 20px; }</style>' +  // font-size inherit's by default
          '<reset-style-inheritance>not included</reset-style-inheritance>' +
          '<default-options>not included</default-options>');
      element.forEach((elt) { document.body.append(elt); }); // we need the computed style.
      $compile(element)(injector, element);

      nextTurn();
      expect(element[1].shadowRoot.query('div').getComputedStyle().fontSize).toEqual('16px');
      expect(element[2].shadowRoot.query('div').getComputedStyle().fontSize).toEqual('20px');
    })));
  });
}
