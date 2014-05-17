library http_spec;

import '../_specs.dart';

import 'dart:async';

var VALUE = 'val';
var CACHED_VALUE = 'cached_value';

class FakeCache extends UnboundedCache<String, HttpResponse> {
  get(x) => x == 'f' ? new HttpResponse(200, CACHED_VALUE) : null;
  put(_,__) => null;

}

class SubstringRewriter extends UrlRewriter {
  call(String x) => x.substring(0, 1);
}

class MockLocation {
  String _url;
  MockLocation(this._url);
  get href => _url == null ? '' : _url;
}

class MockLocationWrapper implements LocationWrapper {
  String url;
  get location => new MockLocation(url);
}

void main() {
  describe('http', () {
    MockHttpBackend backend;
    MockLocationWrapper locationWrapper;

    var cache;

    flush() {
      microLeap();
      backend.flush();
      microLeap();
    }

    beforeEachModule((Module module) {
      backend = new MockHttpBackend();
      locationWrapper = new MockLocationWrapper();
      cache = new FakeCache();
      module
        ..bind(HttpBackend, toValue: backend)
        ..bind(LocationWrapper, toValue: locationWrapper)
        ..bind(ExceptionHandler, toImplementation: LoggingExceptionHandler);
    });

    afterEach((ExceptionHandler eh, Scope scope) {
      scope.apply();
      backend.verifyNoOutstandingRequest();
      backend.verifyNoOutstandingExpectation();
      (eh as LoggingExceptionHandler).assertEmpty();
    });

    describe('the instance', () {
      Http http;
      var callback;

      beforeEach((Http h) {
        http = h;
        callback = guinness.createSpy('callback');
      });


      it('should do basic request', async(() {
        backend.expect('GET', '/url').respond('');
        http(url: '/url', method: 'GET');
        flush();
      }));


      it('should pass data if specified', async(() {
        backend.expect('POST', '/url', 'some-data').respond('');
        http(url: '/url', method: 'POST', data: 'some-data');
        flush();
      }));


      it('should not pass data if not specificed', async(() {
        // NOTE(deboer): I don't have a good why to test this since
        // a null in backend.expect's data parameter means "undefined;
        // we don't care about the data field.
        backend.expect('POST', '/url', 'null').respond('');

        http(url: '/url', method: 'POST');
        expect(() {
          flush();
        }).toThrow('with different data');

        // satisfy the expectation for our afterEach's assert.
        http(url: '/url', method: 'POST', data: 'null');
        flush();
      }));

      describe('backend', () {
        it('should pass on withCredentials to backend and use GET as default method',
            async(() {
          backend.expect('GET', '/url', null, null, true).respond('');
          http(url: '/url', method: 'GET', withCredentials: true);
          flush();
        }));
      });


      describe('params', () {
        it('should do basic request with params and encode', async(() {
          backend.expect('GET', '/url?a%3D=%3F%26&b=2').respond('');
          http(url: '/url', params: {'a=':'?&', 'b':2}, method: 'GET');
          flush();
        }));


        it('should merge params if url contains some already', async(() {
          backend.expect('GET', '/url?c=3&a=1&b=2').respond('');
          http(url: '/url?c=3', params: {'a':1, 'b':2}, method: 'GET');
          flush();
        }));


        it('should jsonify objects in params map', async(() {
          backend.expect('GET', '/url?a=1&b=%7B%22c%22:3%7D').respond('');
          http(url: '/url', params: {'a':1, 'b':{'c':3}}, method: 'GET');
          flush();
        }));


        it('should expand arrays in params map', async(() {
          backend.expect('GET', '/url?a=1&a=2&a=3').respond('');
          http(url: '/url', params: {'a': [1,2,3]}, method: 'GET');
          flush();
        }));


        it('should not encode @ in url params', async(() {
          //encodeURIComponent is too agressive and doesn't follow http://www.ietf.org/rfc/rfc3986.txt
          //with regards to the character set (pchar) allowed in path segments
          //so we need this test to make sure that we don't over-encode the params and break stuff
          //like buzz api which uses @self

          backend.expect('GET', r'/Path?!do%26h=g%3Da+h&:bar=$baz@1').respond('');
          http(url: '/Path', params: {':bar': r'$baz@1', '!do&h': 'g=a h'}, method: 'GET');
          flush();
        }));
      });


      describe('callbacks', () {

        it('should pass in the response object when a request is successful', async(() {
          backend.expect('GET', '/url').respond(207, 'my content', {'content-encoding': 'smurf'});
          http(url: '/url', method: 'GET').then((HttpResponse response) {
            expect(response.data).toEqual('my content');
            expect(response.status).toEqual(207);
            expect(response.headers()).toEqual({'content-encoding': 'smurf'});
            expect(response.config.url).toEqual('/url');
            callback();
          });

          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should pass in the response object when a request failed', async(() {
          backend.expect('GET', '/url').respond(543, 'bad error', {'request-id': '123'});
          http(url: '/url', method: 'GET').then((_) {}, onError: (response) {
            expect(response.data).toEqual('bad error');
            expect(response.status).toEqual(543);
            expect(response.headers()).toEqual({'request-id': '123'});
            expect(response.config.url).toEqual('/url');
            callback();
          });

          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        describe('success', () {
          it('should allow http specific callbacks to be registered via "success"', async(() {
            backend.expect('GET', '/url').respond(207, 'my content', {'content-encoding': 'smurf'});
            http(url: '/url', method: 'GET').then((r) {
              expect(r.data).toEqual('my content');
              expect(r.status).toEqual(207);
              expect(r.headers()).toEqual({'content-encoding': 'smurf'});
              expect(r.config.url).toEqual('/url');
              callback();
            });

            flush();

            expect(callback).toHaveBeenCalledOnce();
          }));
        });


        describe('error', () {
          it('should allow http specific callbacks to be registered via "error"', async(() {
            backend.expect('GET', '/url').respond(543, 'bad error', {'request-id': '123'});
            http(url: '/url', method: 'GET').then((_) {}, onError: (r) {
              if (r is! HttpResponse) { throw r; }
              expect(r.data).toEqual('bad error');
              expect(r.status).toEqual(543);
              expect(r.headers()).toEqual({'request-id': '123'});
              expect(r.config.url).toEqual('/url');
              callback();
            });

            flush();

            expect(callback).toHaveBeenCalledOnce();
          }));
        });
      });


      describe('response headers', () {

        it('should return single header', async(() {
          backend.expect('GET', '/url').respond('', {'date': 'date-val'});
          callback.andCallFake((r) {
            expect(r.headers('date')).toEqual('date-val');
          });

          http(url: '/url', method: 'GET').then(callback);

          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should return null when single header does not exist', async(() {
          backend.expect('GET', '/url').respond('', {'Some-Header': 'Fake'});
          callback.andCallFake((r) {
            r.headers(); // we need that to get headers parsed first
            expect(r.headers('nothing')).toEqual(null);
          });

          http(url: '/url', method: 'GET').then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should return all headers as object', async(() {
          backend.expect('GET', '/url').respond('', {
              'content-encoding': 'gzip',
              'server': 'Apache'
          });

          callback.andCallFake((r) {
            expect(r.headers()).toEqual({'content-encoding': 'gzip', 'server': 'Apache'});
          });

          http(url: '/url', method: 'GET').then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should return empty object for jsonp request', async(() {
          callback.andCallFake((r) {
            expect(r.headers()).toEqual({});
          });

          backend.expect('JSONP', '/some').respond(200);
          http(url: '/some', method: 'JSONP').then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));
      });


      describe('response headers parser', () {
        parseHeaders(x) => Http.parseHeaders(new MockHttpRequest(null, null, x));

        it('should parse basic', () {
          var parsed = parseHeaders(
              'date: Thu, 04 Aug 2011 20:23:08 GMT\n' +
              'content-encoding: gzip\n' +
              'transfer-encoding: chunked\n' +
              'x-cache-info: not cacheable; response has already expired, not cacheable; response has already expired\n' +
              'connection: Keep-Alive\n' +
              'x-backend-server: pm-dekiwiki03\n' +
              'pragma: no-cache\n' +
              'server: Apache\n' +
              'x-frame-options: DENY\n' +
              'content-type: text/html; charset=utf-8\n' +
              'vary: Cookie, Accept-Encoding\n' +
              'keep-alive: timeout=5, max=1000\n' +
              'expires: Thu: , 19 Nov 1981 08:52:00 GMT\n');

          expect(parsed['date']).toEqual('Thu, 04 Aug 2011 20:23:08 GMT');
          expect(parsed['content-encoding']).toEqual('gzip');
          expect(parsed['transfer-encoding']).toEqual('chunked');
          expect(parsed['keep-alive']).toEqual('timeout=5, max=1000');
        });


        it('should parse lines without space after colon', () {
          expect(parseHeaders('key:value')['key']).toEqual('value');
        });


        it('should trim the values', () {
          expect(parseHeaders('key:    value ')['key']).toEqual('value');
        });


        it('should allow headers without value', () {
          expect(parseHeaders('key:')['key']).toEqual('');
        });


        it('should merge headers with same key', () {
          expect(parseHeaders('key: a\nkey:b\n')['key']).toEqual('a, b');
        });


        it('should normalize keys to lower case', () {
          expect(parseHeaders('KeY: value')['key']).toEqual('value');
        });


        it('should parse CRLF as delimiter', () {
          // IE does use CRLF
          expect(parseHeaders('a: b\r\nc: d\r\n')).toEqual({'a': 'b', 'c': 'd'});
          expect(parseHeaders('a: b\r\nc: d\r\n')['a']).toEqual('b');
        });


        it('should parse tab after semi-colon', () {
          expect(parseHeaders('a:\tbb')['a']).toEqual('bb');
          expect(parseHeaders('a: \tbb')['a']).toEqual('bb');
        });
      });


      describe('request headers', () {

        it('should send custom headers', async(() {
          backend.expect('GET', '/url', null, (headers) {
            return headers['Custom'] == 'header';
          }).respond('');

          http(url: '/url', method: 'GET', headers: {
              'Custom': 'header',
          });

          flush();
        }));


        it('should set default headers for GET request', async(() {
          backend.expect('GET', '/url', null, (headers) {
            return headers['Accept'] == 'application/json, text/plain, */*';
          }).respond('');

          http(url: '/url', method: 'GET', headers: {});
          flush();
        }));


        it('should set default headers for POST request', async(() {
          backend.expect('POST', '/url', 'messageBody', (headers) {
            return headers['Accept'] == 'application/json, text/plain, */*' &&
            headers['Content-Type'] == 'application/json;charset=utf-8';
          }).respond('');

          http(url: '/url', method: 'POST', headers: {}, data: 'messageBody');
          flush();
        }));


        it('should set default headers for PUT request', async(() {
          backend.expect('PUT', '/url', 'messageBody', (headers) {
            return headers['Accept'] == 'application/json, text/plain, */*' &&
            headers['Content-Type'] == 'application/json;charset=utf-8';
          }).respond('');

          http(url: '/url', method: 'PUT', headers: {}, data: 'messageBody');
          flush();
        }));

        it('should set default headers for PATCH request', async(() {
          backend.expect('PATCH', '/url', 'messageBody', (headers) {
            return headers['Accept'] == 'application/json, text/plain, */*' &&
            headers['Content-Type'] == 'application/json;charset=utf-8';
          }).respond('');

          http(url: '/url', method: 'PATCH', headers: {}, data: 'messageBody');
          flush();
        }));

        it('should set default headers for custom HTTP method', async(() {
          backend.expect('FOO', '/url', null, (headers) {
            return headers['Accept'] == 'application/json, text/plain, */*';
          }).respond('');

          http(url: '/url', method: 'FOO', headers: {});
          flush();
        }));


        it('should override default headers with custom', async(() {
          backend.expect('POST', '/url', 'messageBody', (headers) {
            return headers['Accept'] == 'Rewritten' &&
            headers['Content-Type'] == 'Rewritten';
          }).respond('');

          http(url: '/url', method: 'POST', data: 'messageBody', headers: {
              'Accept': 'Rewritten',
              'Content-Type': 'Rewritten'
          });
          flush();
        }));

        it('should override default headers with custom in a case insensitive manner', async(() {
          backend.expect('POST', '/url', 'messageBody', (headers) {
            return headers['accept'] == 'Rewritten' &&
            headers['content-type'] == 'Content-Type Rewritten' &&
            headers['Accept'] == null &&
            headers['Content-Type'] == null;
          }).respond('');

          http(url: '/url', method: 'POST', data: 'messageBody', headers: {
              'accept': 'Rewritten',
              'content-type': 'Content-Type Rewritten'
          });
          flush();
        }));

        it('should not set XSRF cookie for cross-domain requests', async((BrowserCookies cookies) {
          cookies['XSRF-TOKEN'] = 'secret';
          locationWrapper.url = 'http://host.com/base';
          backend.expect('GET', 'http://www.test.com/url', null, (headers) {
            return headers['X-XSRF-TOKEN'] == null;
          }).respond('');

          http(url: 'http://www.test.com/url', method: 'GET', headers: {});
          flush();
        }));


        it('should not send Content-Type header if request data/body is null', async(() {
          backend.expect('POST', '/url', null, (headers) {
            return !headers.containsKey('Content-Type');
          }).respond('');

          backend.expect('POST', '/url2', null, (headers) {
            return !headers.containsKey('content-type');
          }).respond('');

          http(url: '/url', method: 'POST');
          http(url: '/url2', method: 'POST', headers: {'content-type': 'Rewritten'});
          flush();
        }));


        it('should set the XSRF cookie into a XSRF header', async((BrowserCookies cookies) {
          checkXSRF(secret, [header]) {
            return (headers) {
              return headers[header != null ? header : 'X-XSRF-TOKEN'] == secret;
            };
          }

          cookies['XSRF-TOKEN'] = 'secret';
          cookies['aCookie'] = 'secret2';
          backend.expect('GET', '/url', null, checkXSRF('secret')).respond('');
          backend.expect('POST', '/url', null, checkXSRF('secret')).respond('');
          backend.expect('PUT', '/url', null, checkXSRF('secret')).respond('');
          backend.expect('DELETE', '/url', null, checkXSRF('secret')).respond('');
          backend.expect('GET', '/url', null, checkXSRF('secret', 'aHeader')).respond('');
          backend.expect('GET', '/url', null, checkXSRF('secret2')).respond('');

          http(url: '/url', method: 'GET');
          http(url: '/url', method: 'POST', headers: {'S-ome': 'Header'});
          http(url: '/url', method: 'PUT', headers: {'Another': 'Header'});
          http(url: '/url', method: 'DELETE', headers: {});
          http(url: '/url', method: 'GET', xsrfHeaderName: 'aHeader');
          http(url: '/url', method: 'GET', xsrfCookieName: 'aCookie');

          flush();
        }));

        it('should send execute result if header value is function', async(() {
          var headerConfig = {'Accept': () { return 'Rewritten'; }};

          checkHeaders(headers) {
            return headers['Accept'] == 'Rewritten';
          }

          backend.expect('GET', '/url', null, checkHeaders).respond('');
          backend.expect('POST', '/url', null, checkHeaders).respond('');
          backend.expect('PUT', '/url', null, checkHeaders).respond('');
          backend.expect('PATCH', '/url', null, checkHeaders).respond('');
          backend.expect('DELETE', '/url', null, checkHeaders).respond('');

          http(url: '/url', method: 'GET', headers: headerConfig);
          http(url: '/url', method: 'POST', headers: headerConfig);
          http(url: '/url', method: 'PUT', headers: headerConfig);
          http(url: '/url', method: 'PATCH', headers: headerConfig);
          http(url: '/url', method: 'DELETE', headers: headerConfig);

          flush();
        }));
      });


      describe('short methods', () {

        checkHeader(name, value) {
          return (headers) {
            return headers[name] == value;
          };
        }

        it('should have get()', async(() {
          backend.expect('GET', '/url').respond('');
          http.get('/url');
          flush();
        }));


        it('get() should allow config param', async(() {
          backend.expect('GET', '/url', null, checkHeader('Custom', 'Header')).respond('');
          http.get('/url', headers: {'Custom': 'Header'});
          flush();
        }));


        it('should have delete()', async(() {
          backend.expect('DELETE', '/url').respond('');
          http.delete('/url');
          flush();
        }));


        it('delete() should allow config param', async(() {
          backend.expect('DELETE', '/url', null, checkHeader('Custom', 'Header')).respond('');
          http.delete('/url', headers: {'Custom': 'Header'});
          flush();
        }));


        it('should have head()', async(() {
          backend.expect('HEAD', '/url').respond('');
          http.head('/url');
          flush();
        }));


        it('head() should allow config param', async(() {
          backend.expect('HEAD', '/url', null, checkHeader('Custom', 'Header')).respond('');
          http.head('/url', headers: {'Custom': 'Header'});
          flush();
        }));


        it('should have post()', async(() {
          backend.expect('POST', '/url', 'some-data').respond('');
          http.post('/url', 'some-data');
          flush();
        }));


        it('post() should allow config param', async(() {
          backend.expect('POST', '/url', 'some-data', checkHeader('Custom', 'Header')).respond('');
          http.post('/url', 'some-data', headers: {'Custom': 'Header'});
          flush();
        }));


        it('should have put()', async(() {
          backend.expect('PUT', '/url', 'some-data').respond('');
          http.put('/url', 'some-data');
          flush();
        }));


        it('put() should allow config param', async(() {
          backend.expect('PUT', '/url', 'some-data', checkHeader('Custom', 'Header')).respond('');
          http.put('/url', 'some-data', headers: {'Custom': 'Header'});
          flush();
        }));


        it('should have jsonp()', async(() {
          backend.expect('JSONP', '/url').respond('');
          http.jsonp('/url');
          flush();
        }));


        it('jsonp() should allow config param', async(() {
          backend.expect('JSONP', '/url', null, checkHeader('Custom', 'Header')).respond('');
          http.jsonp('/url', headers: {'Custom': 'Header'});
          flush();
        }));
      });


      describe('cache', () {

        Cache cache;

        beforeEach((() {
          cache = new UnboundedCache();
        }));


        doFirstCacheRequest([String method, int respStatus, Map headers]) {
          backend.expect(method != null ? method :'GET', '/url')
          .respond(respStatus != null ? respStatus : 200, 'content', headers);
          http(method: method != null ? method : 'GET', url: '/url', cache: cache)
          .then((_){}, onError: (_){});
          flush();
        }


        it('should cache GET request when cache is provided', async(() {
          doFirstCacheRequest();

          http(method: 'get', url: '/url', cache: cache).then(callback);

          microLeap();

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content');
        }));


        it('should not cache when cache is not provided', async(() {
          doFirstCacheRequest();

          backend.expect('GET', '/url').respond();
          http(method: 'GET', url: '/url');
          flush();
        }));


        it('should perform request when cache cleared', async(() {
          doFirstCacheRequest();

          cache.removeAll();
          backend.expect('GET', '/url').respond();
          http(method: 'GET', url: '/url', cache: cache);
          flush();
        }));


        it('should not cache POST request', async(() {
          doFirstCacheRequest('POST');

          backend.expect('POST', '/url').respond('content2');
          http(method: 'POST', url: '/url', cache: cache).then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content2');
        }));


        it('should not cache PUT request', async(() {
          doFirstCacheRequest('PUT');

          backend.expect('PUT', '/url').respond('content2');
          http(method: 'PUT', url: '/url', cache: cache).then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content2');
        }));


        it('should not cache DELETE request', async(() {
          doFirstCacheRequest('DELETE');

          backend.expect('DELETE', '/url').respond(206);
          http(method: 'DELETE', url: '/url', cache: cache).then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should not cache non 2xx responses', async(() {
          doFirstCacheRequest('GET', 404);

          backend.expect('GET', '/url').respond('content2');
          http(method: 'GET', url: '/url', cache: cache).then(callback);
          flush();

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content2');
        }));


        it('should cache the headers as well', async(() {
          doFirstCacheRequest('GET', 200, {'content-encoding': 'gzip', 'server': 'Apache'});
          callback.andCallFake((r) {
            expect(r.headers()).toEqual({'content-encoding': 'gzip', 'server': 'Apache'});
            expect(r.headers('server')).toEqual('Apache');
          });

          http(method: 'GET', url: '/url', cache: cache).then(callback);
          microLeap();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should not share the cached headers object instance', async(() {
          doFirstCacheRequest('GET', 200, {'content-encoding': 'gzip', 'server': 'Apache'});
          callback.andCallFake((r) {
            expect(r.headers()).toEqual(cache.get('/url').headers());
            expect(r.headers()).not.toBe(cache.get('/url').headers());
          });

          http(method: 'GET', url: '/url', cache: cache).then(callback);
          microLeap();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should cache status code as well', async(() {
          doFirstCacheRequest('GET', 201);
          callback.andCallFake((r) {
            expect(r.status).toEqual(201);
          });

          http(method: 'get', url: '/url', cache: cache).then(callback);
          microLeap();

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should use cache even if second request was made before the first returned', async(() {
          backend.expect('GET', '/url').respond(201, 'fake-response');

          callback.andCallFake((r) {
            expect(r.data).toEqual('fake-response');
            expect(r.status).toEqual(201);
          });

          http(method: 'GET', url: '/url', cache: cache).then(callback);
          http(method: 'GET', url: '/url', cache: cache).then(callback);

          flush();

          expect(callback).toHaveBeenCalled();
          expect(callback.callCount).toEqual(2);
        }));


        describe('http.defaults.cache', () {

          it('should be null by default', () {
            expect(http.defaults.cache).toBeNull();
          });

          it('should cache requests when no cache given in request config', async(() {
            http.defaults.cache = cache;

            // First request fills the cache from server response.
            backend.expect('GET', '/url').respond(200, 'content');
            http(method: 'GET', url: '/url'); // Notice no cache given in config.
            flush();

            // Second should be served from cache, without sending request to server.
            http(method: 'get', url: '/url').then(callback);
            microLeap();

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content');

            // Invalidate cache entry.
            http.defaults.cache.remove("/url");

            // After cache entry removed, a request should be sent to server.
            backend.expect('GET', '/url').respond(200, 'content');
            http(method: 'GET', url: '/url');
            flush();
          }));

          it('should have less priority than explicitly given cache', async(() {
            var localCache = new UnboundedCache();
            http.defaults.cache = cache;

            // Fill local cache.
            backend.expect('GET', '/url').respond(200, 'content-local-cache');
            http(method: 'GET', url: '/url', cache: localCache);
            flush();

            // Fill default cache.
            backend.expect('GET', '/url').respond(200, 'content-default-cache');
            http(method: 'GET', url: '/url');
            flush();

            // Serve request from default cache when no local given.
            http(method: 'get', url: '/url').then(callback);
            microLeap();

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content-default-cache');
            callback.reset();

            // Serve request from local cache when it is given (but default filled too).
            http(method: 'get', url: '/url', cache: localCache).then(callback);
            microLeap();

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('content-local-cache');
          }));

          it('should be skipped if {cache: false} is passed in request config', async(() {
            http.defaults.cache = cache;

            backend.expect('GET', '/url').respond(200, 'content');
            http(method: 'GET', url: '/url');
            flush();

            backend.expect('GET', '/url').respond();
            http(method: 'GET', url: '/url', cache: false);
            flush();
          }));
        });
      });


      // NOTE: We are punting on timeouts for now until we understand
      // Dart futures fully.
      xdescribe('timeout', () {

        it('should abort requests when timeout promise resolves', (q) {
          var canceler = q.defer();

          backend.expect('GET', '/some').respond(200);

          http(method: 'GET', url: '/some', timeout: canceler.promise).error(
                  (data, status, headers, config) {
                expect(data).toBeNull();
                expect(status).toEqual(0);
                expect(headers()).toEqual({});
                expect(config.url).toEqual('/some');
                callback();
              });

          //rootScope.apply(() {
          canceler.resolve();
          //});

          expect(callback).toHaveBeenCalled();
          backend.verifyNoOutstandingExpectation();
          backend.verifyNoOutstandingRequest();
        });
      });


      describe('pendingRequests', () {

        it('should be an array of pending requests', async(() {
          backend.when('GET').respond(200);
          expect(http.pendingRequests.length).toEqual(0);

          http(method: 'get', url: '/some');
          microLeap();
          expect(http.pendingRequests.length).toEqual(1);

          flush();
          expect(http.pendingRequests.length).toEqual(0);
        }));


        // TODO(deboer): I think this test is incorrect.
        // pending requests should refer to the number of requests
        // on-the-wire, not the number of times a URL was requested.
        xit('should update pending requests even when served from cache', async(() {
          var cache = new UnboundedCache();
          backend.when('GET').respond(200);

          http(method: 'get', url: '/cached', cache: cache);
          http(method: 'get', url: '/cached', cache: cache);
          expect(http.pendingRequests.length).toEqual(2);

          flush();

          expect(http.pendingRequests.length).toEqual(0);

          http(method: 'get', url: '/cached', cache: true);
          guinness.spyOn(http.pendingRequests, 'add').andCallThrough();
          //expect(http.pendingRequests.add).toHaveBeenCalledOnce();

          expect(http.pendingRequests.length).toEqual(0);
        }));


        it('should remove the request before firing callbacks', async(() {
          backend.when('GET').respond(200);
          http(method: 'get', url: '/url').then((_) {
            expect(http.pendingRequests.length).toEqual(0);
          });
          microLeap();

          expect(http.pendingRequests.length).toEqual(1);
          flush();
        }));
      });


      describe('defaults', () {

        it('should expose the defaults object at runtime', async(() {
          expect(http.defaults).toBeDefined();

          http.defaults.headers['common']['foo'] = 'bar';
          backend.expect('GET', '/url', null, (headers) {
            return headers['foo'] == 'bar';
          }).respond('');

          http.get('/url');
          flush();
        }));
      });
    });

    describe('url rewriting', () {
      beforeEachModule((Module module) {
        module.bind(UrlRewriter, toImplementation: SubstringRewriter);
      });


      it('should rewrite URLs before calling the backend', async((Http http, VmTurnZone zone) {
        backend.when('GET', 'a').respond(200, VALUE);

        var called = 0;
        zone.run(() {
          http.get('a[not sent to backed]').then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);

        flush();

        expect(called).toEqual(1);
      }));


      it('should support pending requests for different raw URLs', async((Http http, VmTurnZone zone) {
        backend.when('GET', 'a').respond(200, VALUE);

        var called = 0;
        zone.run(() {
          http.get('a[some string]', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 1;
          });
          http.get('a[different string]', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);
        flush();

        expect(called).toEqual(11);
      }));


      it('should support caching', async((Http http, VmTurnZone zone) {
        var called = 0;
        zone.run(() {
          http.get('fromCache', cache: cache).then((v) {
            expect(v.responseText).toEqual(CACHED_VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(1);
      }));
    });

    describe('caching', () {
      it('should not cache if no cache is present', async((Http http, VmTurnZone zone) {
        backend.when('GET', 'a').respond(200, VALUE, null);

        var called = 0;
        zone.run(() {
          http.get('a').then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 1;
          });
          http.get('a').then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);

        flush();

        expect(called).toEqual(11);
      }));


      it('should return a pending request', async((Http http, VmTurnZone zone) {
        backend.when('GET', 'a').respond(200, VALUE);

        var called = 0;
        zone.run(() {
          http.get('a', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 1;
          });
          http.get('a', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(0);
        flush();

        expect(called).toEqual(11);
      }));


      it('should not return a pending request after the request is complete', async((Http http, VmTurnZone zone) {
        backend.when('GET', 'a').respond(200, VALUE, null);

        var called = 0;
        zone.run(() {
          http.get('a', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 1;
          });
        });

        expect(called).toEqual(0);
        flush();

        zone.run(() {
          http.get('a', cache: cache).then((v) {
            expect(v.responseText).toEqual(VALUE);
            called += 10;
          });
        });

        expect(called).toEqual(1);
        flush();

        expect(called).toEqual(11);
      }));


      it('should return a cached value if present', async((Http http, VmTurnZone zone) {
        var called = 0;
        // The URL string 'f' is primed in the FakeCache
        zone.run(() {
          http.get('f', cache: cache).then((v) {
            expect(v.responseText).toEqual(CACHED_VALUE);
            called += 1;
          });
          expect(called).toEqual(0);
        });

        expect(called).toEqual(1);
      }));
    });


    describe('error handling', () {
      it('should reject 404 status codes', async((Http http, VmTurnZone zone) {
        backend.when('GET', '404.html').respond(404, VALUE);

        var response = null;
        zone.run(() {
          http.get('404.html').then(
                  (v) => response = 'FAILED',
              onError:(v) { assert(v != null); return response = v; });
        });

        expect(response).toEqual(null);
        flush();
        expect(response.status).toEqual(404);
        expect(response.toString()).toEqual('HTTP 404: val');
      }));
    });


    describe('interceptors', () {
      it('should chain request, requestReject, response and responseReject interceptors', async(() {
        (HttpInterceptors interceptors, Http http) {
          var savedConfig, savedResponse;
          interceptors.add(new HttpInterceptor(
              request: (config) {
                config.url += '/1';
                savedConfig = config;
                return new Future.error('/2');
              }));
          interceptors.add(new HttpInterceptor(
              requestError: (error) {
                savedConfig.url += error;
                return new Future.value(savedConfig);
              }));
          interceptors.add(new HttpInterceptor(
              responseError: (rejection) =>
              new HttpResponse.copy(savedResponse,
              data: savedResponse.data + rejection)
          ));
          interceptors.add(new HttpInterceptor(
              response: (response) {
                savedResponse = new HttpResponse.copy(
                    response, data: response.data + ':1');
                return new Future.error(':2');
              }));
          var response;
          backend.expect('GET', '/url/1/2').respond('response');
          http(method: 'GET', url: '/url').then((r) {
            response = r;
          });
          flush();
          expect(response.data).toEqual('response:1:2');
        };
      }));


      it('should verify order of execution', async(
          (HttpInterceptors interceptors, Http http) {
            interceptors.add(new HttpInterceptor(
                request: (config) {
                  config.url += '/outer';
                  return config;
                },
                response: (response) {
                  return new HttpResponse.copy(
                      response, data: '{' + response.data + '} outer');
                }));
            interceptors.add(new HttpInterceptor(
                request: (config) {
                  config.url += '/inner';
                  return config;
                },
                response: (response) {
                  return new HttpResponse.copy(
                      response, data: '{' + response.data + '} inner');
                }));

            var response;
            backend.expect('GET', '/url/outer/inner').respond('response');
            http(method: 'GET', url: '/url').then((r) {
              response = r;
            });
            flush();
            expect(response.data).toEqual('{{response} inner} outer');
          }));

      describe('transformData', () {
        Http http;
        var callback;

        beforeEach((Http h) {
          http = h;
          callback = guinness.createSpy('callback');
        });

        describe('request', () {

          describe('default', () {

            it('should transform object into json', async(() {
              backend.expect('POST', '/url', '{"one":"two"}').respond('');
              http(method: 'POST', url: '/url', data: {'one': 'two'});
              flush();
            }));


            it('should ignore strings', async(() {
              backend.expect('POST', '/url', 'string-data').respond('');
              http(method: 'POST', url: '/url', data: 'string-data');
              flush();
            }));


            it('should ignore File objects', async(() {
              var file = new FakeFile();
              expect(file is File).toBeTruthy();

              backend.expect('POST', '/some', file).respond('');
              http(method: 'POST', url: '/some', data: file);
              flush();
            }));
          });


          it('should have access to request headers', async(() {
            backend.expect('POST', '/url', 'header1').respond(200);
            http.post('/url', 'req',
            headers: {'h1': 'header1'},
            interceptors: new HttpInterceptor(request: (config) {
              config.data = config.header('h1');
              return config;
            })
            ).then(callback);
            flush();

            expect(callback).toHaveBeenCalledOnce();
          }));


          it('should pipeline more functions', async(() {
            backend.expect('POST', '/url', 'REQ-FIRST:V1').respond(200);
            http.post('/url', 'req',
            headers: {'h1': 'v1'},
            interceptors: new HttpInterceptors.of([
                new HttpInterceptor(request: (config) {
                  config.data = config.data + '-first' + ':' + config.header('h1');
                  return config;
                }),
                new HttpInterceptor(request: (config) {
                  config.data = config.data.toUpperCase();
                  return config;
                })
            ])
            ).then(callback);
            flush();

            expect(callback).toHaveBeenCalledOnce();
          }));
        });


        describe('response', () {

          describe('default', () {

            it('should deserialize json objects', async(() {
              backend.expect('GET', '/url').respond('{"foo":"bar","baz":23}');
              http(method: 'GET', url: '/url').then(callback);
              flush();

              expect(callback).toHaveBeenCalledOnce();
              expect(callback.mostRecentCall.positionalArguments[0].data).toEqual({'foo': 'bar', 'baz': 23});
            }));


            it('should deserialize json arrays', async(() {
              backend.expect('GET', '/url').respond('[1, "abc", {"foo":"bar"}]');
              http(method: 'GET', url: '/url').then(callback);
              flush();

              expect(callback).toHaveBeenCalledOnce();
              expect(callback.mostRecentCall.positionalArguments[0].data).toEqual([1, 'abc', {'foo': 'bar'}]);
            }));


            it('should deserialize json with security prefix', async(() {
              backend.expect('GET', '/url').respond(')]}\',\n[1, "abc", {"foo":"bar"}]');
              http(method: 'GET', url: '/url').then(callback);
              flush();

              expect(callback).toHaveBeenCalledOnce();
              expect(callback.mostRecentCall.positionalArguments[0].data).toEqual([1, 'abc', {'foo':'bar'}]);
            }));


            it('should deserialize json with security prefix ")]}\'"', async(() {
              backend.expect('GET', '/url').respond(')]}\'\n\n[1, "abc", {"foo":"bar"}]');
              http(method: 'GET', url: '/url').then(callback);
              flush();

              expect(callback).toHaveBeenCalledOnce();
              expect(callback.mostRecentCall.positionalArguments[0].data).toEqual([1, 'abc', {'foo':'bar'}]);
            }));


            it('should call onError on a JSON parse error', async(() {
              backend.expect('GET', '/url').respond('[x]');
              var callbackCalled = false;
              var onErrorCalled = false;
              http.get('/url').then((_) {
                callbackCalled = true;
              }, onError: (e,s) {
                // Dartium throws "Unexpected character"
                // dart2js/Chrome throws "Unexpected token"
                // dart2js/Firefox throw "unexpected character"
                expect('$e').toContain('nexpected');
                onErrorCalled = true;
              });
              flush();
              expect(callbackCalled).toBeFalsy();
              expect(onErrorCalled).toBeTruthy();
            }));


            it('should not deserialize tpl beginning with ng expression', async(() {
              backend.expect('GET', '/url').respond('{{some}}');
              http.get('/url').then(callback);
              flush();

              expect(callback).toHaveBeenCalledOnce();
              expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('{{some}}');
            }));
          });


          it('should have access to response headers', async(() {
            backend.expect('GET', '/url').respond(200, 'response', {'h1': 'header1'});
            http.get('/url',
            interceptors: new HttpInterceptor(response: (r) {
              return new HttpResponse.copy(r, data: r.headers('h1'));
            })
            ).then(callback);
            flush();

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('header1');
          }));

          it('should pipeline more functions', async(() {
            backend.expect('POST', '/url').respond(200, 'resp', {'h1': 'v1'});
            http.post('/url', '', interceptors: new HttpInterceptors.of([
                new HttpInterceptor(response: (r) {
                  return new HttpResponse.copy(r, data: r.data.toUpperCase());
                }),
                new HttpInterceptor(response: (r) {
                  return new HttpResponse.copy(r, data: r.data + '-first' + ':' + r.headers('h1'));
                })])).then(callback);
            flush();

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.positionalArguments[0].data).toEqual('RESP-FIRST:V1');
          }));
        });
      });
    });
  });
}

class FakeFile implements File {
  DateTime get lastModifiedDate => null;
  String get name => null;
  String get relativePath => null;
  int get size => 0;
  String get type => null;
  Blob slice([int start, int end, String contentType]) => null;
  int get lastModified => new DateTime.now().millisecondsSinceEpoch;
}
