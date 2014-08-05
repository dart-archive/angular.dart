part of angular.core.dom_internal;

/**
 * Shims for interacting with experimental platform feature that are required
 * for the correct behavior of angular, but are not supported on all browsers
 * without polyfills.
 *
 * http://www.polymer-project.org/docs/polymer/styling.html
 */
@Injectable()
class WebPlatform {
  js.JsObject _shadowCss;

  bool get cssShimRequired => _shadowCss != null;
  bool get shadowDomShimRequired => _shadowCss != null;

  WebPlatform() {
    var platformJs = js.context['Platform'];
    if (platformJs != null) {
      _shadowCss = platformJs['ShadowCSS'];
      if (_shadowCss != null) _shadowCss['strictStyling'] = true;
    }
  }

  /**
   * Because this code uses `strictStyling` for the polymer css shim, it is required to add the
   * custom element’s name as an attribute on all DOM nodes in the shadowRoot (e.g. <span x-foo>).
   *
   * See http://www.polymer-project.org/docs/polymer/styling.html#strictstyling
   */
  String shimCss(String css, { String selector, String cssUrl }) {
    if (!cssShimRequired) return css;

    var shimmedCss =  _shadowCss.callMethod('shimCssText', [css, selector]);
    return "/* Shimmed css for <$selector> from $cssUrl */\n$shimmedCss";
  }

  void shimShadowDom(dom.Element root, String selector) {
    if (shadowDomShimRequired) {
      // This adds an empty attribute with the name of the component tag onto
      // each element in the shadow root.
      //
      // TODO Remove the try-catch once https://github.com/angular/angular.dart/issues/1189 is fixed.
      try {
        root.querySelectorAll("*").forEach((n) => n.attributes[selector] = "");
      } catch (e, s) {
        print("WARNING: Failed to set up Shadow DOM shim for $selector.\n$e\n$s");
      }
    }
  }
}

class PlatformViewCache implements ViewCache {
  final ViewCache cache;
  final String selector;
  final WebPlatform platform;
  bool _shimNeeded;
  String _cacheKeyPrefix;

  Cache<String, ViewFactory> get viewFactoryCache => cache.viewFactoryCache;
  Http get http => cache.http;
  TemplateCache get templateCache => cache.templateCache;
  Compiler get compiler => cache.compiler;
  dom.NodeTreeSanitizer get treeSanitizer => cache.treeSanitizer;

  PlatformViewCache(this.cache, this.selector, this.platform) {
    _shimNeeded = selector != null && selector != "" && platform.shadowDomShimRequired;
    // By adding a comment with the tag name we ensure the template html is unique per selector
    // name when used as a key in the view factory cache.
    _cacheKeyPrefix = _shimNeeded ? '<!-- Shimmed template for: <$selector> -->' : '';
  }

  ViewFactory fromHtml(String html, DirectiveMap directives) {
    ViewFactory viewFactory;

    String cacheKey = _cacheKeyPrefix + html;
    viewFactory = viewFactoryCache.get(cacheKey);

    if (viewFactory == null) {
      var div = new dom.DivElement();
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);

      // This MUST happen before the compiler is called so that every dom element gets touched
      // before the compiler removes them for transcluding directives like `ng-if`
      if (_shimNeeded) platform.shimShadowDom(div, selector);

      viewFactory = compiler(div.nodes, directives);
      viewFactoryCache.put(cacheKey, viewFactory);
    }
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives) {
    String cacheKey = _cacheKeyPrefix + url;
    ViewFactory viewFactory = viewFactoryCache.get(cacheKey);
    if (viewFactory == null) {
      return http.get(url, cache: templateCache).then((resp) {
        ViewFactory factory = fromHtml(resp.responseText, directives);
        viewFactoryCache.put(cacheKey, factory);
        return factory;
      });
    }
    return new async.Future.value(viewFactory);
  }
}
