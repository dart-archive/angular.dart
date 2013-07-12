part of angular;

// NOTE(deboer): This should be a generic utility class, but lets make sure
// it works in this case first!
class HttpFutures {
  value(x) => new async.Future.value(x);
}

class UrlRewriter {
  String call(url) => url;
}

class HttpBackend {
  getString(String url, {bool withCredentials, void onProgress(dom.ProgressEvent e)}) {
    return dom.HttpRequest.getString(url, withCredentials: withCredentials, onProgress: onProgress);
  }
}

class Http {
  Map<String, async.Future<String>> _pendingRequests = <String, async.Future<String>>{};
  UrlRewriter rewriter;
  HttpBackend backend;
  HttpFutures futures;

  Http(UrlRewriter this.rewriter, HttpBackend this.backend, HttpFutures this.futures);

  async.Future<String> getString(String rawUrl, {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    String url = rewriter(rawUrl);

    // We return a pending request only if caching is enabled.
    if (cache != null && _pendingRequests.containsKey(url)) {
      return _pendingRequests[url];
    }
    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      return futures.value(cachedValue);
    }
    var result = backend.getString(url, withCredentials: withCredentials, onProgress: onProgress).then((value) {
      if (cache != null) {
        cache.put(url, value);
      }
      _pendingRequests.remove(url);
      return value;
    }, onError: (error) {
      _pendingRequests.remove(url);
      throw error;
    });
    _pendingRequests[url] = result;
    return result;
  }
}
