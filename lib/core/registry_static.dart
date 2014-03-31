library angular.core_static;

import 'package:angular/core/module_internal.dart';

@NgInjectableService()
class StaticMetadataExtractor extends MetadataExtractor {
  Map<Type, Iterable> metadataMap;
  final List empty = const [];

  StaticMetadataExtractor(this.metadataMap);

  Iterable call(Type type) {
    Iterable i = metadataMap[type];
    return i == null ? empty : i;
  }
}
