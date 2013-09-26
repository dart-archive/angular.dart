library http_spec;

import '../_specs.dart';
import '../_http.dart';

var VALUE = 'val';
var CACHED_VALUE = 'cached_value';

class FakeCache extends Cache {
  get(x) => x == 'f' ? new HttpResponse(200, CACHED_VALUE) : null;
  put(_,__) => null;

}

class SubstringRewriter extends UrlRewriter {
  call(String x) => x.substring(0, 1);
}

main() => describe('http', () {
  MockHttpBackend backend;
  var cache;

  beforeEach(module((AngularModule module) {
    backend = new MockHttpBackend();
    cache = new FakeCache();
    module
    ..value(HttpBackend, backend)
    ..type(ExceptionHandler, implementedBy: LoggingExceptionHandler);
  }));

  afterEach(inject((ExceptionHandler eh, Scope scope) {
    scope.$digest();
    backend.verifyNoOutstandingRequest();
    (eh as LoggingExceptionHandler).assertEmpty();
  }));

  describe('the instance', () {
    MockHttpBackend httpBackend;
    Http http;
    var callback;

    beforeEach(inject((HttpBackend hb, Http h) {
      httpBackend = hb;
      http = h;
      callback = jasmine.createSpy('callback');
    }));


    it('should do basic request', () {
      httpBackend.expect('GET', '/url').respond('');
      http(url: '/url', method: 'GET');
    });


    it('should pass data if specified', () {
      httpBackend.expect('POST', '/url', 'some-data').respond('');
      http(url: '/url', method: 'POST', data: 'some-data');
    });


    describe('params', () {
      it('should do basic request with params and encode', () {
        httpBackend.expect('GET', '/url?a%3D=%3F%26&b=2').respond('');
        http(url: '/url', params: {'a=':'?&', 'b':2}, method: 'GET');
      });


      it('should merge params if url contains some already', () {
        httpBackend.expect('GET', '/url?c=3&a=1&b=2').respond('');
        http(url: '/url?c=3', params: {'a':1, 'b':2}, method: 'GET');
      });


      it('should jsonify objects in params map', () {
        httpBackend.expect('GET', '/url?a=1&b=%7B%22c%22:3%7D').respond('');
        http(url: '/url', params: {'a':1, 'b':{'c':3}}, method: 'GET');
      });


      it('should expand arrays in params map', () {
          httpBackend.expect('GET', '/url?a=1&a=2&a=3').respond('');
          http(url: '/url', params: {'a': [1,2,3]}, method: 'GET');
      });


      it('should not encode @ in url params', () {
        //encodeURIComponent is too agressive and doesn't follow http://www.ietf.org/rfc/rfc3986.txt
        //with regards to the character set (pchar) allowed in path segments
        //so we need this test to make sure that we don't over-encode the params and break stuff
        //like buzz api which uses @self

        httpBackend.expect('GET', r'/Path?!do%26h=g%3Da+h&:bar=$baz@1').respond('');
        http(url: '/Path', params: {':bar': r'$baz@1', '!do&h': 'g=a h'}, method: 'GET');
      });
    });


    describe('callbacks', () {

      it('should pass in the response object when a request is thenful', async(() {
        httpBackend.expect('GET', '/url').respond(207, 'my content', {'content-encoding': 'smurf'});
        http(url: '/url', method: 'GET').then((HttpResponse response) {
          expect(response.data).toEqual('my content');
          expect(response.status).toEqual(207);
          expect(response.headers()).toEqual({'content-encoding': 'smurf'});
          expect(response.config.url).toEqual('/url');
          callback();
        });

        httpBackend.flush();
        nextTurn(true);

        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should pass in the response object when a request failed', async(() {
        httpBackend.expect('GET', '/url').respond(543, 'bad error', {'request-id': '123'});
        http(url: '/url', method: 'GET').then((_) {}, onError: (response) {
          expect(response.data).toEqual('bad error');
          expect(response.status).toEqual(543);
          expect(response.headers()).toEqual({'request-id': '123'});
          expect(response.config.url).toEqual('/url');
          callback();
        });

        httpBackend.flush();
        nextTurn(true);

        expect(callback).toHaveBeenCalledOnce();
      }));


      describe('success', () {
        it('should allow http specific callbacks to be registered via "success"', async(() {
          httpBackend.expect('GET', '/url').respond(207, 'my content', {'content-encoding': 'smurf'});
          http(url: '/url', method: 'GET').then((r) {
            expect(r.data).toEqual('my content');
            expect(r.status).toEqual(207);
            expect(r.headers()).toEqual({'content-encoding': 'smurf'});
            expect(r.config.url).toEqual('/url');
            callback();
          });

          httpBackend.flush();
          nextTurn();

          expect(callback).toHaveBeenCalledOnce();
        }));
      });


      describe('error', () {
        it('should allow http specific callbacks to be registered via "error"', async(() {
          httpBackend.expect('GET', '/url').respond(543, 'bad error', {'request-id': '123'});
          http(url: '/url', method: 'GET').then((_) {}, onError: (r) {
            if (r is! HttpResponse) { throw r; }
            expect(r.data).toEqual('bad error');
            expect(r.status).toEqual(543);
            expect(r.headers()).toEqual({'request-id': '123'});
            expect(r.config.url).toEqual('/url');
            callback();
          });

          httpBackend.flush();
          nextTurn(true);

          expect(callback).toHaveBeenCalledOnce();
        }));
      });
    });


    describe('response headers', () {

      it('should return single header', async(() {
        httpBackend.expect('GET', '/url').respond('', {'date': 'date-val'});
        callback.andCallFake((r) {
          expect(r.headers('date')).toEqual('date-val');
        });

        http(url: '/url', method: 'GET').then(callback);

        httpBackend.flush();
        nextTurn(true);

        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should return null when single header does not exist', async(() {
        httpBackend.expect('GET', '/url').respond('', {'Some-Header': 'Fake'});
        callback.andCallFake((r) {
          r.headers(); // we need that to get headers parsed first
          expect(r.headers('nothing')).toEqual(null);
        });

        http(url: '/url', method: 'GET').then(callback);
        httpBackend.flush();
        nextTurn(true);

        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should return all headers as object', async(() {
        httpBackend.expect('GET', '/url').respond('', {
          'content-encoding': 'gzip',
          'server': 'Apache'
        });

        callback.andCallFake((r) {
          expect(r.headers()).toEqual({'content-encoding': 'gzip', 'server': 'Apache'});
        });

        http(url: '/url', method: 'GET').then(callback);
        httpBackend.flush();
        nextTurn(true);

        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should return empty object for jsonp request', async(() {
        callback.andCallFake((r) {
          expect(r.headers()).toEqual({});
        });

        httpBackend.expect('JSONP', '/some').respond(200);
        http(url: '/some', method: 'JSONP').then(callback);
        httpBackend.flush();
        nextTurn(true);

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

      it('should send custom headers', () {
        httpBackend.expect('GET', '/url', null, (headers) {
          return headers['Custom'] == 'header';
        }).respond('');

        http(url: '/url', method: 'GET', headers: {
          'Custom': 'header',
        });

        httpBackend.flush();
      });


      it('should set default headers for GET request', () {
        httpBackend.expect('GET', '/url', null, (headers) {
          return headers['Accept'] == 'application/json, text/plain, */*';
        }).respond('');

        http(url: '/url', method: 'GET', headers: {});
        httpBackend.flush();
      });


      it('should set default headers for POST request', () {
        httpBackend.expect('POST', '/url', 'messageBody', (headers) {
          return headers['Accept'] == 'application/json, text/plain, */*' &&
                 headers['Content-Type'] == 'application/json;charset=utf-8';
        }).respond('');

        http(url: '/url', method: 'POST', headers: {}, data: 'messageBody');
        httpBackend.flush();
      });


      it('should set default headers for PUT request', () {
        httpBackend.expect('PUT', '/url', 'messageBody', (headers) {
          return headers['Accept'] == 'application/json, text/plain, */*' &&
                 headers['Content-Type'] == 'application/json;charset=utf-8';
        }).respond('');

        http(url: '/url', method: 'PUT', headers: {}, data: 'messageBody');
        httpBackend.flush();
      });

      it('should set default headers for PATCH request', () {
        httpBackend.expect('PATCH', '/url', 'messageBody', (headers) {
          return headers['Accept'] == 'application/json, text/plain, */*' &&
                 headers['Content-Type'] == 'application/json;charset=utf-8';
        }).respond('');

        http(url: '/url', method: 'PATCH', headers: {}, data: 'messageBody');
        httpBackend.flush();
      });

      it('should set default headers for custom HTTP method', () {
        httpBackend.expect('FOO', '/url', null, (headers) {
          return headers['Accept'] == 'application/json, text/plain, */*';
        }).respond('');

        http(url: '/url', method: 'FOO', headers: {});
        httpBackend.flush();
      });


      it('should override default headers with custom', () {
        httpBackend.expect('POST', '/url', 'messageBody', (headers) {
          return headers['Accept'] == 'Rewritten' &&
                 headers['Content-Type'] == 'Rewritten';
        }).respond('');

        http(url: '/url', method: 'POST', data: 'messageBody', headers: {
          'Accept': 'Rewritten',
          'Content-Type': 'Rewritten'
        });
        httpBackend.flush();
      });

      it('should override default headers with custom in a case insensitive manner', () {
        httpBackend.expect('POST', '/url', 'messageBody', (headers) {
          return headers['accept'] == 'Rewritten' &&
                 headers['content-type'] == 'Content-Type Rewritten' &&
                 headers['Accept'] == null &&
                 headers['Content-Type'] == null;
        }).respond('');

        http(url: '/url', method: 'POST', data: 'messageBody', headers: {
          'accept': 'Rewritten',
          'content-type': 'Content-Type Rewritten'
        });
        httpBackend.flush();
      });

      xit('should not set XSRF cookie for cross-domain requests', inject(($browser) {
        $browser.cookies('XSRF-TOKEN', 'secret');
        $browser.url('http://host.com/base');
        httpBackend.expect('GET', 'http://www.test.com/url', null, (headers) {
          return headers['X-XSRF-TOKEN'] == null;
        }).respond('');

        http(url: 'http://www.test.com/url', method: 'GET', headers: {});
        httpBackend.flush();
      }));


      it('should not send Content-Type header if request data/body is null', () {
        httpBackend.expect('POST', '/url', null, (headers) {
          return !headers.containsKey('Content-Type');
        }).respond('');

        httpBackend.expect('POST', '/url2', null, (headers) {
          return !headers.containsKey('content-type');
        }).respond('');

        http(url: '/url', method: 'POST');
        http(url: '/url2', method: 'POST', headers: {'content-type': 'Rewritten'});
        httpBackend.flush();
      });


      xit('should set the XSRF cookie into a XSRF header', inject(($browser) {
        checkXSRF(secret, [header]) {
          return (headers) {
            return headers[header || 'X-XSRF-TOKEN'] == secret;
          };
        }

        $browser.cookies('XSRF-TOKEN', 'secret');
        $browser.cookies('aCookie', 'secret2');
        httpBackend.expect('GET', '/url', null, checkXSRF('secret')).respond('');
        httpBackend.expect('POST', '/url', null, checkXSRF('secret')).respond('');
        httpBackend.expect('PUT', '/url', null, checkXSRF('secret')).respond('');
        httpBackend.expect('DELETE', '/url', null, checkXSRF('secret')).respond('');
        httpBackend.expect('GET', '/url', null, checkXSRF('secret', 'aHeader')).respond('');
        httpBackend.expect('GET', '/url', null, checkXSRF('secret2')).respond('');

        http(url: '/url', method: 'GET');
        http(url: '/url', method: 'POST', headers: {'S-ome': 'Header'});
        http(url: '/url', method: 'PUT', headers: {'Another': 'Header'});
        http(url: '/url', method: 'DELETE', headers: {});
        http(url: '/url', method: 'GET', xsrfHeaderName: 'aHeader');
        http(url: '/url', method: 'GET', xsrfCookieName: 'aCookie');

        httpBackend.flush();
      }));

      it('should send execute result if header value is function', inject(() {
        var headerConfig = {'Accept': () { return 'Rewritten'; }};

        checkHeaders(headers) {
          return headers['Accept'] == 'Rewritten';
        }

        httpBackend.expect('GET', '/url', null, checkHeaders).respond('');
        httpBackend.expect('POST', '/url', null, checkHeaders).respond('');
        httpBackend.expect('PUT', '/url', null, checkHeaders).respond('');
        httpBackend.expect('PATCH', '/url', null, checkHeaders).respond('');
        httpBackend.expect('DELETE', '/url', null, checkHeaders).respond('');

        http(url: '/url', method: 'GET', headers: headerConfig);
        http(url: '/url', method: 'POST', headers: headerConfig);
        http(url: '/url', method: 'PUT', headers: headerConfig);
        http(url: '/url', method: 'PATCH', headers: headerConfig);
        http(url: '/url', method: 'DELETE', headers: headerConfig);

        httpBackend.flush();
      }));
    });


    describe('short methods', () {

      checkHeader(name, value) {
        return (headers) {
          return headers[name] == value;
        };
      }

      it('should have get()', () {
        httpBackend.expect('GET', '/url').respond('');
        http.get('/url');
      });


      it('get() should allow config param', () {
        httpBackend.expect('GET', '/url', null, checkHeader('Custom', 'Header')).respond('');
        http.get('/url', headers: {'Custom': 'Header'});
      });


      it('should have delete()', () {
        httpBackend.expect('DELETE', '/url').respond('');
        http.delete('/url');
      });


      it('delete() should allow config param', () {
        httpBackend.expect('DELETE', '/url', null, checkHeader('Custom', 'Header')).respond('');
        http.delete('/url', headers: {'Custom': 'Header'});
      });


      it('should have head()', () {
        httpBackend.expect('HEAD', '/url').respond('');
        http.head('/url');
      });


      it('head() should allow config param', () {
        httpBackend.expect('HEAD', '/url', null, checkHeader('Custom', 'Header')).respond('');
        http.head('/url', headers: {'Custom': 'Header'});
      });


      it('should have post()', () {
        httpBackend.expect('POST', '/url', 'some-data').respond('');
        http.post('/url', 'some-data');
      });


      it('post() should allow config param', () {
        httpBackend.expect('POST', '/url', 'some-data', checkHeader('Custom', 'Header')).respond('');
        http.post('/url', 'some-data', headers: {'Custom': 'Header'});
      });


      it('should have put()', () {
        httpBackend.expect('PUT', '/url', 'some-data').respond('');
        http.put('/url', 'some-data');
      });


      it('put() should allow config param', () {
        httpBackend.expect('PUT', '/url', 'some-data', checkHeader('Custom', 'Header')).respond('');
        http.put('/url', 'some-data', headers: {'Custom': 'Header'});
      });


      it('should have jsonp()', () {
        httpBackend.expect('JSONP', '/url').respond('');
        http.jsonp('/url');
      });


      it('jsonp() should allow config param', () {
        httpBackend.expect('JSONP', '/url', null, checkHeader('Custom', 'Header')).respond('');
        http.jsonp('/url', headers: {'Custom': 'Header'});
      });
    });

    describe('transformData', () {

      describe('request', () {

        describe('default', () {

          it('should transform object into json', () {
            httpBackend.expect('POST', '/url', '{"one":"two"}').respond('');
            http(method: 'POST', url: '/url', data: {'one': 'two'});
          });


          it('should ignore strings', () {
            httpBackend.expect('POST', '/url', 'string-data').respond('');
            http(method: 'POST', url: '/url', data: 'string-data');
          });


          it('should ignore File objects', () {
            var file = new FakeFile();
            expect(file is File).toBeTruthy();

            httpBackend.expect('POST', '/some', file).respond('');
            http(method: 'POST', url: '/some', data: file);
          });
        });


        it('should have access to request headers', async(() {
          httpBackend.expect('POST', '/url', 'header1').respond(200);
          http.post('/url', 'req',
            headers: {'h1': 'header1'},
            transformRequest: (data, headers) {
              return headers('h1');
            }
          ).then(callback);
          httpBackend.flush();
          nextTurn(true);

          expect(callback).toHaveBeenCalledOnce();
        }));


        it('should pipeline more functions', async(() {
          first(d, h) {return d + '-first' + ':' + h('h1');}
          second(d, _) {return d.toUpperCase();}

          httpBackend.expect('POST', '/url', 'REQ-FIRST:V1').respond(200);
          http.post('/url', 'req',
            headers: {'h1': 'v1'},
            transformRequest: [first, second]
          ).then(callback);
          httpBackend.flush();
          nextTurn(true);

          expect(callback).toHaveBeenCalledOnce();
        }));
      });


      describe('response', () {

        describe('default', () {

          it('should deserialize json objects', async(() {
            httpBackend.expect('GET', '/url').respond('{"foo":"bar","baz":23}');
            http(method: 'GET', url: '/url').then(callback);
            httpBackend.flush();
            nextTurn(true);

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.args[0].data).toEqual({'foo': 'bar', 'baz': 23});
          }));


          it('should deserialize json arrays', async(() {
            httpBackend.expect('GET', '/url').respond('[1, "abc", {"foo":"bar"}]');
            http(method: 'GET', url: '/url').then(callback);
            httpBackend.flush();
            nextTurn(true);

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.args[0].data).toEqual([1, 'abc', {'foo': 'bar'}]);
          }));


          it('should deserialize json with security prefix', async(() {
            httpBackend.expect('GET', '/url').respond(')]}\',\n[1, "abc", {"foo":"bar"}]');
            http(method: 'GET', url: '/url').then(callback);
            httpBackend.flush();
            nextTurn(true);

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.args[0].data).toEqual([1, 'abc', {'foo':'bar'}]);
          }));


          it('should deserialize json with security prefix ")]}\'"', async(() {
            httpBackend.expect('GET', '/url').respond(')]}\'\n\n[1, "abc", {"foo":"bar"}]');
            http(method: 'GET', url: '/url').then(callback);
            httpBackend.flush();
            nextTurn(true);

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.args[0].data).toEqual([1, 'abc', {'foo':'bar'}]);
          }));


          it('should not deserialize tpl beginning with ng expression', async(() {
            httpBackend.expect('GET', '/url').respond('{{some}}');
            http.get('/url').then(callback);
            httpBackend.flush();
            nextTurn(true);

            expect(callback).toHaveBeenCalledOnce();
            expect(callback.mostRecentCall.args[0].data).toEqual('{{some}}');
          }));
        });


        it('should have access to response headers', async(() {
          httpBackend.expect('GET', '/url').respond(200, 'response', {'h1': 'header1'});
          http.get('/url',
            transformResponse: (data, headers) {
              return headers('h1');
            }
          ).then(callback);
          httpBackend.flush();
          nextTurn(true);

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.args[0].data).toEqual('header1');
        }));


        it('should pipeline more functions', async(() {
          first(d, h) {return d + '-first' + ':' + h('h1');}
          second(d, _) {return d.toUpperCase();}

          httpBackend.expect('POST', '/url').respond(200, 'resp', {'h1': 'v1'});
          http.post('/url', '', transformResponse: [first, second]).then(callback);
          httpBackend.flush();
          nextTurn(true);

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.args[0].data).toEqual('RESP-FIRST:V1');
        }));
      });
    });


    xdescribe('cache', () {

      var cache;

      beforeEach(inject(($cacheFactory) {
        cache = $cacheFactory('testCache');
      }));


      doFirstCacheRequest([String method, int respStatus, Map headers]) {
        httpBackend.expect(method != null ? method :'GET', '/url')
            .respond(respStatus != null ? respStatus : 200, 'content', headers);
        http(method: method != null ? method : 'GET', url: '/url', cache: cache);
        httpBackend.flush();
      }


      it('should cache GET request when cache is provided', inject(($rootScope) {
        doFirstCacheRequest();

        http(method: 'get', url: '/url', cache: cache).then(callback);
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.

        expect(callback).toHaveBeenCalledOnce();
        expect(callback.mostRecentCall.args[0]).toEqual('content');
      }));


      it('should not cache when cache is not provided', () {
        doFirstCacheRequest();

        httpBackend.expect('GET', '/url').respond();
        http(method: 'GET', url: '/url');
      });


      it('should perform request when cache cleared', () {
        doFirstCacheRequest();

        cache.removeAll();
        httpBackend.expect('GET', '/url').respond();
        http(method: 'GET', url: '/url', cache: cache);
      });


      it('should always call callback asynchronously', () {
        doFirstCacheRequest();
        http(method: 'get', url: '/url', cache: cache).then(callback);

        expect(callback).not.toHaveBeenCalled();
      });


      it('should not cache POST request', () {
        doFirstCacheRequest('POST');

        httpBackend.expect('POST', '/url').respond('content2');
        http(method: 'POST', url: '/url', cache: cache).then(callback);
        httpBackend.flush();

        expect(callback).toHaveBeenCalledOnce();
        expect(callback.mostRecentCall.args[0]).toEqual('content2');
      });


      it('should not cache PUT request', () {
        doFirstCacheRequest('PUT');

        httpBackend.expect('PUT', '/url').respond('content2');
        http(method: 'PUT', url: '/url', cache: cache).then(callback);
        httpBackend.flush();

        expect(callback).toHaveBeenCalledOnce();
        expect(callback.mostRecentCall.args[0]).toEqual('content2');
      });


      it('should not cache DELETE request', () {
        doFirstCacheRequest('DELETE');

        httpBackend.expect('DELETE', '/url').respond(206);
        http(method: 'DELETE', url: '/url', cache: cache).then(callback);
        httpBackend.flush();

        expect(callback).toHaveBeenCalledOnce();
      });


      it('should not cache non 2xx responses', () {
        doFirstCacheRequest('GET', 404);

        httpBackend.expect('GET', '/url').respond('content2');
        http(method: 'GET', url: '/url', cache: cache).then(callback);
        httpBackend.flush();

        expect(callback).toHaveBeenCalledOnce();
        expect(callback.mostRecentCall.args[0]).toEqual('content2');
      });


      it('should cache the headers as well', inject(($rootScope) {
        doFirstCacheRequest('GET', 200, {'content-encoding': 'gzip', 'server': 'Apache'});
        callback.andCallFake((r, s, headers) {
          expect(headers()).toEqual({'content-encoding': 'gzip', 'server': 'Apache'});
          expect(headers('server')).toEqual('Apache');
        });

        http(method: 'GET', url: '/url', cache: cache).then(callback);
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should not share the cached headers object instance', inject(($rootScope) {
        doFirstCacheRequest('GET', 200, {'content-encoding': 'gzip', 'server': 'Apache'});
        callback.andCallFake((r, s, headers) {
          expect(headers()).toEqual(cache.get('/url')[2]);
          expect(headers()).not.toEqual(cache.get('/url')[2]);
        });

        http(method: 'GET', url: '/url', cache: cache).then(callback);
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should cache status code as well', inject(($rootScope) {
        doFirstCacheRequest('GET', 201);
        callback.andCallFake((r, status, h) {
          expect(status).toEqual(201);
        });

        http(method: 'get', url: '/url', cache: cache).then(callback);
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(callback).toHaveBeenCalledOnce();
      }));


      it('should use cache even if second request was made before the first returned', () {
        httpBackend.expect('GET', '/url').respond(201, 'fake-response');

        callback.andCallFake((response, status, headers) {
          expect(response).toEqual('fake-response');
          expect(status).toEqual(201);
        });

        http(method: 'GET', url: '/url', cache: cache).then(callback);
        http(method: 'GET', url: '/url', cache: cache).then(callback);

        httpBackend.flush();
        expect(callback).toHaveBeenCalled();
        expect(callback.callCount).toEqual(2);
      });


      it('should default to status code 200 and empty headers if cache contains a non-array element',
          inject(($rootScope) {
            cache.put('/myurl', 'simple response');
            http.get('/myurl', cache: cache).then((HttpResponse r) {
              expect(r.data).toEqual('simple response');
              expect(r.status).toEqual(200);
              expect(r.headers()).toEqual({});
              callback();
            });

            // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
            expect(callback).toHaveBeenCalledOnce();
          })
      );

      describe('http.defaults.cache', () {

        it('should be null by default', () {
          expect(http.defaults.cache).toBeNull();
        });

        it('should cache requests when no cache given in request config', () {
          http.defaults.cache = cache;

          // First request fills the cache from server response.
          httpBackend.expect('GET', '/url').respond(200, 'content');
          http(method: 'GET', url: '/url'); // Notice no cache given in config.
          httpBackend.flush();

          // Second should be served from cache, without sending request to server.
          http(method: 'get', url: '/url').then(callback);
          // $rootScope.$digest(); TODO: remove, http and scope are decoupled.

          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.args[0]).toEqual('content');

          // Invalidate cache entry.
          http.defaults.cache.remove("/url");

          // After cache entry removed, a request should be sent to server.
          httpBackend.expect('GET', '/url').respond(200, 'content');
          http(method: 'GET', url: '/url');
          httpBackend.flush();
        });

        it('should have less priority than explicitly given cache', inject(($cacheFactory) {
          var localCache = $cacheFactory('localCache');
          http.defaults.cache = cache;

          // Fill local cache.
          httpBackend.expect('GET', '/url').respond(200, 'content-local-cache');
          http(method: 'GET', url: '/url', cache: localCache);
          httpBackend.flush();

          // Fill default cache.
          httpBackend.expect('GET', '/url').respond(200, 'content-default-cache');
          http(method: 'GET', url: '/url');
          httpBackend.flush();

          // Serve request from default cache when no local given.
          http(method: 'get', url: '/url').then(callback);
          // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.args[0]).toEqual('content-default-cache');
          callback.reset();

          // Serve request from local cache when it is given (but default filled too).
          http(method: 'get', url: '/url', cache: localCache).then(callback);
          // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
          expect(callback).toHaveBeenCalledOnce();
          expect(callback.mostRecentCall.args[0]).toEqual('content-local-cache');
        }));

        it('should be skipped if {cache: false} is passed in request config', () {
          http.defaults.cache = cache;

          httpBackend.expect('GET', '/url').respond(200, 'content');
          http(method: 'GET', url: '/url');
          httpBackend.flush();

          httpBackend.expect('GET', '/url').respond();
          http(method: 'GET', url: '/url', cache: false);
          httpBackend.flush();
        });
      });
    });


    xdescribe('timeout', () {

      it('should abort requests when timeout promise resolves', inject(($q) {
        var canceler = $q.defer();

        httpBackend.expect('GET', '/some').respond(200);

        http(method: 'GET', url: '/some', timeout: canceler.promise).error(
            (data, status, headers, config) {
              expect(data).toBeNull();
              expect(status).toEqual(0);
              expect(headers()).toEqual({});
              expect(config.url).toEqual('/some');
              callback();
            });

        //$rootScope.$apply(() {
          canceler.resolve();
        //});

        expect(callback).toHaveBeenCalled();
        httpBackend.verifyNoOutstandingExpectation();
        httpBackend.verifyNoOutstandingRequest();
      }));
    });


    xdescribe('pendingRequests', () {

      it('should be an array of pending requests', () {
        httpBackend.when('GET').respond(200);
        expect(http.pendingRequests.length).toEqual(0);

        http(method: 'get', url: '/some');
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(http.pendingRequests.length).toEqual(1);

        httpBackend.flush();
        expect(http.pendingRequests.length).toEqual(0);
      });


      it('should update pending requests even when served from cache', inject(($rootScope) {
        httpBackend.when('GET').respond(200);

        http(method: 'get', url: '/cached', cache: true);
        http(method: 'get', url: '/cached', cache: true);
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(http.pendingRequests.length).toEqual(2);

        httpBackend.flush();
        expect(http.pendingRequests.length).toEqual(0);

        http(method: 'get', url: '/cached', cache: true);
        jasmine.spyOn(http.pendingRequests, 'add').andCallThrough();
        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(http.pendingRequests.add).toHaveBeenCalledOnce();

        // $rootScope.$apply(); TODO: remove, http and scope are decoupled.
        expect(http.pendingRequests.length).toEqual(0);
      }));


      it('should remove the request before firing callbacks', () {
        httpBackend.when('GET').respond(200);
        http(method: 'get', url: '/url').then(() {
          expect(http.pendingRequests.length).toEqual(0);
        });

        // $rootScope.$digest(); TODO: remove, http and scope are decoupled.
        expect(http.pendingRequests.length).toEqual(1);
        httpBackend.flush();
      });
    });


    xdescribe('defaults', () {

      it('should expose the defaults object at runtime', () {
        expect(http.defaults).toBeDefined();

        //http.defaults.headers.common.foo = 'bar';
        httpBackend.expect('GET', '/url', null, (headers) {
          return headers['foo'] == 'bar';
        }).respond('');

        http.get('/url');
        httpBackend.flush();
      });
    });
  });

  describe('url rewriting', () {
    beforeEach(module((AngularModule module) {
      module
        ..type(UrlRewriter, implementedBy: SubstringRewriter);
    }));


    it('should rewrite URLs before calling the backend', async(inject((Http http, Zone zone) {
      backend.when('GET', 'a').respond(200, VALUE);

      var called = 0;
      zone.run(() {
        http.getString('a[not sent to backed]').then((v) {
          expect(v).toEqual(VALUE);
          called += 1;
        });
      });

      expect(called).toEqual(0);

      backend.flush();
      nextTurn(true);

      expect(called).toEqual(1);
    })));


    it('should support pending requests for different raw URLs', async(inject((Http http, Zone zone) {
      backend.when('GET', 'a').respond(200, VALUE);

      var called = 0;
      zone.run(() {
        http.getString('a[some string]', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 1;
        });
        http.getString('a[different string]', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 10;
        });
      });

      expect(called).toEqual(0);
      backend.flush();

      nextTurn(true);

      expect(called).toEqual(11);
    })));


    it('should support caching', async(inject((Http http, Zone zone) {
      var called = 0;
      zone.run(() {
        http.getString('fromCache', cache: cache).then((v) {
          expect(v).toEqual(CACHED_VALUE);
          called += 1;
        });
      });

      expect(called).toEqual(0);
      nextTurn();

      expect(called).toEqual(1);
    })));
  });

  describe('caching', () {
    it('should not cache if no cache is present', async(inject((Http http, Zone zone) {
      backend.when('GET', 'a').respond(200, VALUE, null);

      var called = 0;
      zone.run(() {
        http.getString('a').then((v) {
          expect(v).toEqual(VALUE);
          called += 1;
        });
        http.getString('a').then((v) {
          expect(v).toEqual(VALUE);
          called += 10;
        });
      });

      expect(called).toEqual(0);

      backend.flush();
      nextTurn(true);

      expect(called).toEqual(11);
    })));


    it('should return a pending request', async(inject((Http http, Zone zone) {
      backend.when('GET', 'a').respond(200, VALUE);

      var called = 0;
      zone.run(() {
        http.getString('a', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 1;
        });
        http.getString('a', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 10;
        });
      });

      expect(called).toEqual(0);
      backend.flush();
      nextTurn(true);

      expect(called).toEqual(11);
    })));


    it('should not return a pending request after the request is complete', async(inject((Http http, Zone zone) {
      backend.when('GET', 'a').respond(200, VALUE, null);

      var called = 0;
      zone.run(() {
        http.getString('a', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 1;
        });
      });

      expect(called).toEqual(0);
      backend.flush();
      nextTurn(true);

      zone.run(() {
        http.getString('a', cache: cache).then((v) {
          expect(v).toEqual(VALUE);
          called += 10;
        });
      });

      expect(called).toEqual(1);
      backend.flush();
      nextTurn(true);

      expect(called).toEqual(11);
    })));


    it('should return a cached value if present', async(inject((Http http, Zone zone) {
      var called = 0;
      // The URL string 'f' is primed in the FakeCache
      zone.run(() {
        http.getString('f', cache: cache).then((v) {
          expect(v).toEqual(CACHED_VALUE);
          called += 1;
        });
      });

      expect(called).toEqual(0);
      nextTurn();

      expect(called).toEqual(1);
    })));
  });


  describe('error handling', () {
    it('should reject 404 status codes', async(inject((Http http, Zone zone) {
      backend.when('GET', '404.html').respond(404, VALUE);

      var response = null;
      zone.run(() {
        http.getString('404.html').then(
          (v) => response = 'FAILED',
          onError:(v) => response = v);
      });

      expect(response).toEqual(null);
      backend.flush();
      nextTurn(true);
      expect(response.status).toEqual(404);
      expect(response.toString()).toEqual('HTTP 404: val');
    })));
  });
});

class FakeFile implements File {
  final DateTime lastModifiedDate = null;
  final String name = null;
  final String relativePath = null;
  final int size = 0;
  final String type = null;
  Blob slice([int start, int end, String contentType]) => null;
}
