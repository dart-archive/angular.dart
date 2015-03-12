library component_css_loader;

import '../_specs.dart';
import 'dart:html' as dom;

void main() {
  describe("ComponentCssLoader", () {
    ComponentCssLoader loader;

    beforeEach((Http http, TemplateCache tc, MockWebPlatformShim shim,
        ComponentCssRewriter ccr, dom.NodeTreeSanitizer ts, ResourceUrlResolver resourceResolver) {
      loader = new ComponentCssLoader(http, tc, shim, ccr, ts, {}, resourceResolver);
    });

    afterEach((MockHttpBackend backend) {
      backend.verifyNoOutstandingExpectation();
      backend.verifyNoOutstandingRequest();
    });

    it('should return created style elements', async((MockHttpBackend backend) {
      backend..expectGET('simple1.css').respond(200, '.hello1{}');
      backend..expectGET('simple2.css').respond(200, '.hello2{}');

      final res = loader("tag", ['simple1.css', 'simple2.css']);

      backend.flush();
      microLeap();

      res.then((elements) {
        expect(elements[0]).toHaveText(".hello1{}");
        expect(elements[1]).toHaveText(".hello2{}");
      });
    }));

    it('should ignore CSS load errors ', async((MockHttpBackend backend) {
      backend..expectGET('simple.css').respond(500, 'some error');

      final res = loader("tag", ['simple.css']);

      backend.flush();
      microLeap();

      res.then((elements) {
        expect(elements.first).toHaveText('/* HTTP 500: some error */');
      });
    }));

    it('should use same style for the same tag', async((
        MockHttpBackend backend, MockWebPlatformShim shim) {
      backend..expectGET('simple.css').respond(200, '.hello{}');
      shim.cssCompiler = (css, {selector}) => "$selector - $css";

      final f1 = loader("tag", ['simple.css']);

      backend.flush();
      microLeap();

      final f2 = loader("tag", ['simple.css']);
      microLeap();

      f1.then((el) {
        expect(el[0]).toHaveText("tag - .hello{}");
      });

      f2.then((el) {
        expect(el[0]).toHaveText("tag - .hello{}");
      });
    }));

    it('should create new style for every tag', async((
        MockHttpBackend backend, MockWebPlatformShim shim) {
      backend..expectGET('simple.css').respond(200, '.hello{}');
      shim.cssCompiler = (css, {selector}) => "$selector - $css";

      final f1 = loader("tag1", ['simple.css']);

      backend.flush();
      microLeap();

      final f2 = loader("tag2", ['simple.css']);
      microLeap();

      f1.then((el) {
        expect(el[0]).toHaveText("tag1 - .hello{}");
      });

      f2.then((el) {
        expect(el[0]).toHaveText("tag2 - .hello{}");
      });
    }));
  });
}
