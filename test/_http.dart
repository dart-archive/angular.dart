library ng_mock_http;


import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';

class MockHttp extends Http {
  Map<String, String> gets = {};
  List futures = [];

  expectGET(url, content) {
    gets[url] = content;
  }

  flush() => gets.length == 0 ? Future.wait(futures) :
      throw "Expected GETs not called $gets";

  Future<String> getString(String url, {bool withCredentials, void onProgress(ProgressEvent e), Cache cache}) {
    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      return new Future.value(cachedValue);
    }

    if (!gets.containsKey(url)) throw "Unexpected URL $url";
    var expectedValue = gets.remove(url);
    if (cache != null) {
      cache.put(url, expectedValue);
    }
    var future = new Future.value(expectedValue);
    futures.add(future);
    return future;
  }
}

main() {}
