library angular.core_static;

import 'package:angular/angular.dart';
import 'package:angular/core/module.dart';

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
