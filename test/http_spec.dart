import "_specs.dart";
import "_http.dart";

var VALUE = 'val';
var CACHED_VALUE = 'cached_value';


class FakeCache implements Cache {
  get(x) => x == 'f' ? new HttpResponse(200, CACHED_VALUE) : null;
  put(_,__) => null;

}

class SubstringRewriter extends UrlRewriter {
  call(String x) => x.substring(0, 1);
}

main() {
  describe('http rewriting', () {
    var rewriter, futures, backend, cache;
    beforeEach(() {
      rewriter = new SubstringRewriter();
      backend = new MockHttpBackend();
      cache = new FakeCache();
    });

    it('should rewrite URLs before calling the backend', () {
      backend.expectGET('a', VALUE, times: 1);

      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('a[not sent to backed]').then((v) {
        expect(v).toBe(VALUE);
        called += 1;
      });

      expect(called).toEqual(0);

      backend.flush();

      expect(called).toEqual(1);
      backend.assertAllGetsCalled();
    });

    it('should support pending requests for different raw URLs', () {
      backend.expectGET('a', VALUE, times: 1);

      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('a[some string]', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 1;
      });
      http.getString('a[different string]', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 10;
      });

      expect(called).toEqual(0);
      backend.flush();
      expect(called).toEqual(11);
      backend.assertAllGetsCalled();
    });

    it('should support caching', async(() {
      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('fromCache', cache: cache).then((v) {
        expect(v).toBe(CACHED_VALUE);
        called += 1;
      });

      expect(called).toEqual(0);
      backend.flush();
      nextTurn();

      expect(called).toEqual(1);
      backend.assertAllGetsCalled();
    }));
  });

  describe('http caching', () {
    var rewriter, backend, cache;
    beforeEach(() {
      rewriter = new UrlRewriter();
      backend = new MockHttpBackend();
      cache = new FakeCache();
    });
    it('should not cache if no cache is present', () {
      backend.expectGET('a', VALUE, times: 2);

      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('a').then((v) {
        expect(v).toBe(VALUE);
        called += 1;
      });
      http.getString('a').then((v) {
        expect(v).toBe(VALUE);
        called += 10;
      });

      expect(called).toEqual(0);

      backend.flush();

      expect(called).toEqual(11);
      backend.assertAllGetsCalled();
    });


    it('should return a pending request', inject(() {
      backend.expectGET('a', VALUE, times: 1);

      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('a', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 1;
      });
      http.getString('a', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 10;
      });

      expect(called).toEqual(0);
      backend.flush();
      expect(called).toEqual(11);
      backend.assertAllGetsCalled();
    }));


    it('should not return a pending request after the request is complete', () {
      backend.expectGET('a', VALUE, times: 2);

      var http = new Http(rewriter, backend);
      var called = 0;
      http.getString('a', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 1;
      });

      expect(called).toEqual(0);
      backend.flush();

      http.getString('a', cache: cache).then((v) {
        expect(v).toBe(VALUE);
        called += 10;
      });

      expect(called).toEqual(1);
      backend.flush();
      expect(called).toEqual(11);
      backend.assertAllGetsCalled();
    });


    it('should return a cached value if present', async(() {
      var http = new Http(rewriter, backend);
      var called = 0;
      // The URL string 'f' is primed in the FakeCache
      http.getString('f', cache: cache).then((v) {
        expect(v).toBe(CACHED_VALUE);
        called += 1;
      });

      expect(called).toEqual(0);
      backend.flush();
      nextTurn();

      expect(called).toEqual(1);
      backend.assertAllGetsCalled();
    }));
  });
}
