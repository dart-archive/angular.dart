library angular.core_dom.annotation_uri_resolver_dynamic;

import 'dart:mirrors';
import 'package:path/path.dart' as native_path;
import 'annotation_uri_resolver.dart';
import 'dart:html' as dom;

var path = native_path.url;

/// Resolves type-relative URIs
class DynamicAnnotationUriResolver implements AnnotationUriResolver {
  final dom.AnchorElement _anchor = new dom.AnchorElement();

  String resolve(String uri, Type type) {
    var absolute = _resolveUri(uri, type);
    _anchor.href = '.';
    return path.relative(absolute, from: _anchor.href);
  }
}

/// Generic utility to resolve type-relative URIs.
String _resolveUri(String uri, Type type) {
  var original = Uri.parse(uri);
  // Convert to package: for combination with lib URI
  if (uri.startsWith('/packages/')) {
    uri = 'package:${original.pathSegments.skip(1).join('/')}';
  } else if (path.isAbsolute(uri)) {
    // If it's absolute but not package-relative, then just use that.
    return uri;
  }
  var typeMirror = reflectType(type);
  LibraryMirror lib = typeMirror.owner;

  var parsed = lib.uri.resolve(uri);

  if (parsed.scheme == 'package') {
    return '/packages/${parsed.path}';
  }
  return parsed.toString();
}
