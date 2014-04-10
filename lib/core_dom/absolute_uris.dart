library angular.core_dom.relative_uris;

import 'dart:html';
import 'dart:js' as js;

/// Dart port of
/// https://github.com/Polymer/platform-dev/blob/896e245a0046a397bfc0190d958d2bd162e8f53c/src/url.js
///
/// This converts URIs within a document from relative URIs to being absolute
/// URIs.
class AbsoluteUris {
  /// Resolves all relative URIs within the DOM from being relative to
  /// [originalBase] to being rabsolute.
  static void resolveDom(Node root, [Uri originalBase]) {
    if (originalBase == null) {
      // Use baseUrl when dartbug.com/18196 is fixed.
      originalBase = Uri.parse(
          new js.JsObject.fromBrowserObject(root.ownerDocument)['baseURI']);
    }

    _resolveAttributes(root, originalBase);
    _resolveStyles(root, originalBase);

    // handle template.content
    for (var template in _querySelectorAll(root, 'template')) {
      if (template.content != null) {
        resolveDom(template.content, originalBase);
      }
    }
  }

  static Iterable<Element> _querySelectorAll(Node node, String selectors) {
    if (node is DocumentFragment) {
      return node.querySelectorAll(selectors);
    }
    if (node is Element) {
      return node.querySelectorAll(selectors);
    }
    return const [];
  }

  static void _resolveStyles(Node node, Uri originalBase) {
    var styles = _querySelectorAll(node, 'style');
    for (var style in styles) {
      _resolveStyle(style, originalBase);
    }
  }

  static void _resolveStyle(StyleElement style, Uri originalBase) {
    style.text = resolveCssText(style.text, originalBase);
  }

  static String resolveCssText(String cssText, Uri originalBase) {
    cssText = _replaceUrlsInCssText(cssText, originalBase, _cssUrlRegexp);
    return _replaceUrlsInCssText(cssText, originalBase, _cssImportRegexp);
  }

  static void _resolveAttributes(Node root, Uri originalBase) {
    if (root is Element) {
      _resolveElementAttributes(root, originalBase);
    }

    for (var node in _querySelectorAll(root, _urlAttrsSelector)) {
      _resolveElementAttributes(node, originalBase);
    }
  }

  static void _resolveElementAttributes(Element element, Uri originalBase) {
    var attrs = element.attributes;
    for (var attr in _urlAttrs) {
      if (attrs.containsKey(attr)) {
        var value = attrs[attr];
        if (!value.contains(_urlTemplateSearch)) {
          attrs[attr] = originalBase.resolve(value).toString();
        }
      }
    }
  }

  static final RegExp _cssUrlRegexp = new RegExp(r'(url\()([^)]*)(\))');
  static final RegExp _cssImportRegexp = new RegExp(r'(@import[\s]+(?!url\())([^;]*)(;)');
  static const List<String> _urlAttrs = const ['href', 'src', 'action'];
  static final String _urlAttrsSelector = '[${_urlAttrs.join('],[')}]';
  static final RegExp _urlTemplateSearch = new RegExp('{{.*}}');
  static final RegExp _quotes = new RegExp('["\']');

  static String _replaceUrlsInCssText(String cssText, Uri originalBase, RegExp regexp) {
    return cssText.replaceAllMapped(regexp, (match) {
      var url = match[2];
      url = url.replaceAll(_quotes, '');
      var urlPath = originalBase.resolve(url).toString();
      return '${match[1]}\'$urlPath\'${match[3]}';
    });
  }
}
