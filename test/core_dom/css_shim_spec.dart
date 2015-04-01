library css_shim_spec;

import '../_specs.dart';
import 'package:angular/core_dom/css_shim.dart';

main() {
  describe("cssShim", () {
    s(String css, String tag) => shimCssText(css, tag).replaceAll("\n", "");

    it("should handle empty string", () {
      expect(s("", "a")).toEqual("");
    });

    it("should add an attribute to every rule", () {
      final css = "one {color: red;}two {color: red;}";

      final expected = "one[a] {color: red;}two[a] {color: red;}";

      expect(s(css, "a")).toEqual(expected);
    });

    it("should hanlde invalid css", () {
      final css = "one {color: red;}garbage";

      final expected = "one[a] {color: red;}";

      expect(s(css, "a")).toEqual(expected);
    });

    it("should add an attribute to every selector", () {
      final css = "one, two {color: red;}";

      final expected = "one[a], two[a] {color: red;}";

      expect(s(css, "a")).toEqual(expected);
    });

    it("should handle media rules", () {
      final css =
          "@media screen and (max-width: 800px) {div {font-size: 50px;}}";

      final expected =
          "@media screen and (max-width: 800px) {div[a] {font-size: 50px;}}";

      expect(s(css, "a")).toEqual(expected);
    });

    it("should handle media rules with simple rules", () {
      final css =
          "@media screen and (max-width: 800px) {div {font-size: 50px;}} div {}";

      final expected =
          "@media screen and (max-width: 800px) {div[a] {font-size: 50px;}}div[a] {}";

      expect(s(css, "a")).toEqual(expected);
    });

    it("should handle complicated selectors", () {
      expect(s('one::before {}', "a")).toEqual('one[a]::before {}');
      expect(s('one two {}', "a")).toEqual('one[a] two[a] {}');
      expect(s('one>two {}', "a")).toEqual('one[a]>two[a] {}');
      expect(s('one+two {}', "a")).toEqual('one[a]+two[a] {}');
      expect(s('one~two {}', "a")).toEqual('one[a]~two[a] {}');
      expect(s('.one.two > three {}', "a")).toEqual('.one.two[a]>three[a] {}');
      expect(s('one[attr="value"] {}', "a")).toEqual('one[attr="value"][a] {}');
      expect(s('one[attr=value] {}', "a")).toEqual('one[attr=value][a] {}');
      expect(s('one[attr^="value"] {}', "a"))
          .toEqual('one[attr^="value"][a] {}');
      expect(s(r'one[attr$="value"] {}', "a"))
          .toEqual(r'one[attr$="value"][a] {}');
      expect(s('one[attr*="value"] {}', "a"))
          .toEqual('one[attr*="value"][a] {}');
      expect(s('one[attr|="value"] {}', "a"))
          .toEqual('one[attr|="value"][a] {}');
      expect(s('one[attr] {}', "a")).toEqual('one[attr][a] {}');
      expect(s('[is="one"] {}', "a")).toEqual('one[a] {}');
    });

    it("should handle :host", () {
      expect(s(':host {}', "a")).toEqual('a {}');
      expect(s(':host(.x,.y) {}', "a")).toEqual('a.x, a.y {}');
    });

    it("should support polyfill-next-selector", () {
      var css = s("polyfill-next-selector {content: 'x > y'} z {}", "a");
      expect(css).toEqual('x[a]>y[a] {}');

      css = s('polyfill-next-selector {content: "x > y"} z {}', "a");
      expect(css).toEqual('x[a]>y[a] {}');
    });

    it("should support polyfill-unscoped-next-selector", () {
      var css =
          s("polyfill-unscoped-next-selector {content: 'x > y'} z {}", "a");
      expect(css).toEqual('x > y {}');

      css = s('polyfill-unscoped-next-selector {content: "x > y"} z {}', "a");
      expect(css).toEqual('x > y {}');
    });

    it("should support polyfill-non-strict-next-selector", () {
      var css = s("polyfill-non-strict {} one, two {}", "a");
      expect(css).toEqual('a one, a two {}');
    });

    it("should handle ::shadow", () {
      var css = s("polyfill-non-strict {} x::shadow > y {}", "a");
      expect(css).toEqual('a x  > y {}');
    });

    it("should handle /deep/", () {
      var css = s("polyfill-non-strict {} x /deep/ y {}", "a");
      expect(css).toEqual('a x   y {}');
    });
  });
}
