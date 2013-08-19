library ng_mock_http;


import 'dart:async';
import '_specs.dart';

class MockHttp extends Http {
  Map<String, MockHttpData> gets = {};
  List futures = [];

  MockHttp(UrlRewriter rewriter, HttpBackend backend) : super(rewriter, backend);

  expectGET(String url, String content, {int times: 1}) {
    gets[url] = new MockHttpData(200, content, times);
  }

  flush() => Future.wait(futures);
  
  assertAllGetsCalled() {
    if (gets.length != 0) {
      throw "Expected GETs not called $gets";
    }
  }

  Future<String> getString(String url, {bool withCredentials, void onProgress(ProgressEvent e), Cache cache}) {
    if (!gets.containsKey(url)) throw "Unexpected URL $url $gets";
    var data = gets[url];
    data.times--;
    if (data.times <= 0) {
      gets.remove(url);
    }
    var expectedValue = data.value;
    if (cache != null) {
      cache.put(url, new HttpResponse(200, expectedValue));
    }
    var future = new Future.value(expectedValue);
    futures.add(future);
    return future;
  }
}

class MockHttpData {
  int code;
  String value;
  int times;
  MockHttpData(this.code, this.value, this.times);
  
  toString() => value;
}

class MockHttpRequestProgressEvent implements HttpRequestProgressEvent {
  MockHttpRequest currentTarget;

  MockHttpRequestProgressEvent(MockHttpRequest this.currentTarget);
}

class MockHttpRequest implements HttpRequest {
  int status;
  String response;

  MockHttpRequest(int this.status, String this.response);
}

class MockHttpBackend extends HttpBackend {
  Map<String, MockHttpData> gets = {};
  List flushFns = [];

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

main() {}
