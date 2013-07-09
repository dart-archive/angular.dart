library ng_mock_http;


import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';

class MockHttp extends Http {
  Map<String, MockHttpData> gets = {};
  List futures = [];

  expectGET(String url, String content, {int times: 1}) {
    gets[url] = new MockHttpData(content, times);
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
      cache.put(url, expectedValue);
    }
    var future = new Future.value(expectedValue);
    futures.add(future);
    return future;
  }
}

class MockHttpData {
  String value;
  int times;
  MockHttpData(this.value, this.times);
  
  toString() => value;
}

main() {}
