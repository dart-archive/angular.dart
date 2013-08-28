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
  describe('http', () {
    var backend, cache;
    beforeEach(module((AngularModule module) {
      backend = new MockHttpBackend();
      cache = new FakeCache();
      module
      ..value(HttpBackend, backend);
    }));

    describe('url rewriting', () {
      beforeEach(module((AngularModule module) {
        module
          ..type(UrlRewriter, implementedBy: SubstringRewriter);
      }));


      it('should rewrite URLs before calling the backend', async(inject((Http http, Zone zone) {
        backend.expectGET('a', VALUE, times: 1);

        var called = 0;
        zone.run(() {
          http.getString('a[not sent to backed]').then((v) {
            expect(v).toBe(VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);

        backend.flush();
        nextTurn(true);

        expect(called).toEqual(1);
        backend.assertAllGetsCalled();
      })));


      it('should support pending requests for different raw URLs', async(inject((Http http, Zone zone) {
        backend.expectGET('a', VALUE, times: 1);

        var called = 0;
        zone.run(() {
          http.getString('a[some string]', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 1;
          });
          http.getString('a[different string]', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);
        backend.flush();

        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should support caching', async(inject((Http http, Zone zone) {
        var called = 0;
        zone.run(() {
          http.getString('fromCache', cache: cache).then((v) {
            expect(v).toBe(CACHED_VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);
        backend.flush();
        nextTurn();

        expect(called).toEqual(1);
        backend.assertAllGetsCalled();
      })));
    });

    describe('caching', () {
      it('should not cache if no cache is present', async(inject((Http http, Zone zone) {
        backend.expectGET('a', VALUE, times: 2);

        var called = 0;
        zone.run(() {
          http.getString('a').then((v) {
            expect(v).toBe(VALUE);
            called += 1;
          });
          http.getString('a').then((v) {
            expect(v).toBe(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);

        backend.flush();
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should return a pending request', async(inject((Http http, Zone zone) {
        backend.expectGET('a', VALUE, times: 1);

        var called = 0;
        zone.run(() {
          http.getString('a', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 1;
          });
          http.getString('a', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);
        backend.flush();
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should not return a pending request after the request is complete', async(inject((Http http, Zone zone) {
        backend.expectGET('a', VALUE, times: 2);

        var called = 0;
        zone.run(() {
          http.getString('a', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);
        backend.flush();
        nextTurn(true);

        zone.run(() {
          http.getString('a', cache: cache).then((v) {
            expect(v).toBe(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(1);
        backend.flush();
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should return a cached value if present', async(inject((Http http, Zone zone) {
        var called = 0;
        // The URL string 'f' is primed in the FakeCache
        zone.run(() {
          http.getString('f', cache: cache).then((v) {
            expect(v).toBe(CACHED_VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);
        backend.flush();
        nextTurn();

        expect(called).toEqual(1);
        backend.assertAllGetsCalled();
      })));
    });


    describe('error handling', () {
      it('should reject 404 status codes', async(inject((Http http, Zone zone) {
        backend.expectGET('404.html', VALUE, code: 404);

        var response = null;
        zone.run(() {
          http.getString('404.html').then(
            (v) => response = 'FAILED',
            onError:(v) => response = v);
        });

        expect(response).toBe(null);
        backend.flush();
        nextTurn(true);
        expect(response.status).toEqual(404);
        expect(response.toString()).toEqual('HTTP 404: val');

        backend.assertAllGetsCalled();
      })));
    });
  });
}
