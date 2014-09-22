library shadow_boundary_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() {
  describe('ShadowBoundary', () {
    describe("ShadowRootBoundary", () {
      it("should insert style elements in order", () {
        final root = new dom.DivElement().createShadowRoot();
        final boundary = new ShadowRootBoundary(root);

        final s1 = new dom.StyleElement()..text = ".style1{}";
        final s2 = new dom.StyleElement()..text = ".style2{}";
        final s3 = new dom.StyleElement()..text = ".style3{}";

        boundary.insertStyleElements([s1,s2]);
        boundary.insertStyleElements([s3]);

        expect(root).toHaveText(".style1{}.style2{}.style3{}");
      });

      it("should insert style elements before other content", () {
        final root = new dom.DivElement().createShadowRoot();
        final boundary = new ShadowRootBoundary(root);

        root.appendHtml("<div>adiv</div>");
        final s = new dom.StyleElement()..text = ".style1{}";

        boundary.insertStyleElements([s]);

        expect(root).toHaveText(".style1{}adiv");
      });

      it("should not insert the same style element twice", () {
        final root = new dom.DivElement().createShadowRoot();
        final boundary = new ShadowRootBoundary(root);

        final s = new dom.StyleElement()..text = ".style1{}";

        boundary.insertStyleElements([s]);
        boundary.insertStyleElements([s]);

        expect(root).toHaveText(".style1{}");
      });
    });
  });
}