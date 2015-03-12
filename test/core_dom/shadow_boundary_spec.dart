library shadow_boundary_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() {
  describe('ShadowBoundary', () {
    forShadowBoundary(String name, {boundaryFactory, rootFactory}) {
      describe(name, () {
        ShadowBoundary boundary;
        var root;

        beforeEach(() {
          root = rootFactory();
          boundary = boundaryFactory(root);
        });

        it("should insert style elements in order", () {
          final s1 = new dom.StyleElement()..text = ".style1{}";
          final s2 = new dom.StyleElement()..text = ".style2{}";
          final s3 = new dom.StyleElement()..text = ".style3{}";

          boundary.insertStyleElements([s1,s2]);
          boundary.insertStyleElements([s3]);

          expect(root).toHaveText(".style1{}.style2{}.style3{}");
        });

        it("should prepend style elements before other style elements (prepend, then append)", () {
          final s1 = new dom.StyleElement()..text = ".style1{}";
          final s2 = new dom.StyleElement()..text = ".style2{}";
          final s3 = new dom.StyleElement()..text = ".style3{}";

          boundary.insertStyleElements([s1, s2], prepend: true);
          boundary.insertStyleElements([s3]);

          expect(root).toHaveText(".style1{}.style2{}.style3{}");
        });

        it("should prepend style elements before other style elements (append, then prepend)", () {
          final s1 = new dom.StyleElement()..text = ".style1{}";
          final s2 = new dom.StyleElement()..text = ".style2{}";
          final s3 = new dom.StyleElement()..text = ".style3{}";

          boundary.insertStyleElements([s1,s2]);
          boundary.insertStyleElements([s3], prepend: true);

          expect(root).toHaveText(".style3{}.style1{}.style2{}");
        });

        it("should insert style elements before other content", () {
          root.appendHtml("<div>adiv</div>");
          final s = new dom.StyleElement()..text = ".style1{}";

          boundary.insertStyleElements([s]);

          expect(root).toHaveText(".style1{}adiv");
        });

        it("should not insert the same style element twice", () {
          final s = new dom.StyleElement()..text = ".style1{}";

          boundary.insertStyleElements([s]);
          boundary.insertStyleElements([s]);

          expect(root).toHaveText(".style1{}");
        });
      });
    }

    forShadowBoundary("ShadowRootBoundary",
        rootFactory: () => new dom.DivElement().createShadowRoot(),
        boundaryFactory: (root) => new ShadowRootBoundary(root)
    );

    forShadowBoundary("DefaultShadowBounary",
        rootFactory: () => new dom.DivElement(),
        boundaryFactory: (root) => new DefaultShadowBoundary.custom(root)
    );
  });
}