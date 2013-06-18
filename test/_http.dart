library ng_mock_http;


import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';

class MockHttp extends Http {
  Map<String, String> gets = {};
  expectGET(url, content) {
    gets[url] = content;
  }

  Future<String> getString(String url, {bool withCredentials, void onProgress(ProgressEvent e)}) {
    if (!gets.containsKey(url)) throw "Unexpected URL $url";
    return new Future.value(gets.remove(url));
  }
}

main() {}
