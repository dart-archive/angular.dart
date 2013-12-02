part of angular.core.dom;

/**
* This class provides low-level acces to the browser's cookies.
* It is not meant to be used directly by applications.  Instead
* use the Cookies service.
*
* NOTE the Cookies service is not yet implemented.
*/
@NgInjectableService()
class BrowserCookies {
  dom.Document _document;

  var lastCookies = {};
  var lastCookieString = '';
  var cookiePath;
  var baseElement;


  BrowserCookies() {
    // Injecting document produces the error 'Caught Compile-time error during mirrored execution:
    // <'file:///mnt/data/b/build/slave/dartium-lucid32-full-trunk/build/src/out/Release/gen/blink/
    // bindings/dart/dart/html/Document.dart': Error: line 7 pos 3: expression must be a compile-time constant
    // @ DocsEditable '
    // I have not had time to debug it yet.
    _document = dom.document;

    var baseElementList = _document.getElementsByName('base');
    if (baseElementList.isEmpty) return;
    baseElement = _document.getElementsByName('base').first;
    cookiePath = _baseHref();
  }

  var URL_PROTOCOL = new RegExp(r'^https?\:\/\/[^\/]*');
  _baseHref() {
    var href = baseElement != null ? baseElement.attr('href') : null;
    return href != null ? href.replace(URL_PROTOCOL, '') : '';
  }

  // NOTE(deboer): This is sub-optimal, see dartbug.com/14281
  _unescape(s) => Uri.decodeFull(s);
  _escape(s) =>
    Uri.encodeFull(s)
      .replaceAll('=', '%3D')
      .replaceAll(';', '%3B');


  _updateLastCookies() {
    var cookieLength, cookieArray, cookie, i, index;

    if (_document.cookie != lastCookieString) {
      lastCookieString = _document.cookie;
      cookieArray = lastCookieString.split("; ");
      lastCookies = {};

      for (i = 0; i < cookieArray.length; i++) {
        cookie = cookieArray[i];
        index = cookie.indexOf('=');
        if (index > 0) { //ignore nameless cookies
          var name = _unescape(cookie.substring(0, index));
          // the first value that is seen for a cookie is the most
          // specific one.  values for the same cookie name that
          // follow are for less specific paths.
          if (!lastCookies.containsKey(name)) {
            lastCookies[name] = _unescape(cookie.substring(index + 1));
          }
        }
      }
    }
    return lastCookies;
  }

  /**
   * Returns a cookie.
   */
  operator[](key) => _updateLastCookies()[key];

  /**
   * Sets a cookie.  Setting a cookie to [null] deletes the cookie.
   */
  operator[]=(name, value) {
    var cookieLength, cookieArray, cookie, i, index;

    if (identical(value, null)) {
      _document.cookie = "${_escape(name)}=;path=$cookiePath;expires=Thu, 01 Jan 1970 00:00:00 GMT";
    } else {
      if (value is String) {
        cookieLength = (_document.cookie = "${_escape(name)}=${_escape(value)};path=$cookiePath").length + 1;

        // per http://www.ietf.org/rfc/rfc2109.txt browser must allow at minimum:
        // - 300 cookies
        // - 20 cookies per unique domain
        // - 4096 bytes per cookie
        if (cookieLength > 4096) {
          print("Cookie '$name' possibly not set or overflowed because it was " +
                "too large ($cookieLength > 4096 bytes)!");
        }
      }
    }

  }

  get all => _updateLastCookies();
}
