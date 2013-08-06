part of angular;

class UrlRewriter {
  String call(url) => url;
}

class HttpBackend {
  async.Future request(String url,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(dom.ProgressEvent e)}) =>
    dom.HttpRequest.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress);
}

class HttpResponse {
  int status;
  String responseText;
  Map<String, String> headers;
  HttpResponse([this.status, this.responseText, this.headers]);
}

class Http {
  Map<String, async.Future<String>> _pendingRequests = <String, async.Future<String>>{};
  UrlRewriter rewriter;
  HttpBackend backend;
  Scope scope;

  Http(Scope this.scope, UrlRewriter this.rewriter, HttpBackend this.backend);

  async.Future<String> getString(String url,
      {bool withCredentials, void onProgress(ProgressEvent e), Cache cache}) {
    return request(url,
        withCredentials: withCredentials,
        onProgress: onProgress,
        cache: cache).then((HttpResponse xhr) => xhr.responseText);
  }

  // TODO(deboer): The cache is keyed on the url only.  It should be keyed on
  //     (url, method, mimeType, requestHeaders, ...)
  //     Better yet, we should be using a HTTP standard cache.
  async.Future<HttpResponse> request(String rawUrl,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(dom.ProgressEvent e),
      Cache<HttpResponse> cache}) {
    String url = rewriter(rawUrl);

    // We return a pending request only if caching is enabled.
    if (cache != null && _pendingRequests.containsKey(url)) {
      return _pendingRequests[url];
    }

    var requestFuture;
    async.runZonedExperimental(() {
      requestFuture = _requestUnguarded(url,
          method: method,
          withCredentials: withCredentials,
          responseType: responseType,
          mimeType: mimeType,
          requestHeaders: requestHeaders,
          sendData: sendData,
          onProgress: onProgress,
          cache: cache).then((x) {
            // Disallow $digest inside of http handlers.
            scope.$beginPhase('http');
            return x;
          });
    }, onDone: () {
      scope.$clearPhase();
      try {
        scope.$apply();
      } catch (e, s) {
        dump('Exception from HTTP, Dart may throw a cryptic error next: $e\n\n$s');
        rethrow;
      }
    });
    return requestFuture;
  }

  async.Future<HttpResponse> _requestUnguarded(String url,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(dom.ProgressEvent e),
      Cache<HttpResponse> cache}) {

    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      // The then here forced runZoned's onDone handler to wait for the
      // future to complete.
      return new async.Future.value(cachedValue).then((x) => x);
    }
    var result = backend.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress).then((value) {
      // NOTE(deboer): Missing headers.  Ask the Dart team for a sane API.
      var response = new HttpResponse(value.status, value.responseText);

      if (cache != null) {
        cache.put(url, response);
      }
      _pendingRequests.remove(url);
      return response;
    }, onError: (error) {
      _pendingRequests.remove(url);
      throw error;
    });
    _pendingRequests[url] = result;
    return result;
  }
}

