/**
 * Dart port of
 * https://github.com/Polymer/platform-dev/blob/896e245a0046a397bfc0190d958d2bd162e8f53c/src/url.js
 *
 * This converts URIs within a document from relative URIs to being absolute URIs.
 */

library angular.core_dom.resource_url_resolver;

import 'dart:html';
import 'dart:js' as js;

import 'package:di/di.dart';
import 'package:di/annotations.dart';

import 'package:angular/core_dom/type_to_uri_mapper.dart';

class _NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

@Injectable()
class ResourceUrlResolver {
  static final RegExp cssUrlRegexp = new RegExp(r'''(\burl\((?:[\s]+)?)(['"]?)([\S]*)(\2(?:[\s]+)?\))''');
  static final RegExp cssImportRegexp = new RegExp(r'(@import[\s]+(?!url\())([^;]*)(;)');
  static const List<String> urlAttrs = const ['href', 'src', 'action'];
  static final String urlAttrsSelector = '[${urlAttrs.join('],[')}]';
  static final RegExp urlTemplateSearch = new RegExp('{{.*}}');
  static final RegExp quotes = new RegExp("[\"\']");

  // Ensures that Uri.base is http/https.
  final _baseUri = Uri.base.origin + ('/');

  final TypeToUriMapper _uriMapper;
  final ResourceResolverConfig _config;

  ResourceUrlResolver(this._uriMapper, this._config);

  static final NodeTreeSanitizer _nullTreeSanitizer = new _NullTreeSanitizer();
  static final docForParsing = document.implementation.createHtmlDocument('');

  static Node _parseHtmlString(String html) {
    var div = docForParsing.createElement('div');
    div.setInnerHtml(html, treeSanitizer: _nullTreeSanitizer);
    return div;
  }

  String resolveHtml(String html, [Uri baseUri]) {
    if (baseUri == null) {
      return html;
    }
    Node node = _parseHtmlString(html);
    _resolveDom(node, baseUri);
    return node.innerHtml;
  }

  /**
   * Resolves all relative URIs within the DOM from being relative to
   * [originalBase] to being absolute.
   */
  void _resolveDom(Node root, Uri baseUri) {
    _resolveAttributes(root, baseUri);
    _resolveStyles(root, baseUri);

    // handle template.content
    for (var template in _querySelectorAll(root, 'template')) {
      if (template.content != null) {
        _resolveDom(template.content, baseUri);
      }
    }
  }

  Iterable<Element> _querySelectorAll(Node node, String selectors) {
    if (node is DocumentFragment) {
      return node.querySelectorAll(selectors);
    }
    if (node is Element) {
      return node.querySelectorAll(selectors);
    }
    return const [];
  }

  void _resolveStyles(Node node, Uri baseUri) {
    var styles = _querySelectorAll(node, 'style');
    for (var style in styles) {
      _resolveStyle(style, baseUri);
    }
  }

  void _resolveStyle(StyleElement style, Uri baseUri) {
    style.text = resolveCssText(style.text, baseUri);
  }

  String resolveCssText(String cssText, Uri baseUri) {
    cssText = _replaceUrlsInCssText(cssText, baseUri, cssUrlRegexp);
    return _replaceUrlsInCssText(cssText, baseUri, cssImportRegexp);
  }

  void _resolveAttributes(Node root, Uri baseUri) {
    if (root is Element) {
      _resolveElementAttributes(root, baseUri);
    }

    for (var node in _querySelectorAll(root, urlAttrsSelector)) {
      _resolveElementAttributes(node, baseUri);
    }
  }

  void _resolveElementAttributes(Element element, Uri baseUri) {
    var attrs = element.attributes;
    for (var attr in urlAttrs) {
      if (attrs.containsKey(attr)) {
        var value = attrs[attr];
        if (!value.contains(urlTemplateSearch)) {
          attrs[attr] = combine(baseUri, value).toString();
        }
      }
    }
  }

  String _replaceUrlsInCssText(String cssText, Uri baseUri, RegExp regexp) {
    return cssText.replaceAllMapped(regexp, (match) {
      var url = match[3].trim();
      var urlPath = combine(baseUri, url).toString();
      return '${match[1].trim()}${match[2]}${urlPath}${match[2]})';
    });
  }
  /// Combines a type-based URI with a relative URI.
  ///
  /// [baseUri] is assumed to use package: syntax for package-relative
  /// URIs, while [uri] is assumed to use 'packages/' syntax for
  /// package-relative URIs. Resulting URIs will use 'packages/' to indicate
  /// package-relative URIs.
  String combine(Uri baseUri, String uri) {
    if (!_config.useRelativeUrls) {
       return uri;
    }

    if (uri == null) {
      uri = baseUri.path;
    } else {
      // if it's absolute but not package-relative, then just use that
      // The "packages/" test is just for backward compatibility.  It's ok to
      // not resolve them, even through they're relative URLs, because in a Dart
      // application, "packages/" is managed by pub which creates a symlinked
      // hierarchy and they should all resolve to the same file at any level
      // that a "packages/" exists.
      if (uri.startsWith("/") || uri.startsWith('packages/')) {
        return uri;
      }
    }
    // If it's not absolute, then resolve it first
    Uri resolved = baseUri.resolve(uri);

    // If it's package-relative, tack on 'packages/' - Note that eventually
    // we may want to change this to be '/packages/' to make it truly absolute
    if (resolved.scheme == 'package') {
      return 'packages/${resolved.path}';
    } else if (resolved.isAbsolute && resolved.toString().startsWith(_baseUri)) {
      var path = resolved.path;
      return path.startsWith("/") ? path.substring(1) : path;
    } else {
      return resolved.toString();
    }
  }

  String combineWithType(Type type, String uri) {
    if (_config.useRelativeUrls) {
      return combine(_uriMapper.uriForType(type), uri);
    } else {
      return uri;
    }
  }
}

@Injectable()
class ResourceResolverConfig {
  bool useRelativeUrls;

  ResourceResolverConfig(): useRelativeUrls = true;

  ResourceResolverConfig.resolveRelativeUrls(this.useRelativeUrls);
}
