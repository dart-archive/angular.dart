part of angular;

class Http {
  async.Future<String> getString(String url, {bool withCredentials, void onProgress(dom.ProgressEvent e)}) =>
    dom.HttpRequest.getString(url, withCredentials: withCredentials, onProgress: onProgress);
}
