part of angular;

class UrlRewriter {
  String call(url) => url;
}

class HttpBackend {
  async.Future request(String url,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(dom.ProgressEvent e)}) {
    if (method == null) {
      method = "GET";
    }
    var xhr = new HttpRequest()
      ..open(method, url, async: true);
    if (withCredentials != null) {
      xhr.withCredentials = withCredentials;
    }
    if (responseType != null) {
      xhr.responseType = responseType;
    }
    if (mimeType != null) {
      xhr.overrideMimeType(mimeType);
    }
    if (requestHeaders != null) {
      requestHeaders.forEach(xhr.setRequestHeader);
    }
    if (onProgress != null) {
      xhr.onProgress.listen(onProgress);
    }
    xhr.send(sendData);
    
    // Complete the future with the HttpRequest either way, regardless of whether
    // there's an error or not.
    return xhr.onLoad.first
        .then((_) => xhr)
        .catchError((_) => xhr);
  }
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
      if (value is HttpRequest) {
        response.headers = _parseHttpHeaders(value.getAllResponseHeaders());
      }

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

_parseHttpHeaders(String headers) {
  var headerMap = new Map<String, String>();
  headers.split("\r\n").forEach((header) {
    var colon = header.indexOf(':');
    if (colon < 0) {
      return;
    }
    headerMap[header.substring(0, colon).trim()] = header.substring(colon + 1).trim();
  });
  return headerMap;
}
