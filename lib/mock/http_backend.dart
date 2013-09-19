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
  final bool supportsCrossOrigin = false;
  final bool supportsLoadEndEvent = false;
  final bool supportsOverrideMimeType = false;
  final bool supportsProgressEvent = false;
  final Events on = null;

  final Stream<ProgressEvent> onAbort = null;
  final Stream<ProgressEvent> onError = null;
  final Stream<ProgressEvent> onLoad = null;
  final Stream<ProgressEvent> onLoadEnd = null;
  final Stream<ProgressEvent> onLoadStart = null;
  final Stream<ProgressEvent> onProgress = null;
  final Stream<ProgressEvent> onReadyStateChange = null;

  final Stream<ProgressEvent> onTimeout = null;
  final int readyState = 0;

  final responseText = null;
  final responseXml = null;
  final String statusText = null;
  final HttpRequestUpload upload = null;

  String responseType = null;
  int timeout = 0;
  bool withCredentials;

  final int status;
  final response;

  MockHttpRequest(int this.status, String this.response);

  void abort() {}
  bool dispatchEvent(Event event) => false;
  String getAllResponseHeaders() => null;
  String getResponseHeader(String header) => null;

  void open(String method, String url, {bool async, String user, String password}) {}
  void overrideMimeType(String override) {}
  void send([data]) {}
  void setRequestHeader(String header, String value) {}
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) {}
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) {}
}

class MockHttpRequestProgressEvent implements HttpRequestProgressEvent {
  final bool bubbles = false;
  final bool cancelable = false;
  final DataTransfer clipboardData = null;
  final EventTarget currentTarget;
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

  MockHttpRequestProgressEvent(MockHttpRequest this.currentTarget);

  void preventDefault() {}
  void stopImmediatePropagation() {}
  void stopPropagation() {}
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
