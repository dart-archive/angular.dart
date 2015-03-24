/**
 * Dart port of
 * https://github.com/Polymer/platform-dev/blob/896e245a0046a397bfc0190d958d2bd162e8f53c/src/url.js
 *
 * This converts URIs within a document from relative URIs to being absolute URIs.
 */

library angular.core_dom.resource_url_resolver;

import 'dart:html';

import 'package:di/di.dart';
import 'package:di/annotations.dart';

import 'package:angular/core_dom/type_to_uri_mapper.dart';

class _NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

@Injectable()
class ResourceUrlResolver {
  static final RegExp cssUrlRegexp = new RegExp(r'''(\burl\((?:[\s]+)?)(['"]?)([\S]*?)(\2(?:[\s]+)?\))''');
  static final RegExp cssImportRegexp = new RegExp(r'(@import[\s]+(?!url\())([^;]*)(;)');
  static const List<String> urlAttrs = const ['href', 'src', 'action'];
  static final String urlAttrsSelector = '[${urlAttrs.join('],[')}]';
  static final RegExp urlTemplateSearch = new RegExp('{{.*}}');
  static final RegExp quotes = new RegExp("[\"\']");

  // Reconstruct the Uri without the http or https restriction due to Uri.base.origin
  final String _baseUri;

  final TypeToUriMapper _uriMapper;
  final ResourceResolverConfig _config;

  ResourceUrlResolver(this._uriMapper, this._config): _baseUri = _getBaseUri();

  ResourceUrlResolver.forTests(this._uriMapper, this._config, this._baseUri);

  static final NodeTreeSanitizer _nullTreeSanitizer = new _NullTreeSanitizer();
  static final docForParsing = document.implementation.createHtmlDocument('');

  static String _getBaseUri() {
    if (Uri.base.authority.isEmpty) {
      throw "Relative URL resolution requires a valid base URI";
    } else {
      return "${Uri.base.scheme}://${Uri.base.authority}/";
    }
  }

  static Element _parseHtmlString(String html) {
    var div = docForParsing.createElement('div');
    div.setInnerHtml(html, treeSanitizer: _nullTreeSanitizer);
    return div;
  }

  String resolveHtml(String html, [Uri baseUri]) {
    if (baseUri == null) {
      return html;
    }
    Element elem = _parseHtmlString(html);
    _resolveDom(elem, baseUri);
    return elem.innerHtml;
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
  String combine(Uri baseUri, String path) {
    if (!_config.useRelativeUrls) {
       return path;
    }

    Uri resolved;
    if (path == null) {
      resolved = baseUri;
    } else {
      Uri uri = Uri.parse(path);
      // if it's absolute but not package-relative, then just use that
      // The "packages/" test is just for backward compatibility.  It's ok to
      // not resolve them, even through they're relative URLs, because in a Dart
      // application, "packages/" is managed by pub which creates a symlinked
      // hierarchy and they should all resolve to the same file at any level
      // that a "packages/" exists.
      if (uri.path.startsWith('/') ||
          uri.path.startsWith('packages/') ||
          uri.path.trim() == '' || // Covers both empty strings and # fragments
          uri.isAbsolute) {
        return _uriToPath(uri);
      }
      // Not an absolute uri. Resolve it to the base.
      resolved = baseUri.resolve(path);
    }

    return _uriToPath(resolved);
  }

  String _uriToPath(Uri uri) {
    if (uri.scheme == 'package') {
      return '${_config.packageRoot}${uri.path}';
    } else if (uri.isAbsolute && uri.toString().startsWith(_baseUri)) {
      return uri.path;
    }  else {
      return uri.toString();
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
  static const String DEFAULT_PACKAGE_ROOT = '/packages/';
  bool useRelativeUrls;
  String packageRoot;

  ResourceResolverConfig(): useRelativeUrls = true,
      packageRoot = DEFAULT_PACKAGE_ROOT;

  ResourceResolverConfig.resolveRelativeUrls(this.useRelativeUrls,
      {this.packageRoot: DEFAULT_PACKAGE_ROOT});
}
