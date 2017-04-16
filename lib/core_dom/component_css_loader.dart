part of angular.core.dom_internal;

class ComponentCssLoader {
  final Http _http;
  final TemplateCache _templateCache;
  final WebPlatformShim _platformShim;
  final ComponentCssRewriter _componentCssRewriter;
  final dom.NodeTreeSanitizer _treeSanitizer;
  final ResourceUrlResolver _resourceResolver;
  final Map<_ComponentAssetKey, async.Future<dom.StyleElement>> _styleElementCache;

  ComponentCssLoader(this._http, this._templateCache, this._platformShim,
                      this._componentCssRewriter, this._treeSanitizer,
                      this._styleElementCache, this._resourceResolver);

  async.Future<List<dom.StyleElement>> call(String tag, String attribute, List<String> cssUrls, {Type type}) =>
      async.Future.wait(cssUrls.map((url) => _styleElement(tag, attribute, url, type)));

  async.Future<dom.StyleElement> _styleElement(String tag, String attribute, String cssUrl, Type type) {
    if (type != null) cssUrl = _resourceResolver.combineWithType(type, cssUrl);
    final element = _styleElementCache.putIfAbsent(
        new _ComponentAssetKey(tag, cssUrl),
        () => _loadNewCss(tag, attribute, cssUrl));
    return element;
  }

  async.Future _loadNewCss(String tag, String attribute, String cssUrl) {
    return _fetch(cssUrl)
        .then((css) => _resourceResolver.resolveCssText(css, Uri.parse(cssUrl)))
        .then((css) => _shim(css, tag, attribute, cssUrl))
        .then(_buildStyleElement);
  }

  async.Future<String> _fetch(String cssUrl) {
    return _http.get(cssUrl, cache: _templateCache)
        .then((resp) => resp.responseText, onError: (e) => '/* $e */');
  }

  String _shim(String css, String tag, String attribute, String cssUrl) {
    final shimmed = _platformShim.shimCss(css, selector: tag, attribute: attribute, cssUrl: cssUrl);
    return _componentCssRewriter(shimmed, selector: tag, cssUrl: cssUrl);
  }

  dom.StyleElement _buildStyleElement(String css) {
    var styleElement = new dom.StyleElement()..appendText(css);
    _treeSanitizer.sanitizeTree(styleElement);
    return styleElement;
  }
}

class _ComponentAssetKey {
  final String tag;
  final String assetUrl;

  final String _key;

  _ComponentAssetKey(String tag, String assetUrl)
      : _key = "$tag|$assetUrl", tag = tag, assetUrl = assetUrl;

  @override
  String toString() => _key;

  @override
  int get hashCode => _key.hashCode;

  bool operator ==(key) =>
      key is _ComponentAssetKey && tag == key.tag && assetUrl == key.assetUrl;
}
