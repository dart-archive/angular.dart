library angular.dom.view_cache_spec;

import '../_specs.dart';

main() {
  describe('ViewCache', () {
    var HTML = '<div>html</div>';
    var mockCompiler;
    beforeEachModule((Module module) {
      var httpBackend = new MockHttpBackend();

      module
        ..bind(HttpBackend, toValue: httpBackend)
        ..bind(MockHttpBackend, toValue: httpBackend);
    });

    it('should cache the ViewFactory', async((
          ViewFactoryCache cache, MockHttpBackend backend, DirectiveMap directives) {
      var firstFactory = cache.fromHtml(HTML, directives);

      expect(cache.fromHtml(HTML, directives)).toBe(firstFactory);

      var httpFactory;
      cache.fromUrl('template.url', directives, Uri.base).then((f) => httpFactory = f);

      backend.flushGET('template.url').respond(200, HTML);
      microLeap();

      expect(httpFactory).toBe(firstFactory);
    }));
  });
}
