library angular.core_dom.type_to_uri_mapper_dynamic;

import 'dart:html' as dom;
import 'dart:mirrors';
import 'package:di/annotations.dart';

import 'type_to_uri_mapper.dart';

/// Resolves type-relative URIs
@Injectable()
class DynamicTypeToUriMapper extends TypeToUriMapper {
  Uri uriForType(Type type) {
    var typeMirror = reflectType(type);
    LibraryMirror lib = typeMirror.owner;
    return lib.uri;
  }
}
