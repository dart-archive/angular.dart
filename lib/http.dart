part of angular;

class Http {
  async.Future<String> getString(String url, {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    var cachedValue = cache != null ? cache.get(url) : null;
    if (cachedValue != null) {
      return new async.Future.value(cachedValue);
    }
    return dom.HttpRequest.getString(url, withCredentials: withCredentials, onProgress: onProgress).then((value) {
      if (cache != null) {
        cache.put(url, value);
      }
      return value;
    });
  }
}
