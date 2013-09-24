library angular.core.service.http;

import '../cache.dart';
import 'dart:async' as async;
import 'dart:html' as dom;
import 'dart:json' as json;


class UrlRewriter {
  String call(url) => url;
}

class HttpBackend {
  async.Future request(String url,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(dom.ProgressEvent e)}) {
    // Complete inside a then to work-around dartbug.com/13051
    var c = new async.Completer();

    dom.HttpRequest.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress).then((x) => c.complete(x));
    return c.future;
  }
}

class HttpResponseConfig {
  String url;

  HttpResponseConfig({this.url});
}

class HttpResponse {
  int status;
  String responseText;
  var _headers;
  HttpResponseConfig config;
  HttpResponse([this.status, this.responseText, this._headers, this.config]);

  // AngularJS style:
  get data => responseText;

  headers([String key]) {
    if (key == null) {
      return _headers;
    }
    if (_headers.containsKey(key)) {
      return _headers[key];
    }
    return null;
  }

  toString() => 'HTTP $status: $responseText';
}

class HttpDefaultHeaders {
  setHeaders(Map<String, String> headers, String method) {
    assert(headers != null);
     var ucHeaders = headers.keys.map((x) => x.toUpperCase()).toSet();
    // common
    if (!ucHeaders.contains('ACCEPT')) {
      headers['Accept'] = 'application/json, text/plain, */*';
    }

    // per-method
    method = method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      if (!ucHeaders.contains('CONTENT-TYPE')) {
        headers['Content-Type'] = 'application/json;charset=utf-8';
      }
    }
  }
}

class HttpDefaults {
  var headers;
  var cache;

  HttpDefaults(HttpDefaultHeaders this.headers);
}

/**
 * Wrapper around the browser XHR. Use Http service to fetch data
 * from the server.
 */
class Http {
  Map<String, async.Future<HttpResponse>> _pendingRequests = <String, async.Future<HttpResponse>>{};
  UrlRewriter _rewriter;
  HttpBackend _backend;
  HttpDefaults defaults;

  List pendingRequests = []; // TODO(deboer): From the AngularJS API.

  Http(UrlRewriter this._rewriter, HttpBackend this._backend, HttpDefaults this.defaults);

  async.Future<String> getString(String url,
      {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    return request(url,
        withCredentials: withCredentials,
        onProgress: onProgress,
        cache: cache).then((HttpResponse xhr) => xhr.responseText);
  }

  async.Future<HttpResponse> call({
    String url,
    String method,
    data,
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) {
    if (xsrfHeaderName != null || xsrfCookieName != null ||
        transformResponse != null ||
        transformRequest != null || cache != null || timeout != null) {
      throw ['not implemented'];
    }

    if (headers == null) { headers = {}; }
    defaults.headers.setHeaders(headers, method);

    //
    if (data == null) {
      List<String> toRemove = [];
      headers.forEach((h, _) {
        if (h.toUpperCase() == 'CONTENT-TYPE') {
          toRemove.add(h);
        };
      });
      toRemove.forEach((x) => headers.remove(x));
    }

    // Check for functions in headers
    headers.forEach((k,v) {
      if (v is Function) {
        headers[k] = v();
      }
    });
    return request(_buildUrl(url, params), method: method, sendData: data, requestHeaders: headers);
  }

  async.Future<HttpResponse> get(String url, {
    String data,
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'GET', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);

  async.Future<HttpResponse> delete(String url, {
    String data,
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'DELETE', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);

  async.Future<HttpResponse> head(String url, {
    String data,
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'HEAD', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);

  async.Future<HttpResponse> put(String url, String data, {
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'PUT', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);

  async.Future<HttpResponse> post(String url, String data, {
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'POST', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);

  async.Future<HttpResponse> jsonp(String url, {
    String data,
    Map<String, dynamic> params,
    Map<String, String> headers,
    xsrfHeaderName,
    xsrfCookieName,
    transformRequest,
    transformResponse,
    cache,
    timeout
  }) => call(method: 'JSONP', url: url, data: data, params: params, headers: headers,
             xsrfHeaderName: xsrfHeaderName, xsrfCookieName: xsrfCookieName,
             transformRequest: transformRequest, transformResponse: transformResponse,
             cache: cache, timeout: timeout);


/**
   * Parse headers into key value object
   *
   * @param {string} headers Raw headers as a string
   * @returns {Object} Parsed headers as key value object
   */
  static Map<String, String> parseHeaders(dom.HttpRequest value) {
    var headers = value.getAllResponseHeaders();

    var parsed = {}, key, val, i;

    if (headers == null) return parsed;

    headers.split('\n').forEach((line) {
      i = line.indexOf(':');
      if (i == -1) return;
      key = line.substring(0, i).trim().toLowerCase();
      val = line.substring(i + 1).trim();

      if (key != '') {
        if (parsed.containsKey(key)) {
          parsed[key] += ', ' + val;
        } else {
          parsed[key] = val;
        }
      }
    });
    return parsed;
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
        onProgress: onProgress).then((dom.HttpRequest value) {

      var response = new HttpResponse(
          value.status, value.responseText, parseHeaders(value),
          new HttpResponseConfig(url: url));

      if (cache != null) {
        cache.put(url, response);
      }
      _pendingRequests.remove(url);
      return response;
    }, onError: (dom.HttpRequestProgressEvent event) {
      _pendingRequests.remove(url);
      dom.HttpRequest request = event.currentTarget;
      return new async.Future.error(
          new HttpResponse(request.status, request.response,
              parseHeaders(request), new HttpResponseConfig(url: url)));
    });
    _pendingRequests[url] = result;
    return result;
  }

  _buildUrl(String url, Map<String, dynamic> params) {
    if (params == null) return url;
    var parts = [];

    new List.from(params.keys)..sort()..forEach((String key) {
      var value = params[key];
      if (value == null) return;
      if (value is! List) value = [value];

      value.forEach((v) {
        if (v is Map) {
          v = json.stringify(v);
        }
        parts.add(_encodeUriQuery(key) + '=' +
        _encodeUriQuery("$v"));
      });
    });
    return url + ((url.indexOf('?') == -1) ? '?' : '&') + parts.join('&');
  }

  _encodeUriQuery(val, {bool pctEncodeSpaces: false}) =>
    Uri.encodeComponent(val)
      .replaceAll('%40', '@')
      .replaceAll('%3A', ':')
      .replaceAll('%24', r'$')
      .replaceAll('%2C', ',')
      .replaceAll('%20', pctEncodeSpaces ? '%20' : '+');
}
