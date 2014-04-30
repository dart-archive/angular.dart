library cookies_spec;

import '../_specs.dart';
import 'package:angular/core/module.dart';

void main() {
  describe('cookies', () {
    deleteAllCookies() {
      var cookies = document.cookie.split(";");
      var path = window.location.pathname;

      for (var i = 0; i < cookies.length; i++) {
        var cookie = cookies[i];
        var eqPos = cookie.indexOf("=");
        var name = eqPos > -1 ? cookie.substring(0, eqPos) : '';
        var parts = path.split('/');
        while (!parts.isEmpty) {
          var joinedParts = parts.join('/');
          document.cookie = name + "=;path=" + (joinedParts.isEmpty ? '/': joinedParts) +
          ";expires=Thu, 01 Jan 1970 00:00:00 GMT";
          parts.removeLast();
        }
      }
    }

    afterEach(() {
      deleteAllCookies();
      expect(document.cookie).toEqual('');
    });

    describe('browser cookies', () {
      var cookies;

      beforeEachModule((Module module) {
        module.bind(ExceptionHandler, toImplementation: LoggingExceptionHandler);
      });

      beforeEach((BrowserCookies iCookies) {
        iCookies.cookiePath = '/';
        deleteAllCookies();
        expect(document.cookie).toEqual('');

        iCookies.cookiePath = '/';
        cookies = iCookies;
      });

      describe('remove via cookies(cookieName, null)', () {

        it('should remove a cookie when it is present', () {
          document.cookie = 'foo=bar;path=/';

          cookies['foo'] = null;

          expect(document.cookie).toEqual('');
          expect(cookies.all).toEqual({});
        });


        it('should do nothing when an nonexisting cookie is being removed', () {
          cookies['doesntexist'] = null;
          expect(document.cookie).toEqual('');
          expect(cookies.all).toEqual({});
        });
      });


      describe('put via cookies(cookieName, string)', () {

        it('should create and store a cookie', () {
          cookies['cookieName'] = 'cookie=Value';
          expect(document.cookie).toEqual('cookieName=cookie%3DValue');
          expect(cookies.all).toEqual({'cookieName':'cookie=Value'});
        });


        it('should overwrite an existing unsynced cookie', () {
          document.cookie = "cookie=new;path=/";

          var oldVal = cookies['cookie'] = 'newer';

          expect(document.cookie).toEqual('cookie=newer');
          expect(cookies.all).toEqual({'cookie':'newer'});
          expect(oldVal).not.toBe(null);
        });

        it('should escape both name and value', () {
          cookies['cookie1='] = 'val;ue';
          cookies['cookie2=bar;baz'] = 'val=ue';

          var rawCookies = document.cookie.split("; "); //order is not guaranteed, so we need to parse
          expect(rawCookies.length).toEqual(2);
          expect(rawCookies).toContain('cookie1%3D=val%3Bue');
          expect(rawCookies).toContain('cookie2%3Dbar%3Bbaz=val%3Due');
        });

        it('should log warnings when 4kb per cookie storage limit is reached',
        (ExceptionHandler exceptionHandler) {
          var i, longVal = '', cookieStr;

          for (i=0; i<4083; i++) {
            longVal += 'r';  // Can't do + due to dartbug.com/14281
          }

          cookieStr = document.cookie;
          cookies['x'] = longVal; //total size 4093-4096, so it should go through
          expect(document.cookie).not.toEqual(cookieStr);
          expect(cookies['x']).toEqual(longVal);
          //expect(logs.warn).toEqual([]);
          var overflow = 'xxxxxxxxxxxxxxxxxxxx';
          cookies['x'] = longVal + overflow; //total size 4097-4099, a warning should be logged
          //expect(logs.warn).toEqual(
          //    [[ "Cookie 'x' possibly not set or overflowed because it was too large (4097 > 4096 " +
          //    "bytes)!" ]]);
          expect(document.cookie).not.toContain(overflow);

          //force browser to dropped a cookie and make sure that the cache is not out of sync
          cookies['x'] = 'shortVal';
          expect(cookies['x']).toEqual('shortVal'); //needed to prime the cache
          cookieStr = document.cookie;
          cookies['x'] = longVal + longVal + longVal; //should be too long for all browsers

          if (document.cookie != cookieStr) {
            throw "browser didn't drop long cookie when it was expected. make the " +
            "cookie in this test longer";
          }

          expect(cookies['x']).toEqual('shortVal');
          var errors = (exceptionHandler as LoggingExceptionHandler).errors;
          expect(errors.length).toEqual(2);
          expect(errors[0].error).
          toEqual("Cookie 'x' possibly not set or overflowed because it was too large (4113 > 4096 bytes)!");
          expect(errors[1].error).
          toEqual("Cookie 'x' possibly not set or overflowed because it was too large (12259 > 4096 bytes)!");
          errors.clear();
        });
      });

      xdescribe('put via cookies(cookieName, string), if no <base href> ', () {
        beforeEach(() {
          //fakeDocument.basePath = null;
        });

        it('should default path in cookie to "" (empty string)', () {
          cookies['cookie'] = 'bender';
          // This only fails in Safari and IE when cookiePath returns null
          // Where it now succeeds since baseHref return '' instead of null
          expect(document.cookie).toEqual('cookie=bender');
        });
      });

      describe('get via cookies[cookieName]', () {

        it('should return null for nonexistent cookie', () {
          expect(cookies['nonexistent']).toBe(null);
        });


        it ('should return a value for an existing cookie', () {
          document.cookie = "foo=bar=baz;path=/";
          expect(cookies['foo']).toEqual('bar=baz');
        });

        it('should return the the first value provided for a cookie', () {
          // For a cookie that has different values that differ by path, the
          // value for the most specific path appears first.  cookies()
          // should provide that value for the cookie.
          document.cookie = 'foo="first"; foo="second"';
          expect(cookies['foo']).toEqual('"first"');
        });

        it ('should unescape cookie values that were escaped by puts', () {
          document.cookie = "cookie2%3Dbar%3Bbaz=val%3Due;path=/";
          expect(cookies['cookie2=bar;baz']).toEqual('val=ue');
        });


        it('should preserve leading & trailing spaces in names and values', () {
          cookies[' cookie name '] = ' cookie value ';
          expect(cookies[' cookie name ']).toEqual(' cookie value ');
          expect(cookies['cookie name']).toBe(null);
        });
      });


      describe('getAll via cookies(', () {

        it('should return cookies as hash', () {
          document.cookie = "foo1=bar1;path=/";
          document.cookie = "foo2=bar2;path=/";
          expect(cookies.all).toEqual({'foo1':'bar1', 'foo2':'bar2'});
        });


        it('should return empty hash if no cookies exist', () {
          expect(cookies.all).toEqual({});
        });
      });


      it('should pick up external changes made to browser cookies', () {
        cookies['oatmealCookie'] = 'drool';
        expect(cookies.all).toEqual({'oatmealCookie':'drool'});

        document.cookie = 'oatmealCookie=changed;path=/';
        expect(cookies['oatmealCookie']).toEqual('changed');
      });


      it('should initialize cookie cache with existing cookies', () {
        document.cookie = "existingCookie=existingValue;path=/";
        expect(cookies.all).toEqual({'existingCookie':'existingValue'});
      });
    });

    describe('cookies service', () {
      var cookiesService;
      beforeEach((Cookies iCookies) {
        cookiesService = iCookies;
        document.cookie = 'oatmealCookie=fresh;path=/';
      });

      it('should read cookie', () {
        expect(cookiesService["oatmealCookie"]).toEqual("fresh");
      });

      describe("set cookie", () {
        it('should set new key value pair', () {
          cookiesService["oven"] = "hot";
          expect(document.cookie).toContain("oven=hot");
        });

        it('should override existing value', () {
          cookiesService["oatmealCookie"] = "stale";
          expect(document.cookie).toContain("oatmealCookie=stale");
        });
      });

      it('should remove cookie', () {
        cookiesService.remove("oatmealCookie");
        expect(document.cookie).not.toContain("oatmealCookie");
      });
    });
  });
}

