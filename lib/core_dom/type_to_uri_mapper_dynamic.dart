library angular.core_dom.type_to_uri_mapper_dynamic;

import 'dart:html' as dom;
import 'dart:mirrors';

import 'type_to_uri_mapper.dart';

/// Resolves type-relative URIs
class DynamicTypeToUriMapper extends TypeToUriMapper {
  Uri uriForType(Type type) {
    var typeMirror = reflectType(type);
    LibraryMirror lib = typeMirror.owner;
    // LibraryMirror should produce absolute URIs but due to bug:
    // http://dartbug.com/22249 dart2js produces relative URIs. Change to an
    // absolute path.
    // TODO(tsander): Remove this code when bug is fixed.
    if (!lib.uri.isAbsolute && !lib.uri.path.startsWith('/')) {
      return Uri.parse('/${lib.uri.path}');
    }
    return lib.uri;
  }
}
