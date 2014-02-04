library shadow_root_options_spec;

import '../_specs.dart';

@NgComponent(
    selector: 'reset-style-inheritance',
    template: '<div class="c">Reset me foo</div>',
    applyAuthorStyles: false,
    resetStyleInheritance: true
)
class ResetStyleInheritanceComponent {
  static var lastTemplateLoader;
  ResetStyleInheritanceComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

@NgComponent(
    selector: 'apply-author-style',
    template: '<div>Style me foo</div>',
    applyAuthorStyles: true
)
class ApplyAuthorStyleComponent {
  static var lastTemplateLoader;
  ApplyAuthorStyleComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

@NgComponent(
    selector: 'default-options',
    template: '<div class="c">Style me foo</div>'
)
class DefaultOptionsComponent {
  static var lastTemplateLoader;
  DefaultOptionsComponent(Element elt, TemplateLoader tl) {
    lastTemplateLoader = tl.template;
  }
}

main() {
  describe('shadow dom options', () {
    Compiler $compile;
    DirectiveMap directives;
    Injector injector;
    Scope $rootScope;

    beforeEach(module((Module module) {
      module
      ..type(ApplyAuthorStyleComponent)
      ..type(ResetStyleInheritanceComponent)
      ..type(DefaultOptionsComponent);
      return (Injector _injector) {
        injector = _injector;
        $compile = injector.get(Compiler);
        $rootScope = injector.get(Scope);
        directives = injector.get(DirectiveMap);
      };
    }));

    it('should respect the apply-author-style option', async(inject(() {
      var element = $(
          '<style>div { border: 3px solid green }</style>' +
          '<apply-author-style>not included</apply-author-style>' +
          '<default-options>not included</default-options>');
      element.forEach((elt) { document.body.append(elt); }); // we need the computed style.
      $compile(element, directives)(injector, element);

      microLeap();
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
      $compile(element, directives)(injector, element);

      microLeap();
      expect(element[1].shadowRoot.query('div').getComputedStyle().fontSize).toEqual('16px');
      expect(element[2].shadowRoot.query('div').getComputedStyle().fontSize).toEqual('20px');
    })));
  });
}
