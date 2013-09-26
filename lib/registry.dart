library angular.registry;

import 'dart:mirrors';
import 'package:di/di.dart';

abstract class AnnotationMap<K> {
  final Map<K, Type> _map = {};

  AnnotationMap(Injector injector) {
    injector.types.forEach((type) {
      var meta = reflectClass(type).metadata;
      if (meta == null) return;
      meta
        .map((InstanceMirror im) => im.reflectee)
        .where((annotation) => annotation is K)
        .forEach((annotation) {
          if (_map.containsKey(annotation)) {
            var annotationType = K;
            throw "Duplicate annotation found: $annotationType: $annotation. " +
                  "Exisitng: ${_map[annotation]}; New: $type.";
          }
          _map[annotation] = type;
        });
    });
  }

  Type operator[](K annotation) => _map[annotation];

  forEach(fn(K, Type)) => _map.forEach(fn);
}
