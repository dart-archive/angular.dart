library angular.playback.playback_http;

import "dart:async";
import "dart:html";
import "dart:json" as json;

import "package:angular/dom/http.dart";
import "package:angular/mock/mock.dart" as mock;

import "playback_data.dart" as playback_data;

class PlaybackHttpBackendConfig {
  requestKey(String url,
                 {String method, bool withCredentials, String responseType,
                 String mimeType, Map<String, String> requestHeaders, sendData,
                 void onProgress(ProgressEvent e)}) {
    print('send data: ${sendData is String}');
    return json.stringify({
        "url": url,
        "method": method,
        "requestHeaders": requestHeaders,
        "data": sendData
    });
  }
}

// HELP! The DI system is getting in the way.  We want
// the HttpBackend, but it will be implemented by ourselves.
class HttpBackendWrapper {
  HttpBackend backend;
  HttpBackendWrapper(HttpBackend this.backend);
}

class RecordingHttpBackend implements HttpBackend {

  HttpBackend _prodBackend;
  PlaybackHttpBackendConfig _config;

  RecordingHttpBackend(HttpBackendWrapper wrapper,
                       PlaybackHttpBackendConfig this._config) {
    this._prodBackend = wrapper.backend;

  }

  Future request(String url,
                 {String method, bool withCredentials, String responseType,
                 String mimeType, Map<String, String> requestHeaders, sendData,
                 void onProgress(ProgressEvent e)}) {
    return _prodBackend.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress).then((HttpRequest r) {

     var key = _config.requestKey(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress);

      _prodBackend.request('/record',  //TODO make this URL configurable.
        method: 'POST', sendData: json.stringify({
          "key": key, "data": json.stringify({
              "status": r.status,
              "headers": r.getAllResponseHeaders(),
              "data": r.responseText})
      }));
      return r;
    });
  }
}

class PlaybackHttpBackend implements HttpBackend {

  PlaybackHttpBackendConfig _config;

  PlaybackHttpBackend(PlaybackHttpBackendConfig this._config);

  Map data = playback_data.playbackData;

  Future request(String url,
                 {String method, bool withCredentials, String responseType,
                 String mimeType, Map<String, String> requestHeaders, sendData,
                 void onProgress(ProgressEvent e)}) {
    var key = _config.requestKey(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress);

    if (!data.containsKey(key)) {
      throw ["Request is not recorded $key"];
    }
    var playback = data[key];
    return new Future.value(
        new mock.MockHttpRequest(
            playback['status'],
            playback['data'],
            playback['headers']));
  }
}
