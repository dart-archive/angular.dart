library angular.core_dom.annotation_uri_resolver_dynamic;

import 'dart:html' as dom;
import 'dart:mirrors';

import 'annotation_uri_resolver.dart';

/// Resolves type-relative URIs
class DynamicAnnotationUriResolver implements AnnotationUriResolver {

  String resolve(String uri, Type type) {
    var typeMirror = reflectType(type);
    LibraryMirror lib = typeMirror.owner;
    return AnnotationUriResolver.combine(lib.uri, uri);
  }
}
