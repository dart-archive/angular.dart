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
        root.querySelectorAll("*").forEach((dom.Element n) => n.setAttribute(selector, ""));
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
  final dom.HtmlDocument parseDocument =
      dom.document.implementation.createHtmlDocument('');

  get resourceResolver => cache.resourceResolver;
  get viewFactoryCache => cache.viewFactoryCache;
  Http get http => cache.http;
  TemplateCache get templateCache => cache.templateCache;
  Compiler get compiler => cache.compiler;
  dom.NodeTreeSanitizer get treeSanitizer => cache.treeSanitizer;

  PlatformViewCache(this.cache, this.selector, this.platform);

  ViewFactory fromHtml(String html, DirectiveMap directives, [Uri baseUri]) {
    ViewFactory viewFactory;

    if (selector != null && selector != "" && platform.shadowDomShimRequired) {
      // By adding a comment with the tag name we ensure the template html is unique per selector
      // name when used as a key in the view factory cache.
      //TODO(misko): This will always be miss, since we never put it in cache under such key.
      viewFactory = viewFactoryCache.get("<!-- Shimmed template for: <$selector> -->$html");
    } else {
      viewFactory = viewFactoryCache.get(html);
    }

    if (baseUri != null)
      html = resourceResolver.resolveHtml(html, baseUri);
    else
      html = resourceResolver.resolveHtml(html);

    var div = parseDocument.createElement('div');
    div.setInnerHtml(html, treeSanitizer: treeSanitizer);

    if (selector != null && selector != "" && platform.shadowDomShimRequired) {
      // This MUST happen before the compiler is called so that every dom element gets touched
      // before the compiler removes them for transcluding directives like `ng-if`
      platform.shimShadowDom(div, selector);
    }

    if (viewFactory == null) {
      viewFactory = compiler(div.nodes, directives);
      viewFactoryCache.put(html, viewFactory);
    }
    return viewFactory;
  }

  async.Future<ViewFactory> fromUrl(String url, DirectiveMap directives, [Uri baseUri]) {
    var key = "[$selector]$url";
    ViewFactory viewFactory = viewFactoryCache.get(key);
    if (viewFactory == null) {
      return http.get(url, cache: templateCache).then((resp) {
        var viewFactoryFromHttp = fromHtml(resp.responseText, directives, baseUri);
        viewFactoryCache.put(key, viewFactoryFromHttp);
        return viewFactoryFromHttp;
      });
    }
    return new async.Future.value(viewFactory);
  }
}
