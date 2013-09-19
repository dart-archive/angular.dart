part of angular.mock;



class MockHttpData {
  int code;
  String value;
  int times;
  MockHttpData(this.code, this.value, this.times);

  toString() => value;
}

/**
 * Mock implementation of the [HttpRequest] object returned from the HttpBackend.
 */
class MockHttpRequest implements HttpRequest {
  int status;
  String response;

  MockHttpRequest(int this.status, String this.response);
}

class MockHttpRequestProgressEvent implements HttpRequestProgressEvent {
  MockHttpRequest currentTarget;

  MockHttpRequestProgressEvent(MockHttpRequest this.currentTarget);
}


class _WhenPartial {
  String _url;
  MockHttpBackend _backend;
  _WhenPartial(method, this._url, this._backend) {
    assert(method == 'GET');
  }

  respond(int code, String content, [Map headers, int times=1]) {
    _backend.gets[_url] = new MockHttpData(code, content, times);
  }
}

/**
 * Mock implementation of [HttpBackend].
 */
class MockHttpBackend extends HttpBackend {
  Map<String, MockHttpData> gets = {};
  List flushFns = [];

  when(String method, String url) {
    return new _WhenPartial(method, url, this);
  }

  expectGET(String url, String content, {int times: 1, int code: 200}) {
    gets[url] = new MockHttpData(code, content, times);
  }

  flush() {
    flushFns.forEach((fn) => fn());
    flushFns = [];
  }

  assertAllGetsCalled() {
    if (gets.length != 0) {
      throw "Expected GETs not called $gets";
    }
  }

  Future<HttpRequest> request(String url,
                              {String method, bool withCredentials, String responseType,
                              String mimeType, Map<String, String> requestHeaders, sendData,
                              void onProgress(ProgressEvent e)}) {
    if (!gets.containsKey(url)) throw "Unexpected URL $url $gets";
    var data = gets[url];
    data.times--;
    if (data.times <= 0) {
      gets.remove(url);
    }
    var completer = new Completer.sync();
    if (data.code >= 200 && data.code < 300) {
      flushFns.add(() => completer.complete(new HttpResponse(data.code, data.value)));
    } else {
      flushFns.add(() => completer.completeError(
          new MockHttpRequestProgressEvent(new MockHttpRequest(data.code, data.value))
      ));
    }
    return completer.future;
  }
}
