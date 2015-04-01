library angular.dom.platform_js_based_shim_spec;

import '../_specs.dart';

main() {
  describe('PlatformJsBasedShim', () {

    beforeEachModule((Module module) {
      module
        ..bind(_WebPlatformTestComponent)
        ..bind(_InnerComponent)
        ..bind(_OuterComponent)
        ..bind(PlatformJsBasedShim, toValue: new PlatformJsBasedShim());
    });

    it('should scope styles to shadow dom across browsers.',
      async((TestBed _, MockHttpBackend backend, PlatformJsBasedShim platform) {

      // TODO(vicb) WebPlatform does not work with polyfills
      // see https://github.com/angular/angular.dart/issues/1300
      if (platform.shimRequired) return;

      Element element = e('<span><test-wptc><span>ignore</span></test-wptc></span>');

      _.compile(element);

      backend..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/style.css')
                 .respond(200, 'span {background-color: red;}')
             ..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/template.html')
                 .respond(200, '<span>foo</span>');

      try {
        document.body.append(element);
        microLeap();

        // Outer span should not be styled.
        expect(element.getComputedStyle().backgroundColor)
          .not.toEqual("rgb(255, 0, 0)");

        // Inner span should not be styled.
        expect(element.children[0].children[0].getComputedStyle()
          .backgroundColor)
          .not.toEqual("rgb(255, 0, 0)");

        // Shadow root should be styled.
        expect(element.children[0].shadowRoot.querySelector("span")
        .getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

      } finally {
        element.remove();
      }
    }));

    it('should scope :host styles to the primary element.',
        async((TestBed _, MockHttpBackend backend, PlatformJsBasedShim platform) {

      // TODO(vicb) WebPlatform does not work with polyfills
      // see https://github.com/angular/angular.dart/issues/1300
      if (platform.shimRequired) return;

      Element element = e('<span><test-wptc><span>ignore</span></test-wptc></span>');

      _.compile(element);

      backend..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/style.css')
                 .respond(200, ':host {background-color: red; }')
             ..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/template.html')
                 .respond(200, '<span>foo</span>');

      try {
        document.body.append(element);
        microLeap();

        // Element should be styled.
        expect(element.children[0].getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

      } finally {
        element.remove();
      }
    }));

    // NOTE: This test currently fails on firefox, but passes on chrome,
    // safari and dartium browsers. Add back into the list of tests when firefox
    // pushes new version(s).
    xit('should scope ::content rules to component content.',
    async((TestBed _, MockHttpBackend backend) {

      Element element = e('<test-wptc><span>RED'
      '</span></test-wptc>');

      _.compile(element);

      backend
          ..flushGET('style.css').respond(200,
              "polyfill-next-selector { content: ':host span:not([:host])'; }"
              "::content span { background-color: red; }")
          ..flushGET('template.html').respond(200, '<span><content></content></span>');

      try {
        document.body.append(element);
        microLeap();

        // Child span should be styled.
        expect(element.children[0].getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

        // Shadow span should not be styled.
        expect(element.shadowRoot.querySelector("span").getComputedStyle().backgroundColor)
            .not.toEqual("rgb(255, 0, 0)");

      } finally {
        element.remove();
      }
    }));

    // NOTE: Chrome 34 does not work with this test. Uncomment when the dartium
    // base Chrome version is > 34
    xit('should style into child shadow dom with ::shadow.',
    async((TestBed _, MockHttpBackend backend) {

      Element element = e('<my-outer></my-outer>');

      _.compile(element);


      backend..flushGET('outer-style.css').respond(200,
                 'my-inner::shadow .foo {background-color: red; }')
             ..flushGET('outer-html.html').respond(200,
                 '<my-inner><span class="foo">foo</span></my-inner>');

      microLeap();

      backend..flushGET('inner-style.css').respond(200, '/* no style */')
             ..flushGET('inner-html.html').respond(200,
                 '<span class="foo"><content></content></span>');

      try {
        document.body.append(element);
        microLeap();

        // Outer element foo should not be styled red.
        expect(element.shadowRoot.querySelector("span")
        .getComputedStyle().backgroundColor).not.toEqual("rgb(255, 0, 0)");

        // inner element foo should be styled red.
        expect(element.shadowRoot.querySelector("my-inner").shadowRoot
        .querySelector("span").getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

      } finally {
        element.remove();
      }
    }));
  });
}

@Component(
    selector: "test-wptc",
    templateUrl: "template.html",
    cssUrl: "style.css")
class _WebPlatformTestComponent {
}

@Component(
    selector: "test-wptca[a]",
    templateUrl: "template.html",
    cssUrl: "style.css")
class _WebPlatformTestComponentWithAttribute {
}

@Component(
    selector: "my-inner",
    templateUrl: "inner-html.html",
    cssUrl: "inner-style.css")
class _InnerComponent {
}

@Component(
    selector: "my-outer",
    templateUrl: "outer-html.html",
    cssUrl: "outer-style.css")
class _OuterComponent {
}
