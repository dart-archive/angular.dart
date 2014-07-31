part of angular.core.dom_internal;

/**
 * This class provides low-level access to the browser's cookies. It is not meant to be used
 * directly by applications. Use the [Cookies] service instead.
 */
@Injectable()
class BrowserCookies {
  String cookiePath = '/';

  ExceptionHandler _exceptionHandler;
  dom.Document _document;
  var _lastCookies = <String, String>{};
  var _lastCookieString = '';
  var _baseElement;

  BrowserCookies(this._exceptionHandler) {
    _document = dom.document;
    var baseElementList = _document.getElementsByName('base');
    if (baseElementList.isEmpty) return;
    _baseElement = baseElementList.first;
    cookiePath = _baseHref();
  }

  final URL_PROTOCOL = new RegExp(r'^https?\:\/\/[^\/]*');

  String _baseHref() {
    var href = _baseElement != null ? _baseElement.attr('href') : null;
    return href != null ? href.replace(URL_PROTOCOL, '') : '';
  }

  // NOTE(deboer): This is sub-optimal, see dartbug.com/14281
  String _unescape(s) => Uri.decodeFull(s);

  String _escape(s) => Uri.encodeFull(s).replaceAll('=', '%3D').replaceAll(';', '%3B');

  Map<String, String> _updateLastCookies() {
    if (_document.cookie != _lastCookieString) {
      _lastCookieString = _document.cookie;
      List<String> cookieArray = _lastCookieString.split("; ");
      _lastCookies = {};

      // The first value that is seen for a cookie is the most specific one.
      // Values for the same cookie name that follow are for less specific paths.
      // Hence we reverse the array.
      cookieArray.reversed.forEach((cookie) {
        var index = cookie.indexOf('=');
        if (index > 0) { //ignore nameless cookies
          var name = _unescape(cookie.substring(0, index));
          _lastCookies[name] = _unescape(cookie.substring(index + 1));
        }
      });
    }
    return _lastCookies;
  }

  /// Return a cookie by name
  String operator[](key) => _updateLastCookies()[key];

  /// Sets a cookie.  Setting a cookie to [null] deletes the cookie.
  void operator[]=(name, value) {
    if (value == null) {
      _document.cookie = "${_escape(name)}=;path=$cookiePath;expires=Thu, 01 Jan 1970 00:00:00 GMT";
    } else {
      if (value is String) {
        var cookie = "${_escape(name)}=${_escape(value)};path=$cookiePath";
        _document.cookie = cookie;
        var cookieLength = cookie.length + 1;

        // per http://www.ietf.org/rfc/rfc2109.txt browser must allow at minimum:
        // - 300 cookies
        // - 20 cookies per unique domain
        // - 4096 bytes per cookie
        if (cookieLength > 4096) {
          _exceptionHandler("Cookie '$name' possibly not set or overflowed because it was " +
                            "too large ($cookieLength > 4096 bytes)!", null);
        }
      }
    }
  }

  Map<String, String> get all => _updateLastCookies();
}

/// Handling of browser cookies
@Injectable()
class Cookies {
  BrowserCookies _browserCookies;

  Cookies(this._browserCookies);

  /// Returns the value of given cookie key
  String operator[](name) => _browserCookies[name];

  /// Sets a value for given cookie key
  void operator[]=(name, value) {
    _browserCookies[name] = value;
  }

  /// Remove given cookie
  void remove(name) {
    _browserCookies[name] = null;
  }
}

