library angular.dom.default_platform_shim_spec;

import '../_specs.dart';

import 'dart:js' as js;

main() {
  describe("DefaultPlatformShim", () {
    final shim = new DefaultPlatformShim();

    describe("shimCss", () {
      it("should shim the given css", () {
        final shimmed = shim.shimCss("a{color: red;}", selector: "SELECTOR", cssUrl: 'URL');

        expect(shimmed).toContain("Shimmed css for <SELECTOR> from URL");
      });
    });

    describe("shimShadowDom", () {
      it("add an attribute to all element in the dom subtree", () {
        final root = e("<div><span><b></b></span></div>");

        shim.shimShadowDom(root, "selector");

        expect(root).toHaveHtml('<span selector=""><b selector=""></b></span>');
      });

      // TODO: Remove the test once https://github.com/angular/angular.dart/issues/1300 is fixed
      it("should not crash with an invalid selector; but wont work either", () {
        final root = e("<div><span><b></b></span></div>");

        shim.shimShadowDom(root, "c[a]");

        expect(root).toHaveHtml('<span><b></b></span>');
      });
    });

    describe("Integration Test", () {
      beforeEachModule((Module module) {
        module
            ..bind(ComponentFactory, toImplementation: TranscludingComponentFactory)
            ..bind(DefaultPlatformShim)
            ..bind(_WebPlatformTestComponent);
      });

      it('should scope styles to shadow dom across browsers.', async((
          TestBed _, MockHttpBackend backend) {

        Element element = _.compile('<span><test-wptc></test-wptc></span>');

        microLeap();
        backend
          ..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/style.css').respond(200, 'span { background-color: red; }')
          ..flushGET('${TEST_SERVER_BASE_PREFIX}test/core_dom/template.html').respond(200, '<span>foo</span>');
        microLeap();

        try {
          document.body.append(element);
          microLeap();

          // Outer span should not be styled.
          expect(element.getComputedStyle().backgroundColor)
              .not.toEqual("rgb(255, 0, 0)");

          // "Shadow root" should be styled.
          expect(element.children[0].querySelector("span")
              .getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

        } finally {
          element.remove();
        }
      }));
    });
  });
}

@Component(
    selector: "test-wptc",
    publishAs: "ctrl",
    templateUrl: "template.html",
    cssUrl: "style.css")
class _WebPlatformTestComponent {
}



