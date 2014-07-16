library angular.core_dom.annotation_uri_resolver;

import 'package:path/path.dart' as native_path;

final _path = native_path.url;

/// Utility to convert type-relative URIs to be page-relative.
abstract class AnnotationUriResolver {
  String resolve(String uri, Type type);

  /// Combines a type-based URI with a relative URI.
  ///
  /// [typeUri] is assumed to use package: syntax for package-relative
  /// URIs, while [uri] is assumed to use 'packages/' syntax for
  /// package-relative URIs. Resulting URIs will use 'packages/' to indicate
  /// package-relative URIs.
  static String combine(Uri typeUri, String uri) {
    var original = Uri.parse(uri);
    // Convert to package: for combination with lib URI
    if (uri.startsWith(new RegExp(r'[/]packages/'))) {
      uri = 'package:${original.pathSegments.skip(1).join('/')}';
    } else if (_path.isAbsolute(uri)) {
      // If it's absolute but not package-relative, then just use that.
      return uri;
    }

    var parsed = typeUri.resolve(uri);

    if (parsed.scheme == 'package') {
      return 'packages/${parsed.path}';
    }
    if (parsed.isAbsolute) {
      var path = Uri.base.path;
      if (!path.endsWith('/')) {
        var parts = Uri.base.pathSegments.toList();
        parts.removeLast();
        path = parts.join('/');
      }

      return _path.relative(parsed.toString(),
          from: '${Uri.base.origin}/$path');
    }
    return parsed.toString();
  }
}
