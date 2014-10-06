library angular.mock.http_backend;

import 'dart:async' as dart_async;
import 'dart:convert' show JSON;
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/utils.dart' as utils;


class _MockXhr {
  var method, url, async, reqHeaders, respHeaders;

  void open(method, url, async) {
    this.method = method;
    this.url = url;
    this.async = async;
    reqHeaders = {};
    respHeaders = {};
  }

  var data;

  void send(data) {
    data = data;
  }

  void setRequestHeader(key, value) {
    reqHeaders[key] = value;
  }

  String getResponseHeader(name) {
    // the lookup must be case insensitive, that's why we try two quick
    // lookups and full scan at last
    if (respHeaders.containsKey(name)) return respHeaders[name];

    name = name.toLowerCase();
    if (respHeaders.containsKey(name)) return respHeaders[name];

    String header = null;
    respHeaders.forEach((headerName, headerVal) {
      if (header != null) return;
      if (headerName.toLowerCase()) header = headerVal;
    });
    return header;
  }

  getAllResponseHeaders() {
    if (respHeaders == null) return '';

    var lines = [];

    respHeaders.forEach((key, value) {
      lines.add("$key: $value");
    });
    return lines.join('\n');
  }

  // noop
  abort() {}
}

/**
 * An internal class used by [MockHttpBackend].
 */
class MockHttpExpectation {
  final String method;
  final /*String or RegExp*/ url;
  final data;
  final headers;
  final bool withCredentials;

  var response;

  MockHttpExpectation(this.method, this.url, [this.data, this.headers, withCredentials]) :
      this.withCredentials = withCredentials == true;

  bool match(req) =>
      matchMethodAndUrl(req) && matchData(req) && matchHeaders(req) && matchWithCredentials(req);

  bool matchMethodAndUrl(req) =>
      method == req.method && matchUrl(req);

  bool matchUrl(req) {
    if (url == null) return true;
    return _matchUrl(url, req.url);
  }

  bool matchHeaders(req) {
    if (headers == null) return true;
    if (headers is Function) return headers(req.headers);
    return "$headers" == "${req.headers}";
  }

  bool matchData(req) {
    if (data == null) return true;
    if (req.data == null) return false;
    if (data is File) return data == req.data;
    assert(req.data is String);
    if (data is RegExp) return data.hasMatch(req.data);
    return JSON.encode(data) == JSON.encode(req.data);
  }

  bool matchWithCredentials(req) {
    if (withCredentials == null) return true;
    if (req.withCredentials == null) return true;
    return withCredentials == req.withCredentials;
  }

  String toString() => "$method $url";
}


class _Chain {
  final Function _respondFn;
  _Chain({respond}): _respondFn = respond;
  respond([x,y,z]) => _respondFn(x,y,z);
}


/**
 * An internal class used by [MockHttpBackend].
 */
class RecordedRequest {
  final String method;
  final url, callback, data, headers, timeout;
  final bool withCredentials;

  RecordedRequest({this.method, this.url, this.callback, this.data,
      this.headers, this.timeout, this.withCredentials});

  bool matchMethodAndUrl(method, url) =>
      this.method == method && _matchUrl(url, this.url);
}

bool _matchUrl(expected, actual) =>
    (expected is RegExp) ? expected.hasMatch(actual) : expected == actual;

/**
 * A mock implementation of [HttpBackend], used in tests.
 */
@Injectable()
class MockHttpBackend implements HttpBackend {
  var definitions = [],
      expectations = [],
      requests = [];

  /**
   * This function is called from [Http] and designed to mimic the Dart APIs.
   */
  dart_async.Future request(String url,
                 {String method, bool withCredentials: false, String responseType,
                 String mimeType, Map<String, String> requestHeaders, sendData,
                 void onProgress(ProgressEvent e)}) {
    dart_async.Completer c = new dart_async.Completer();
    var callback = (status, data, headers) {
      if (status >= 200 && status < 300) {
        c.complete(new MockHttpRequest(status, data, headers));
      } else {
        c.completeError(new MockProgressEvent(
            new MockHttpRequest(status, data, headers)));
      }
    };
    call(method == null ? 'GET' : method, url, callback,
         data: sendData, headers: requestHeaders, withCredentials: withCredentials);
    return c.future;
  }

  _createResponse(statusOrDataOrFunction, dataOrHeaders, headersOrNone) {
    if (statusOrDataOrFunction is Function) return statusOrDataOrFunction;
    var status, data, headers;
    if (statusOrDataOrFunction is num) {
      status = statusOrDataOrFunction;
      data = dataOrHeaders;
      headers = headersOrNone;
    } else {
      status = 200;
      data = statusOrDataOrFunction;
      headers = dataOrHeaders;
    }
    if (data is Map || data is List) data = JSON.encode(data);

    return ([a,b,c,d,e]) => [status, data, headers];
  }


  void call(method, url, callback, {data, headers, timeout, withCredentials: false}) {
    requests.add(new RecordedRequest(
      method: method,
      url: url,
      callback: callback,
      data: data,
      headers: headers,
      timeout: timeout,
      withCredentials: withCredentials
    ));
  }

  /**
   * Creates a new backend definition.
   *
   * @param {string} method HTTP method.
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {(Object|function(Object))=} headers HTTP headers or function that
   * receives http header object and returns true if the headers match the
   * current definition.
   * @returns {requestHandler} Returns an object with `respond` method that
   * control how a matched request is handled.
   *
   *  - respond – `{function([status,] data[, headers])|function(function(method, url, data, headers)}`
   *    – The respond method takes a set of static data to be returned or a function that can return
   *    an array containing response status (number), response data (string) and response headers
   *    (Object).
   */
  _Chain when(method, [url, data, headers, withCredentials = false]) {
    var definition = new MockHttpExpectation(method, url, data, headers, withCredentials),
        chain = new _Chain(respond: (status, data, headers) {
          definition.response = _createResponse(status, data, headers);
        });

    definitions.add(definition);
    return chain;
  }

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenGET
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for GET requests. For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(Object|function(Object))=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */
  _Chain whenGET(url, [headers]) => when('GET', url, null, headers);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenDELETE
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for DELETE requests. For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(Object|function(Object))=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */
  _Chain whenDELETE(url, [headers]) => when('DELETE', url, null, headers);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenJSONP
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for JSONP requests. For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */
  _Chain whenJSONP(url, [headers]) => when('JSONP', url, null, headers);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenPUT
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for PUT requests.  For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {(Object|function(Object))=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */
  _Chain whenPUT(url, [data, headers]) => when('PUT', url, data, headers);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenPOST
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for POST requests. For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {(Object|function(Object))=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */
  _Chain whenPOST(url, [data, headers]) => when('POST', url, data, headers);

  _Chain whenPATCH(url, [data, headers]) => when('PATCH', url, data, headers);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#whenHEAD
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new backend definition for HEAD requests. For more info see `when()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(Object|function(Object))=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled.
   */

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expect
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation.
   *
   * @param {string} method HTTP method.
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {(Object|function(Object))=} headers HTTP headers or function that receives http header
   *   object and returns true if the headers match the current expectation.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *  request is handled.
   *
   *  - respond – `{function([status,] data[, headers])|function(function(method, url, data, headers)}`
   *    – The respond method takes a set of static data to be returned or a function that can return
   *    an array containing response status (number), response data (string) and response headers
   *    (Object).
   */
  _Chain expect(method, [url, data, headers, withCredentials = false]) {
    var expectation = new MockHttpExpectation(method, url, data, headers, withCredentials);
    expectations.add(expectation);
    return new _Chain(respond: (status, data, headers) {
      expectation.response = _createResponse(status, data, headers);
    });
  }


  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectGET
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for GET requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   * request is handled. See #expect for more info.
   */
  _Chain expectGET(url, [headers, withCredentials = false]) => expect('GET', url, null, headers,
      withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectDELETE
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for DELETE requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain expectDELETE(url, [headers, withCredentials = false]) => expect('DELETE', url, null,
      headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectJSONP
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for JSONP requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain expectJSONP(url, [headers, withCredentials = false]) => expect('JSONP', url, null, headers,
      withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectPUT
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for PUT requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain expectPUT(url, [data, headers, withCredentials = false]) => expect('PUT', url, data,
      headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectPOST
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for POST requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain expectPOST(url, [data, headers, withCredentials = false]) => expect('POST', url, data,
      headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#expectPATCH
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for PATCH requests. For more info see `expect()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain expectPATCH(url, [data, headers, withCredentials = false]) => expect('PATCH', url, data,
      headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flush
   * @methodOf ngMock.httpBackend
   * @description
   * Flushes all pending requests using the trained responses.
   *
   * @param {number=} count Number of responses to flush (in the order they arrived). If undefined,
   *   all pending requests will be flushed. If there are no pending requests when the flush method
   *   is called an exception is thrown (as this typically a sign of programming error).
   */
  void flush([count]) {
    if (requests.isEmpty) throw ['No pending request to flush !'];

    if (count != null) {
      while (count-- > 0) {
        if (requests.isEmpty) throw ['No more pending request to flush !'];
        _processRequest(requests.removeAt(0));
      }
    } else {
      while (!requests.isEmpty) {
        _processRequest(requests.removeAt(0));
      }
    }
    verifyNoOutstandingExpectation();
  }

  /**
   * Creates a new expectation and flushes all pending requests until the one matching the expectation.
   *
   * @param {string} method HTTP method.
   * @param {string|RegExp} url HTTP url.
   * @param {(string|RegExp)=} data HTTP request body.
   * @param {(Object|function(Object))=} headers HTTP headers or function that
   * receives http header object and returns true if the headers match the
   * current definition.
   * @returns {requestHandler} Returns an object with `respond` method that
   * control how a matched request is handled.
   *
   *  - respond – `{function([status,] data[, headers])|function(function(method, url, data, headers)}`
   *    – The respond method takes a set of static data to be returned or a function that can return
   *    an array containing response status (number), response data (string) and response headers
   *    (Object).
   */
  _Chain flushExpected(String method, url, [data, headers, withCredentials = false]) {
    var expectation = new MockHttpExpectation(method, url, data, headers, withCredentials);
    expectations.add(expectation);

    flushUntilMethodAndUrlMatch () {
      while (requests.isNotEmpty) {
        final r = requests.removeAt(0);
        _processRequest(r);
        if (r.matchMethodAndUrl(method, url)) return;
      }
      throw ['No more pending requests matching $method $url'];
    }

    return new _Chain(respond: (status, data, headers) {
      expectation.response = _createResponse(status, data, headers);
      flushUntilMethodAndUrlMatch();
    });
  }

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushGET
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for GET requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushGET(url, [headers, withCredentials = false]) =>
      flushExpected("GET", url, null, headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushPOST
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for POST requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushPOST(url, [data, headers, withCredentials = false]) =>
      flushExpected("POST", url, data, headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushPUT
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for PUT requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushPUT(url, [data, headers, withCredentials = false]) =>
      flushExpected("PUT", url, data, headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushPATCH
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for PATCH requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushPATCH(url, [data, headers, withCredentials = false]) =>
      flushExpected("PATCH", url, data, headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushDELETE
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for DELETE requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushDELETE(url, [headers, withCredentials = false]) =>
      flushExpected("DELETE", url, null, headers, withCredentials);

  /**
   * @ngdoc method
   * @name ngMock.httpBackend#flushJSONP
   * @methodOf ngMock.httpBackend
   * @description
   * Creates a new request expectation for JSONP requests. For more info see `flushExpected()`.
   *
   * @param {string|RegExp} url HTTP url.
   * @param {Object=} headers HTTP headers.
   * @returns {requestHandler} Returns an object with `respond` method that control how a matched
   *   request is handled.
   */
  _Chain flushJSONP(url, [headers, withCredentials = false]) =>
      flushExpected("JSONP", url, null, headers, withCredentials);


  /**
   * @ngdoc method
   * @name ngMock.httpBackend#verifyNoOutstandingExpectation
   * @methodOf ngMock.httpBackend
   * @description
   * Verifies that all of the requests defined via the `expect` api were made. If any of the
   * requests were not made, verifyNoOutstandingExpectation throws an exception.
   *
   * Typically, you would call this method following each test case that asserts requests using an
   * "afterEach" clause.
   *
   * <pre>
   *   afterEach(httpBackend.verifyNoOutstandingExpectation);
   * </pre>
   */
  void verifyNoOutstandingExpectation() {
    if (!expectations.isEmpty) {
      throw ['Unsatisfied requests: ${expectations.join(', ')}'];
    }
  }


  /**
   * @ngdoc method
   * @name ngMock.httpBackend#verifyNoOutstandingRequest
   * @methodOf ngMock.httpBackend
   * @description
   * Verifies that there are no outstanding requests that need to be flushed.
   *
   * Typically, you would call this method following each test case that asserts requests using an
   * "afterEach" clause.
   *
   * <pre>
   *   afterEach(httpBackend.verifyNoOutstandingRequest);
   * </pre>
   */
  void verifyNoOutstandingRequest() {
    if (!requests.isEmpty) throw ['Unflushed requests: ${requests.length}'];
  }


  /**
   * @ngdoc method
   * @name ngMock.httpBackend#resetExpectations
   * @methodOf ngMock.httpBackend
   * @description
   * Resets all request expectations, but preserves all backend definitions. Typically, you would
   * call resetExpectations during a multiple-phase test when you want to reuse the same instance of
   * httpBackend mock.
   */
  void resetExpectations() {
    expectations.length = 0;
    requests.length = 0;
  }


  void _processRequest(RecordedRequest req) {
    prettyPrint(data) {
      return (data is String || data is Function || data is RegExp)
          ? data
          : JSON.encode(data);
    }

    handleResponse(expectation) {
      final xhr = new _MockXhr();
      final response = expectation.response(req.method, req.url, req.data, req.headers);

      final status = response[0];
      final data = response[1];
      xhr.respHeaders = response[2];

      utils.relaxFnApply(req.callback, [status, data, xhr.getAllResponseHeaders()]);
    }

    handleResponseAndTimeout(expectation) {
      if (req.timeout != null) {
        req.timeout.then(() => req.callback(-1, null, ''));
      } else {
        handleResponse(expectation);
      }
    }

    checkExpectation(expectation) {
      if (!expectation.matchData(req)) {
        throw ['Expected $expectation with different data\n'
            'EXPECTED: ${prettyPrint(expectation.data)}\nGOT:      ${req.data}'];
      }

      if (!expectation.matchHeaders(req)) {
        throw ['Expected $expectation with different headers\n'
            'EXPECTED: ${prettyPrint(expectation.headers)}\n'
            'GOT:      ${prettyPrint(req.headers)}'];
      }

      if (!expectation.matchWithCredentials(req)) {
        throw ['Expected $expectation with different withCredentials\n'
            'EXPECTED: ${prettyPrint(expectation.withCredentials)}\n'
            'GOT:      ${prettyPrint(req.withCredentials)}'];
      }
    }

    hasResponse(d) => d != null && d.response != null;

    executeFirstExpectation(e, d) {
      checkExpectation(e);
      expectations.remove(e);

      if (hasResponse(e)) {
        handleResponseAndTimeout(e);
      } else if (hasResponse(d)) {
        handleResponseAndTimeout(d);
      } else {
        throw ['No response defined !'];
      }
    }

    executeMatchingDefinition(e, d) {
      if (hasResponse(d)) {
        handleResponseAndTimeout(d);
      } else if (d != null) {
        throw ['No response defined !'];;
      } else if (e != null) {
        throw ['Unexpected request: ${req.method} ${req.url}\nExpected $e'];
      } else  {
        throw ['Unexpected request: ${req.method} ${req.url}\nNo more requests expected'];
      }
    }

    firstExpectation() =>
        expectations.isEmpty ? null : expectations.first;

    matchingDefinition() =>
        definitions.firstWhere((d) => d.match(req), orElse: () => null);

    final e = firstExpectation();
    final d = matchingDefinition();

    if (e != null && e.matchMethodAndUrl(req)) {
      executeFirstExpectation(e, d);
    } else {
      executeMatchingDefinition(e, d);
    }
  }
}

/**
 * Mock implementation of the [HttpRequest] object returned from the HttpBackend.
 */
class MockHttpRequest implements HttpRequest {
  final bool supportsCrossOrigin = false;
  final bool supportsLoadEndEvent = false;
  final bool supportsOverrideMimeType = false;
  final bool supportsProgressEvent = false;
  final Events on = null;

  final dart_async.Stream<ProgressEvent> onAbort = null;
  final dart_async.Stream<ProgressEvent> onError = null;
  final dart_async.Stream<ProgressEvent> onLoad = null;
  final dart_async.Stream<ProgressEvent> onLoadEnd = null;
  final dart_async.Stream<ProgressEvent> onLoadStart = null;
  final dart_async.Stream<ProgressEvent> onProgress = null;
  final dart_async.Stream<ProgressEvent> onReadyStateChange = null;

  final dart_async.Stream<ProgressEvent> onTimeout = null;
  final int readyState = 0;

  get responseText => response == null ? null : "$response";
  Map<String, String> get responseHeaders => null;
  final responseXml = null;
  final String statusText = null;
  final HttpRequestUpload upload = null;

  String responseType = null;
  int timeout = 0;
  bool withCredentials;

  final int status;
  final response;
  final String headers;

  MockHttpRequest(this.status, this.response, [this.headers]);

  void abort() {}
  bool dispatchEvent(Event event) => false;
  String getAllResponseHeaders() => headers;
  String getResponseHeader(String header) => null;

  void open(String method, String url, {bool async, String user, String password}) {}
  void overrideMimeType(String override) {}
  void send([data]) {}
  void setRequestHeader(String header, String value) {}
  void addEventListener(String type, EventListener listener, [bool useCapture]) {}
  void removeEventListener(String type, EventListener listener, [bool useCapture]) {}
}

class MockProgressEvent implements ProgressEvent {
  final bool bubbles = false;
  final bool cancelable = false;
  final DataTransfer clipboardData = null;
  final EventTarget currentTarget;
  final Element matchingTarget = null;
  final bool defaultPrevented = false;
  final int eventPhase = 0;
  final bool lengthComputable = false;
  final int loaded = 0;
  final List<Node> path = null;
  final int position = 0;
  final Type runtimeType = null;
  final EventTarget target = null;
  final int timeStamp = 0;
  final int total = 0;
  final int totalSize = 0;
  final String type = null;

  bool cancelBubble = false;

  MockProgressEvent(MockHttpRequest this.currentTarget);

  void preventDefault() {}
  void stopImmediatePropagation() {}
  void stopPropagation() {}
}
