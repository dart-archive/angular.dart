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

  toString() => 'HTTP $status: $responseText';
}

/**
 * Wrapper around the browser XHR. Use Http service to fetch data
 * from the server.
 */
class Http {
  Map<String, async.Future<String>> _pendingRequests = <String, async.Future<String>>{};
  UrlRewriter _rewriter;
  HttpBackend _backend;

  Http(UrlRewriter this._rewriter, HttpBackend this._backend);

  async.Future<String> getString(String url,
      {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    return request(url,
        withCredentials: withCredentials,
        onProgress: onProgress,
        cache: cache).then((HttpResponse xhr) => xhr.responseText);
  }

  async.Future<HttpResponse> request(String rawUrl,
      { String method: 'GET',
        bool withCredentials: false,
        String responseType,
        String mimeType,
        Map<String, String> requestHeaders,
        sendData,
        void onProgress(dom.ProgressEvent e),
        Cache<HttpResponse> cache }) {
    String url = _rewriter(rawUrl);

    // We return a pending request only if caching is enabled.
    if (cache != null && _pendingRequests.containsKey(url)) {
      return _pendingRequests[url];
    }
    var cachedValue = (cache != null && method == 'GET') ? cache.get(url) : null;
    if (cachedValue != null) {
      return new async.Future.value(cachedValue);
    }
    var result = _backend.request(url,
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
    }, onError: (HttpRequestProgressEvent event) {
      _pendingRequests.remove(url);
      HttpRequest request = event.currentTarget;
      return new async.Future.error(
          new HttpResponse(request.status, request.response));
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
