library angular.core_dom.annotation_uri_resolver;

import 'package:angular/angular.dart';

/// Utility to convert type-relative URIs to be page-relative.
abstract class AnnotationUriResolver {
  String resolve(String uri, Type type);
}

/// Used when URIs have been converted to be page-relative at build time.
@NgInjectableService()
class StaticAnnotationUriResolver implements AnnotationUriResolver {
  String resolve(String path, Type type) => path;
}
