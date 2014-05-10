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
          ViewCache cache, MockHttpBackend backend, DirectiveMap directives) {
      var firstFactory = cache.fromHtml(HTML, directives);

      expect(cache.fromHtml(HTML, directives)).toBe(firstFactory);

      // Also for fromUrl
      backend.whenGET('template.url').respond(200, HTML);

      var httpFactory;
      cache.fromUrl('template.url', directives).then((f) => httpFactory = f);

      microLeap();
      backend.flush();
      microLeap();

      expect(httpFactory).toBe(firstFactory);
    }));
  });
}
