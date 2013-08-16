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

  Http(UrlRewriter this.rewriter, HttpBackend this.backend);

  async.Future<String> getString(String url,
      {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
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
    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      return new async.Future.value(cachedValue);
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

