library angular.registry;

import 'dart:mirrors';
import 'package:di/di.dart';

abstract class AnnotationMap<K> {
  final Map<K, Type> _map = {};

  AnnotationMap(Type annotationType, Injector injector) {
    injector.types.forEach((type) {
      var meta = reflectClass(type).metadata;
      if (meta == null) return;
      meta
        .map((InstanceMirror im) => im.reflectee)
        .where(where)
        .forEach((annotation) {
          if (_map.containsKey(annotation)) {
            throw "Duplicate annotation found: $annotationType: $annotation. " +
                  "Exisitng: ${_map[annotation]}; New: $type.";
          }
          _map[annotation] = type;
        });
    });
  }

  where(annotation);

  Type operator[](K annotation) => _map[annotation];

  forEach(fn(K, Type)) => _map.forEach(fn);
}
