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

  Future<String> getString(String url, {bool withCredentials, void onProgress(ProgressEvent e)}) {
    if (!gets.containsKey(url)) throw "Unexpected URL $url";
    var f = new Future.value(gets.remove(url));
    futures.add(f);
    return f;
  }
}

main() {}
