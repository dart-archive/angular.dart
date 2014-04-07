library angular.core_static;

import 'package:angular/core/annotation.dart';
import 'package:angular/core/registry.dart';

@NgInjectableService()
class StaticMetadataExtractor extends MetadataExtractor {
  final Map<Type, Iterable> metadataMap;
  final List empty = const [];

  StaticMetadataExtractor(this.metadataMap);

  Iterable call(Type type) {
    Iterable i = metadataMap[type];
    return i == null ? empty : i;
  }
}
