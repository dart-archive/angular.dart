library angular.core.service.http;

import '../cache.dart';
import 'dart:async' as async;
import 'dart:html' as dom;
import 'dart:json' as json;


class UrlRewriter {
  String call(url) => url;
}

/**
 * HTTP backend used by the [Http] service that delegates to dart:html's
 * [HttpRequest] and deals with Dart bugs.
 *
 * Never use this service directly, instead use the higher-level [Http].
 *
 * During testing this implementation is swapped with [MockHttpBackend] which
 * can be trained with responses.
 */
class HttpBackend {
  /**
   * Wrapper around dart:html's [HttpRequest.request]
   */
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

/**
 * The request configuration of the request associated with this response.
 */
class HttpResponseConfig {
  /**
   * The request's URL
   */
  String url;

  /**
   * Constructor
   */
  HttpResponseConfig({this.url});
}

/**
 * The response for an HTTP request.  Returned from the [Http] service.
 */
class HttpResponse {
/**
  * The HTTP status code.
*/
  int status;

/**
  * DEPRECATED
*/
  var responseText;
  Map _headers;

/**
  * The [HttpResponseConfig] object which contains the requested URL
*/
  HttpResponseConfig config;

/**
  * Constructor
*/
  HttpResponse([this.status, this.responseText, this._headers, this.config]);

  /**
   * Copy constructor.  Creates a clone of the response, optionally with new
   * data.
   */
  HttpResponse.copy(HttpResponse r, {data}) {
    status = r.status;
    responseText = data == null ? r.responseText : data;
    _headers = r._headers == null ? null : new Map.from(r._headers);
    config = r.config;
  }

/**
  * The response's data.  Either a string or a transformed object.
*/
  get data => responseText;

  /**
   * The response's headers.  Without parameters, this method will return the
   * [Map] of headers.  With [key] parameter, this method will return the specific
   * header.
   */
  headers([String key]) {
    if (key == null) {
      return _headers;
    }
    if (_headers.containsKey(key)) {
      return _headers[key];
    }
    return null;
  }

  /**
   * Useful for debugging.
   */
  toString() => 'HTTP $status: $data';
}

/**
 * Default header configuration.
 */
class HttpDefaultHeaders {
  static String _defaultContentType = 'application/json;charset=utf-8';
  Map _headers = {
    'COMMON': {
        'Accept': 'application/json, text/plain, */*'
    },
    'POST' : {
        'Content-Type': _defaultContentType
    },
    'PUT' : {
      'Content-Type': _defaultContentType
    },
    'PATCH' : {
      'Content-Type': _defaultContentType
    }
  };

  _applyHeaders(method, ucHeaders, headers) {
    if (!_headers.containsKey(method)) return;
    _headers[method].forEach((k, v) {
      if (!ucHeaders.contains(k.toUpperCase())) {
        headers[k] = v;
      }
    });
  }

  /**
   * Called from [Http], this method sets default headers on [headers]
   */
  setHeaders(Map<String, String> headers, String method) {
    assert(headers != null);
    var ucHeaders = headers.keys.map((x) => x.toUpperCase()).toSet();
    _applyHeaders('COMMON', ucHeaders, headers);
    _applyHeaders(method.toUpperCase(), ucHeaders, headers);
  }

  /**
   * Returns the default header [Map] for a method.  You can then modify
   * the map.
   *
   * Passing 'common' as [method] will return a Map that contains headers
   * common to all operations.
   */
  operator[](method) {
    return _headers[method.toUpperCase()];
  }
}

/**
* Injected into the [Http] service.  This class contains application-wide
* HTTP defaults.
*
* The default implementation provides headers and interceptors which the
* Angular team believes to be useful.
*/
class HttpDefaults {
  /**
   * The [HttpDefaultHeaders] object used by [Http] to add default headers
   * to requests.
   */
  HttpDefaultHeaders headers;
  /** DEPRECATED */
  List<Function> transformRequest;
  /** DEPRECATED */
  List<Function> transformResponse;

  /**
   * The default cache.  To enable caching application-wide, instantiate with a
   * [Cache] object.
   */
  var cache;

  static _defaultTransformRequest(d, _) =>
    d is String || d is dom.File ? d : json.stringify(d);


  static var _JSON_START = new RegExp(r'^\s*(\[|\{[^\{])');
  static var _JSON_END = new RegExp(r'[\}\]]\s*$');
  static var _PROTECTION_PREFIX = new RegExp('^\\)\\]\\}\',?\\n');
  static _defaultTransformResponse(d, _) {
    if (d is String) {
      d = d.replaceFirst(_PROTECTION_PREFIX, '');
      if (d.contains(_JSON_START) && d.contains(_JSON_END)) {
        d = json.parse(d);
      }
    }
    return d;
  }

  /**
   * Constructor intended for DI.
   */
  HttpDefaults(HttpDefaultHeaders this.headers) {
    transformRequest = [_defaultTransformRequest];
    transformResponse = [_defaultTransformResponse];
  }
}

/**
 * The [Http] service facilitates communication with the remote HTTP servers.  It
 * uses dart:html's [HttpRequest] and provides a number of features on top
 * of the core Dart library.
 *
 * For unit testing, applications should use the [MockHttpBackend] service.
 *
 * # General usage
 * The [call] method takes a number of named parameters and returns a
 * [Future<HttpResponse>].
 *
 *      http(method: 'GET', url: '/someUrl')
 *        .then((HttpResponse response) { .. },
 *               onError: (HttpRequest request) { .. });
 *
 * A response status code between 200 and 299 is considered a success status and
 * will result in the 'then' being called. Note that if the response is a redirect,
 * Dart's [HttpRequest] will transparently follow it, meaning that the error callback will not be
 * called for such responses.
 *
 * # Shortcut methods
 *
 * The Http service also defines a number of shortcuts:
 *
 *      http.get('/someUrl') is the same as http(method: 'GET', url: '/someUrl')
 *
 * See the method definitions below.
 *
 * # Setting HTTP Headers
 *
 * The [Http] service will add certain HTTP headers to requests.  These defaults
 * can be configured using the [HttpDefaultHeaders] object.  The defaults are:
 *
 * - For all requests: `Accept: application/json, text/plain, * / *`
 * - For POST, PUT, PATCH requests: `Content-Type: application/json`
 *
 * # Transforming Requests and Responses
 *
 *  NOTE: < use interceptors >.
 *
 * # Caching
 *
 * To enable caching, pass a [Cache] object into the [call] method.  The [Http]
 * service will store responses in the cache and return the response for
 * any matching requests.
 *
 * Note that data is returned through a [Future], regardless of whether it
 * came from the [Cache] or the server.
 *
 * If there are multiple GET requests for the same not-yet-in-cache URL
 * while a cache is in use, only one request to the server will be made.
 *
 * # Interceptors
 *
 * NOTE: < not yet implemented >
 *
 * # Security Considerations
 *
 * NOTE: < not yet documented >
 */
class Http {
  Map<String, async.Future<HttpResponse>> _pendingRequests = <String, async.Future<HttpResponse>>{};
  UrlRewriter _rewriter;
  HttpBackend _backend;
  HttpDefaults defaults;

  /**
   * Constructor, useful for DI.
   */
  Http(UrlRewriter this._rewriter, HttpBackend this._backend, HttpDefaults this.defaults);

  /**
   * DEPRECATED
   */
  async.Future<String> getString(String url,
      {bool withCredentials, void onProgress(dom.ProgressEvent e), Cache cache}) {
    return request(url,
        withCredentials: withCredentials,
        onProgress: onProgress,
        cache: cache).then((HttpResponse xhr) => xhr.responseText);
  }

/**
  * Returns a [Future<HttpResponse>] when the request is fulfilled.
  *
  * Named Parameters:
  * - method: HTTP method (e.g. 'GET', 'POST', etc)
  * - url: Absolute or relative URL of the resource being requested.
  * - data: Data to be sent as the request message data.
  * - params: Map of strings or objects which will be turned to
  *          `?key1=value1&key2=value2` after the url. If the values are
  *           not strings, they will be JSONified.
  * - headers: Map of strings or functions which return strings representing
  *      HTTP headers to send to the server. If the return value of a function
  *      is null, the header will not be sent.
  * - xsrfHeaderName: TBI
  * - xsrfCookieName: TBI
  * - transformRequest: deprecated
  * - transformResponse: deprecated
  * - cache: Boolean or [Cache].  If true, the default cache will be used.
  * - timeout: deprecated
*/
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
        timeout != null) {
      throw ['not implemented'];
    }

    method = method.toUpperCase();

    if (transformRequest == null) transformRequest = defaults.transformRequest;
    if (transformResponse == null) transformResponse = defaults.transformResponse;

    if (headers == null) { headers = {}; }
    defaults.headers.setHeaders(headers, method);

    // Check for functions in headers
    headers.forEach((k,v) {
      if (v is Function) {
        headers[k] = v();
      }
    });

    // Transform data.
    var reqData = _transformData(data, _headersGetter(headers), transformRequest);
    assert(reqData is String || reqData is dom.File);

    // Strip content-type if data is undefined
    if (data == null) {
      List<String> toRemove = [];
      headers.forEach((h, _) {
        if (h.toUpperCase() == 'CONTENT-TYPE') {
          toRemove.add(h);
        };
      });
      toRemove.forEach((x) => headers.remove(x));
    }


    return request(
        _buildUrl(url, params),
        method: method,
        sendData: reqData,
        requestHeaders: headers,
        cache: cache).then((HttpResponse r) {
      var data = _transformData(r.data, r.headers, transformResponse);
      if (!identical(data, r.data)) {
        return new HttpResponse.copy(r, data: data);
      }
      return r;
    });
  }

  /**
   * Shortcut method for GET requests.  See [call] for a complete description
   * of parameters.
   */
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

  /**
   * Shortcut method for DELETE requests.  See [call] for a complete description
   * of parameters.
   */
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

  /**
   * Shortcut method for HEAD requests.  See [call] for a complete description
   * of parameters.
   */
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

  /**
   * Shortcut method for PUT requests.  See [call] for a complete description
   * of parameters.
   */
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

  /**
   * Shortcut method for POST requests.  See [call] for a complete description
   * of parameters.
   */
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

  /**
   * Shortcut method for JSONP requests.  See [call] for a complete description
   * of parameters.
   */
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
   * Parse raw headers into key-value object
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

  /**
   * Returns an [Iterable] of [Future] [HttpResponse]s for the requests
   * that the [Http] service is currently waiting for.
   */
  Iterable<async.Future<HttpResponse> > get pendingRequests {
    return _pendingRequests.values;
  }

  /**
   * DEPRECATED
   */
  async.Future<HttpResponse> request(String rawUrl,
      { String method: 'GET',
        bool withCredentials: false,
        String responseType,
        String mimeType,
        Map<String, String> requestHeaders,
        sendData,
        void onProgress(dom.ProgressEvent e),
        /*Cache<HttpResponse> or false*/ cache }) {
    String url = _rewriter(rawUrl);

    if (cache is bool && cache == false) {
      cache = null;
    } else if (cache == null) {
      cache = defaults.cache;
    }
    // We return a pending request only if caching is enabled.
    if (cache != null && _pendingRequests.containsKey(url)) {
      return _pendingRequests[url];
    }
    var cachedValue = (cache != null && method == 'GET') ? cache.get(url) : null;
    if (cachedValue != null) {
      return new async.Future.value(new HttpResponse.copy(cachedValue));
    }
    var result = _backend.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress).then((dom.HttpRequest value) {
      assert(value.status >= 200 && value.status < 300);

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

  /*String or File*/ _transformData(data, headers, fns) {
    if (fns is Function) {
      return fns(data, headers);
    }

    fns.forEach((fn) {
      data = fn(data, headers);
    });
    return data;
  }

  Function _headersGetter(Map headers) {
    var headersObj;

    return ([String name]) {
      if (headersObj == null) {
        headersObj = {};
        headers.forEach((k,v) {
          headersObj[k.toLowerCase()] = v;
        });
      }

      if (name != null) {
        name = name.toLowerCase();
        if (!headersObj.containsKey(name)) return null;
        return headersObj[name];
      }

      return headersObj;
    };
  }
}
