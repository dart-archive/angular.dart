part of angular.core.dom_internal;

final Logger _log = new Logger('WebPlatformShim');

/**
 * Shims for interacting with experimental platform feature that are required
 * for the correct behavior of angular, but are not supported on all browsers
 * without polyfills.
 */
abstract class WebPlatformShim {
  String shimCss(String css, { String selector, String cssUrl });

  void shimShadowDom(dom.Element root, String selector);

  bool get shimRequired;
}

/**
 * [PlatformJsBasedShim] is an implementation of WebPlatformShim that delegates
 * css shimming to platform.js. It also uses platform.js to detect if shimming is required.
 *
 * See http://www.polymer-project.org/docs/polymer/styling.html
 */
@Injectable()
class PlatformJsBasedShim implements WebPlatformShim {
  js.JsObject _shadowCss;

  bool get shimRequired => _shadowCss != null;

  PlatformJsBasedShim() {
    var _platformJs = js.context['Platform'];
    if (_platformJs != null) {
      _shadowCss = _platformJs['ShadowCSS'];
      if (_shadowCss != null) {
        _shadowCss['strictStyling'] = true;
      }
    }
  }

  String shimCss(String css, { String selector, String cssUrl }) {
    if (! shimRequired) return css;

    var shimmedCss =  _shadowCss.callMethod('shimCssText', [css, selector]);
    return "/* Shimmed css for <$selector> from $cssUrl */\n$shimmedCss";
  }

  /**
   * Because this code uses `strictStyling` for the polymer css shim, it is required to add the
   * custom element’s name as an attribute on all DOM nodes in the shadowRoot (e.g. <span x-foo>).
   *
   * See http://www.polymer-project.org/docs/polymer/styling.html#strictstyling
   */
  void shimShadowDom(dom.Element root, String selector) {
    if (! shimRequired) return;

    _addAttributeToAllElements(root, selector);
  }
}

@Injectable()
class DefaultPlatformShim implements WebPlatformShim {
  bool get shimRequired => true;

  String shimCss(String css, { String selector, String cssUrl }) {
    final shimmedCss = cssShim.shimCssText(css, selector);
    return "/* Shimmed css for <$selector> from $cssUrl */\n$shimmedCss";
  }

  void shimShadowDom(dom.Element root, String selector) {
    _addAttributeToAllElements(root, selector);
  }
}

void _addAttributeToAllElements(dom.Element root, String attr) {
  // This adds an empty attribute with the name of the component tag onto
  // each element in the shadow root.
  //
  // TODO: Remove the try-catch once https://github.com/angular/angular.dart/issues/1189 is fixed.
  try {
    root.querySelectorAll("*").forEach((n) => n.attributes[attr] = "");
  } catch (e, s) {
    _log.warning("WARNING: Failed to set up Shadow DOM shim for $attr.\n$e\n$s");
  }
}

class ShimmingViewFactoryCache implements ViewFactoryCache {
  final ViewFactoryCache cache;
  final String selector;
  final WebPlatformShim platformShim;

  LruCache<String, ViewFactory> get viewFactoryCache => cache.viewFactoryCache;
  Http get http => cache.http;
  TemplateCache get templateCache => cache.templateCache;
  Compiler get compiler => cache.compiler;
  dom.NodeTreeSanitizer get treeSanitizer => cache.treeSanitizer;
  ResourceUrlResolver get resourceResolver => cache.resourceResolver;
  dom.HtmlDocument get parseDocument => cache.parseDocument;

  ShimmingViewFactoryCache(this.cache, this.selector, this.platformShim);

  ViewFactory fromHtml(String html, DirectiveMap directives, [Uri baseUri]) {
    if (!platformShim.shimRequired) return cache.fromHtml(html, directives, baseUri);

    ViewFactory viewFactory = viewFactoryCache.get(_cacheKey(html));
    if (viewFactory != null) {
      return viewFactory;
    } else {
      // This MUST happen before the compiler is called so that every dom
      // element gets touched before the compiler removes them for
      // transcluding directives like ng-if.
      return viewFactoryCache.put(_cacheKey(html), _createViewFactory(html, directives));
    }
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives, [Uri baseUri]) {
    if (!platformShim.shimRequired) return cache.fromUrl(url, directives, baseUri);

    ViewFactory viewFactory = viewFactoryCache.get(url);
    if (viewFactory != null) {
      return new async.Future.value(viewFactory);
    } else {
      return http.get(url, cache: templateCache).then((resp) =>
          viewFactoryCache.put(_cacheKey(url), fromHtml(resp.responseText, directives)));
    }
  }

  ViewFactory _createViewFactory(String html, DirectiveMap directives) {
    var div = new dom.DivElement();
    div.setInnerHtml(html, treeSanitizer: treeSanitizer);
    platformShim.shimShadowDom(div, selector);
    return compiler(div.nodes, directives);
  }

  /**
   * By adding a comment with the tag name we ensure the cached resource is
   * unique per selector name when used as a key in the view factory cache.
   */
  String _cacheKey(String s) => "<!-- Shimmed template for: <$selector> -->$s";
}
