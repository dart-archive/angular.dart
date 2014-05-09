library angular.mock.http_backend_spec;

import '../_specs.dart';

class _Chain {
  var _thenFn;
  _Chain({then}) {
    _thenFn = then;
  }

  then(x) => _thenFn(x);
}

void main() {
  describe('MockHttpBackend', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    MockHttpBackend hb;
    var callback, realBackendSpy;

    var noop = (_, __) {};
    var undefined = null;

    beforeEach((HttpBackend httpBackend) {
      callback = guinness.createSpy('callback');
      hb = httpBackend;
    });


    it('should respond with first matched definition', () {
      hb.when('GET', '/url1').respond(200, 'content', {});
      hb.when('GET', '/url1').respond(201, 'another', {});

      callback.andCallFake((status, response, _) {
        expect(status).toBe(200);
        expect(response).toBe('content');
      });

      hb('GET', '/url1', callback);
      expect(callback).not.toHaveBeenCalled();
      hb.flush();
      expect(callback).toHaveBeenCalledOnce();
    });

    it('should match when with credentials is set', () {
      hb.when('GET', '/url1').respond(200, 'content', {});
      hb.when('GET', '/url1', null, null, true).respond(201, 'another', {});

      callback.andCallFake((status, response, _) {
        expect(status).toBe(201);
        expect(response).toBe('another');
      });

      hb('GET', '/url1', callback, withCredentials: true);
      expect(callback).not.toHaveBeenCalled();
      hb.flush();
      expect(callback).toHaveBeenCalledOnce();
    });


    it('should respond with JSON', (Logger logger) {
      hb.when('GET', '/url1').respond(200, ['abc'], {});
      hb.when('GET', '/url2').respond(200, {'key': 'value'}, {});


      callback.andCallFake((status, response, _) {
        expect(status).toBe(200);
        logger(response);
      });

      hb('GET', '/url1', callback);
      hb('GET', '/url2', callback);
      hb.flush();
      expect(logger).toEqual(['["abc"]', '{"key":"value"}']);
    });


    it('should throw error when unexpected request', () {
      hb.when('GET', '/url1').respond(200, 'content');
      expect(() {
        hb('GET', '/xxx', noop);
      }).toThrow('Unexpected request: GET /xxx\nNo more requests expected');
    });


    it('should throw an error on an exception in then', async(() {
      hb.expectGET('/url').respond(200, 'content');

      expect(() {
        hb.request('/url', method: 'GET').then((x) {
          throw ["exceptiona"];
        });
        hb.flush();
        microLeap();
      }).toThrow('exceptiona');
    }));


    it('should match headers if specified', () {
      try {
        hb.when('GET', '/url', null, {'X': 'val1'}).respond(201, 'content1');
        hb.when('GET', '/url', null, {'X': 'val2'}).respond(202, 'content2');
        hb.when('GET', '/url').respond(203, 'content3');

        hb('GET', '/url', (status, response, _) {
          expect(status).toBe(203);
          expect(response).toBe('content3');
        });

        hb('GET', '/url', (status, response, _) {
          expect(status).toBe(201);
          expect(response).toBe('content1');
        }, headers: {'X': 'val1'});

        hb('GET', '/url', (status, response, _) {
          expect(status).toBe(202);
          expect(response).toBe('content2');
        }, headers: {'X': 'val2'});

        hb.flush();
      } catch (e,s) { print("$e $s"); }
    });


    it('should match data if specified', () {
      hb.when('GET', '/a/b', '{a: true}').respond(201, 'content1');
      hb.when('GET', '/a/b').respond(202, 'content2');

      hb('GET', '/a/b', (status, response) {
        expect(status).toBe(201);
        expect(response).toBe('content1');
      }, data: '{a: true}');

      hb('GET', '/a/b', (status, response) {
        expect(status).toBe(202);
        expect(response).toBe('content2');
      }, data: '{}');

      hb.flush();
    });


    it('should match only method', () {
      hb.when('GET').respond(202, 'c');
      callback.andCallFake((status, response, _) {
        expect(status).toBe(202);
        expect(response).toBe('c');
      });

      hb('GET', '/some', callback, headers: {});
      hb('GET', '/another', callback, headers: {'X-Fake': 'Header'});
      hb('GET', '/third', callback, data: 'some-data', headers: {});
      hb.flush();

      expect(callback).toHaveBeenCalled();
    });


    it('should preserve the order of requests', () {
      hb.when('GET', '/url1').respond(200, 'first');
      hb.when('GET', '/url2').respond(201, 'second');

      hb('GET', '/url2', callback);
      hb('GET', '/url1', callback);

      hb.flush();

      expect(callback.callCount).toBe(2);
      expect(callback.calls[0].positionalArguments).toEqual([201, 'second', '']);
      expect(callback.calls[1].positionalArguments).toEqual([200, 'first', '']);
    });


    describe('respond()', () {
      it('should take values', () {
        hb.expect('GET', '/url1').respond(200, 'first', {'header': 'val'});
        hb('GET', '/url1', callback);
        hb.flush();

        expect(callback).toHaveBeenCalledOnceWith(200, 'first', "header: val");
      });

      it('should take function', () {
        hb.expect('GET', '/some').respond((m, u, d, h) {
          return [301, m + u + ';' + d + ';a=' + h['a'], {'Connection': 'keep-alive'}];
        });

        hb('GET', '/some', callback, data: 'data', headers: {'a': 'b'});
        hb.flush();

        expect(callback).toHaveBeenCalledOnceWith(301, 'GET/some;data;a=b', 'Connection: keep-alive');
      });

      it('should default status code to 200', () {
        callback.andCallFake((status, response, _) {
          expect(status).toBe(200);
          expect(response).toBe('some-data');
        });

        hb.expect('GET', '/url1').respond('some-data');
        hb.expect('GET', '/url2').respond('some-data', {'X-Header': 'true'});
        hb('GET', '/url1', callback);
        hb('GET', '/url2', callback);
        hb.flush();
        expect(callback).toHaveBeenCalled();
        expect(callback.callCount).toBe(2);
      });


      it('should default response headers to ""', () {
        hb.expect('GET', '/url1').respond(200, 'first');
        hb.expect('GET', '/url2').respond('second');

        hb('GET', '/url1', callback);
        hb('GET', '/url2', callback);

        hb.flush();

        expect(callback.callCount).toBe(2);
        expect(callback.calls[0].positionalArguments).toEqual([200, 'first', '']);
        expect(callback.calls[1].positionalArguments).toEqual([200, 'second', '']);
      });
    });


    describe('expect()', () {
      it('should require specified order', () {
        hb.expect('GET', '/url1').respond(200, '');
        hb.expect('GET', '/url2').respond(200, '');

        expect(() {
          hb('GET', '/url2', noop, headers: {});
        }).toThrow('Unexpected request: GET /url2\nExpected GET /url1');
      });


      it('should have precedence over when()', () {
        callback.andCallFake((status, response, _) {
          expect(status).toBe(299);
          expect(response).toBe('expect');
        });

        hb.when('GET', '/url').respond(200, 'when');
        hb.expect('GET', '/url').respond(299, 'expect');

        hb('GET', '/url', callback);
        hb.flush();
        expect(callback).toHaveBeenCalledOnce();
      });


      it('should throw exception when only headers differs from expectation', () {
        hb.when('GET', '/match').respond(200, '', {});
        hb.expect('GET', '/match', null, {'Content-Type': 'application/json'}).respond(200, '', {});

        expect(() {
          hb('GET', '/match', noop, headers: {});
        }).toThrow('Expected GET /match with different headers\n' +
        'EXPECTED: {"Content-Type":"application/json"}\nGOT:      {}');
      });


      it('should throw exception when only data differs from expectation', () {
        hb.when('GET', '/match').respond(200, '', {});
        hb.expect('GET', '/match', 'some-data').respond(200, '', {});

        expect(() {
          hb('GET', '/match', noop, data: 'different');
        }).toThrow('Expected GET /match with different data\n' +
        'EXPECTED: some-data\nGOT:      different');
      });


      it("should use when's respond() when no expect() respond is defined", () {
        callback.andCallFake((status, response, _) {
          expect(status).toBe(201);
          expect(response).toBe('data');
        });

        hb.when('GET', '/some').respond(201, 'data');
        hb.expect('GET', '/some');
        hb('GET', '/some', callback);
        hb.flush();

        expect(callback).toHaveBeenCalled();
        expect(() { hb.verifyNoOutstandingExpectation(); }).not.toThrow();
      });
    });


    describe('flush()', () {
      it('flush() should flush requests fired during callbacks', () {
        hb.when('GET', '/some').respond(200, '');
        hb.when('GET', '/other').respond(200, '');
        hb('GET', '/some', (_, __) {
          hb('GET', '/other', callback);
        });

        hb.flush();
        expect(callback).toHaveBeenCalled();
      });


      it('should flush given number of pending requests', () {
        hb.when('GET').respond(200, '');
        hb('GET', '/some', callback);
        hb('GET', '/some', callback);
        hb('GET', '/some', callback);

        hb.flush(2);
        expect(callback).toHaveBeenCalled();
        expect(callback.callCount).toBe(2);
      });


      it('should throw exception when flushing more requests than pending', () {
        hb.when('GET').respond(200, '');
        hb('GET', '/url', callback);

        expect(() {hb.flush(2);}).toThrow('No more pending request to flush !');
        expect(callback).toHaveBeenCalledOnce();
      });


      it('should throw exception when no request to flush', () {
        expect(() {hb.flush();}).toThrow('No pending request to flush !');

        hb.when('GET').respond(200, '');
        hb('GET', '/some', callback);
        hb.flush();

        expect(() {hb.flush();}).toThrow('No pending request to flush !');
      });


      it('should throw exception if not all expectations satisfied', () {
        hb.expect('GET', '/url1').respond();
        hb.expect('GET', '/url2').respond();

        hb('GET', '/url1', noop);
        expect(() {hb.flush();}).toThrow('Unsatisfied requests: GET /url2');
      });
    });


    it('should abort requests when timeout promise resolves', () {
      hb.expect('GET', '/url1').respond(200);

      var canceler, then = guinness.createSpy('then').andCallFake((fn) {
        canceler = fn;
      });

      hb('GET', '/url1', callback, timeout: new _Chain(then: then));
      expect(canceler is Function).toBe(true);

      canceler();  // simulate promise resolution

      expect(callback).toHaveBeenCalledWith(-1, null, '');
      hb.verifyNoOutstandingExpectation();
      hb.verifyNoOutstandingRequest();
    });


    it('should throw an exception if no response defined', () {
      hb.when('GET', '/test');
      expect(() {
        hb('GET', '/test', callback);
      }).toThrow('No response defined !');
    });


    it('should throw an exception if no response for exception and no definition', () {
      hb.expect('GET', '/url');
      expect(() {
        hb('GET', '/url', callback);
      }).toThrow('No response defined !');
    });


    it('should respond undefined when JSONP method', () {
      hb.when('JSONP', '/url1').respond(200);
      hb.expect('JSONP', '/url2').respond(200);

      expect(hb('JSONP', '/url1', noop)).toBeNull();
      expect(hb('JSONP', '/url2', noop)).toBeNull();
    });


    describe('verifyExpectations', () {

      it('should throw exception if not all expectations were satisfied', () {
        hb.expect('POST', '/u1', 'ddd').respond(201, '', {});
        hb.expect('GET', '/u2').respond(200, '', {});
        hb.expect('POST', '/u3').respond(201, '', {});

        hb('POST', '/u1', noop, data: 'ddd', headers: {});

        expect(() {hb.verifyNoOutstandingExpectation();}).
        toThrow('Unsatisfied requests: GET /u2, POST /u3');
      });


      it('should do nothing when no expectation', () {
        hb.when('DELETE', '/some').respond(200, '');

        expect(() {hb.verifyNoOutstandingExpectation();}).not.toThrow();
      });


      it('should do nothing when all expectations satisfied', () {
        hb.expect('GET', '/u2').respond(200, '', {});
        hb.expect('POST', '/u3').respond(201, '', {});
        hb.when('DELETE', '/some').respond(200, '');

        hb('GET', '/u2', noop);
        hb('POST', '/u3', noop);

        expect(() {hb.verifyNoOutstandingExpectation();}).not.toThrow();
      });
    });

    describe('verifyRequests', () {

      it('should throw exception if not all requests were flushed', () {
        hb.when('GET').respond(200);
        hb('GET', '/some', noop, headers: {});

        expect(() {
          hb.verifyNoOutstandingRequest();
        }).toThrow('Unflushed requests: 1');
      });
    });


    describe('resetExpectations', () {

      it('should remove all expectations', () {
        hb.expect('GET', '/u2').respond(200, '', {});
        hb.expect('POST', '/u3').respond(201, '', {});
        hb.resetExpectations();

        expect(() {hb.verifyNoOutstandingExpectation();}).not.toThrow();
      });


      it('should remove all pending responses', () {
        var cancelledClb = guinness.createSpy('cancelled');

        hb.expect('GET', '/url').respond(200, '');
        hb('GET', '/url', cancelledClb);
        hb.resetExpectations();

        hb.expect('GET', '/url').respond(300, '');
        hb('GET', '/url', callback, headers: {});
        hb.flush();

        expect(callback).toHaveBeenCalledOnce();
        expect(cancelledClb).not.toHaveBeenCalled();
      });


      it('should not remove definitions', () {
        var cancelledClb = guinness.createSpy('cancelled');

        hb.when('GET', '/url').respond(200, 'success');
        hb('GET', '/url', cancelledClb);
        hb.resetExpectations();

        hb('GET', '/url', callback, headers: {});
        hb.flush();

        expect(callback).toHaveBeenCalledOnce();
        expect(cancelledClb).not.toHaveBeenCalled();
      });
    });


    describe('expect/when shortcuts', () {
      [[(x) => hb.expectGET(x), 'GET'],
      [(x) => hb.expectPOST(x), 'POST'],
      [(x) => hb.expectPUT(x), 'PUT'],
      [(x) => hb.expectPATCH(x), 'PATCH'],
      [(x) => hb.expectDELETE(x), 'DELETE'],
      [(x) => hb.expectJSONP(x), 'JSONP'],
      [(x) => hb.whenGET(x), 'GET'],
      [(x) => hb.whenPOST(x), 'POST'],
      [(x) => hb.whenPUT(x), 'PUT'],
      [(x) => hb.whenPATCH(x), 'PATCH'],
      [(x) => hb.whenDELETE(x), 'DELETE'],
      [(x) => hb.whenJSONP(x), 'JSONP']
      ].forEach((step) {
        var shortcut = step[0], method = step[1];
        it('should provide $shortcut  shortcut method', () {
          shortcut('/foo').respond('bar');
          hb(method, '/foo', callback);
          hb.flush();
          expect(callback).toHaveBeenCalledOnceWith(200, 'bar', '');
        });
      });
    });


    describe('MockHttpExpectation', () {

      it('should accept url as regexp', () {
        var exp = new MockHttpExpectation('GET', new RegExp('^\/x'));

        expect(exp.match('GET', '/x')).toBe(true);
        expect(exp.match('GET', '/xxx/x')).toBe(true);
        expect(exp.match('GET', 'x')).toBe(false);
        expect(exp.match('GET', 'a/x')).toBe(false);
      });


      it('should accept data as regexp', () {
        var exp = new MockHttpExpectation('POST', '/url', new RegExp('\{.*?\}'));

        expect(exp.match('POST', '/url', '{"a": "aa"}')).toBe(true);
        expect(exp.match('POST', '/url', '{"one": "two"}')).toBe(true);
        expect(exp.match('POST', '/url', '{"one"')).toBe(false);
      });


      it('should accept headers as function', () {
        var exp = new MockHttpExpectation('GET', '/url', undefined, (h) {
          return h['Content-Type'] == 'application/json';
        });

        expect(exp.matchHeaders({})).toBe(false);
        expect(exp.matchHeaders({'Content-Type': 'application/json', 'X-Another': 'true'})).toBe(true);
      });
    });
  });
}
