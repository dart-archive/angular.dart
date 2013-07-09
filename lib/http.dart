part of angular;

class Http {
  Map<String, async.Future<String>> _pendingRequests = <String, async.Future<String>>{};
  
  async.Future<String> getString(String url, {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    // We return a pending request only if caching is enabled.
    if (cache != null && _pendingRequests.containsKey(url)) {
      return _pendingRequests[url];
    }
    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      return new async.Future.value(cachedValue);
    }
    var result = dom.HttpRequest.getString(url, withCredentials: withCredentials, onProgress: onProgress).then((value) {
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
