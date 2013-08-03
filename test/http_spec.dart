import "_specs.dart";
import "_http.dart";

import "dart:async";

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
          ..type(UrlRewriter, SubstringRewriter);
      }));


      it('should rewrite URLs before calling the backend', async(inject((Http http) {
        backend.expectGET('a', VALUE, times: 1);

        var called = 0;
        http.getString('a[not sent to backed]').then((v) {
          expect(v).toBe(VALUE);
          called += 1;
        });

        expect(called).toEqual(0);

        backend.flush();
        nextTurn(true);

        expect(called).toEqual(1);
        backend.assertAllGetsCalled();
      })));


      it('should support pending requests for different raw URLs', async(inject((Http http) {
        backend.expectGET('a', VALUE, times: 1);

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
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should support caching', async(inject((Http http) {
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
      })));
    });

    describe('caching', () {
      it('should not cache if no cache is present', async(inject((Http http) {
        backend.expectGET('a', VALUE, times: 2);

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
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should return a pending request', async(inject((Http http) {
        backend.expectGET('a', VALUE, times: 1);

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
        nextTurn(true);

        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should not return a pending request after the request is complete', async(inject((Http http) {
        backend.expectGET('a', VALUE, times: 2);

        var called = 0;
        http.getString('a', cache: cache).then((v) {
          expect(v).toBe(VALUE);
          called += 1;
        });

        expect(called).toEqual(0);
        backend.flush();
        nextTurn(true);

        http.getString('a', cache: cache).then((v) {
          expect(v).toBe(VALUE);
          called += 10;
        });

        expect(called).toEqual(1);
        backend.flush();
        nextTurn(true);
        
        expect(called).toEqual(11);
        backend.assertAllGetsCalled();
      })));


      it('should return a cached value if present', async(inject((Http http) {
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
      })));
    });

    describe('scope digesting', () {
      it('should digest scope after a request', async(inject((Scope scope, Http http) {
        backend.expectGET('a', 'value');

        scope.$watch('fromHttp', (v) {
          scope.digested = v;
        });

        http.getString('a').then((v) {
          scope.fromHttp = v;
        });

        backend.flush();
        nextTurn(true);

        expect(scope.digested).toEqual('value');
      })));


      it('should digest scope after a cached request', async(inject((Scope scope, Http http) {
        scope.$watch('fromHttp', (v) {
          scope.digested = v;
        });

        http.getString('f', cache: cache).then((v) {
          scope.fromHttp = v;
        });

        backend.flush();
        nextTurn(true);

        expect(scope.digested).toEqual('cached_value');
      })));


      it('should digest twice for chained requests', async(inject((Scope scope, Http http) {
        backend.expectGET('a', 'value');
        backend.expectGET('b', 'bval');

        scope.$watch('fromHttp', (v) {
          scope.digested = v;
        });

        http.getString('a').then((v) {
          scope.fromHttp = 'A:$v';
          http.getString('b').then((vb) {
            scope.fromHttp += ' B:$vb';
          });
        });

        backend.flush();
        nextTurn(true);

        expect(scope.digested).toEqual('A:value');

        backend.flush();
        nextTurn(true);

        expect(scope.digested).toEqual('A:value B:bval');
      })));


      it('should NOT digest after an chained runAsync', async(inject((Scope scope, Http http) {
        backend.expectGET('a', 'value');

        scope.$watch('fromHttp', (v) {
          scope.digested = v;
        });

        http.getString('a').then((v) {
          scope.fromHttp = 'then:$v';
          runAsync(() {
            // This is an example of a bug.  If you use runAsync,
            // you are responsible for digesting the scope.
            // In general, don't use runAsync!
            scope.fromHttp = 'async:$v';
          });
        });

        backend.flush();
        nextTurn(true);

        expect(scope.digested).toEqual('then:value');

        // Note that the runAsync has run, but it was not digested.
        scope.$digest();
        expect(scope.digested).toEqual('async:value');
      })));
    });
  });
}
