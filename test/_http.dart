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

main() {}
