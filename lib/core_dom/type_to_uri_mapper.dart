library angular.core_dom.type_to_uri_mapper;

import 'package:path/path.dart' as native_path;

final _path = native_path.url;

/// Utility to convert type-relative URIs to be page-relative.
abstract class TypeToUriMapper {

  TypeToUriMapper();

  static final RegExp _libraryRegExp = new RegExp(r'/packages/');

  // to be rewritten for dynamic and static cases
  Uri uriForType(Type type);
}
