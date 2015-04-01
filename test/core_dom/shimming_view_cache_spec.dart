library angular.dom.shimming_view_cache_spec;

import '../_specs.dart';

main() {
  describe("ShimmingViewCache", () {
    ShimmingViewFactoryCache cache;
    MockWebPlatformShim platformShim;
    MockHttpBackend backend;
    Injector inj;
    TestBed _;

    beforeEach((Injector _inj, TestBed tb, MockHttpBackend _backend,
        MockWebPlatformShim _platformShim) {
      _ = tb;
      inj = _inj;
      backend = _backend;

      platformShim = _platformShim;
      platformShim.shimDom = (root, selector) {
        root.innerHtml = "SHIMMED";
      };

      cache = new ShimmingViewFactoryCache(
          inj.get(ViewFactoryCache), "selector", platformShim);
    });

    describe("fromHtml", () {
      fromHtml(ViewFactoryCache cache, String html) {
        final viewFactory = cache.fromHtml(html, inj.get(DirectiveMap));
        return viewFactory(_.rootScope, inj.get(DirectiveInjector));
      }

      describe("shim is not required", () {
        it("should delegate to the decorated cache", () {
          platformShim.shimRequired = false;
          expect(fromHtml(cache, "HTML")).toHaveText("HTML");
        });
      });

      describe("shim is required", () {
        beforeEach(() {
          platformShim.shimRequired = true;
        });

        it("should shim the dom", () {
          expect(fromHtml(cache, "HTML")).toHaveText("SHIMMED");
        });

        it("uses uniq cache key per selector", () {
          final cache2 = new ShimmingViewFactoryCache(
              inj.get(ViewFactoryCache), "selector2", platformShim);

          fromHtml(cache, "HTML");
          fromHtml(cache2, "HTML");

          expect(cache.viewFactoryCache.size).toEqual(2);
        });
      });
    });

    describe("fromUrl", () {
      beforeEach(() {
        backend.whenGET("URL").respond(200, "HTML");
      });

      fromUrl(ViewFactoryCache cache, String url) {
        final f = cache.fromUrl(url, inj.get(DirectiveMap));

        if (backend.requests.isNotEmpty) backend.flush();
        microLeap();

        return f.then((vf) => vf(_.rootScope, inj.get(DirectiveInjector)));
      }

      describe("shim is not required", () {
        it("should delegate to the decorated cache", async(() {
          platformShim.shimRequired = false;

          return fromUrl(cache, "URL").then((view) {
            expect(view).toHaveText("HTML");
          });
        }));
      });

      describe("shim is required", () {
        beforeEach(() {
          platformShim.shimRequired = true;
        });

        it("should shim the dom", async(() {
          return fromUrl(cache, "URL").then((view) {
            expect(view).toHaveText("SHIMMED");
          });
        }));

        it("uses uniq cache key per selector", async(() {
          final cache2 = new ShimmingViewFactoryCache(
              inj.get(ViewFactoryCache), "selector2", platformShim);

          fromUrl(cache, "URL");
          fromUrl(cache2, "URL");

          expect(cache.viewFactoryCache.size).toEqual(4); //2 html, 2 url
        }));
      });
    });
  });
}
