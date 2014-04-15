library angular.core.registry;

import 'package:di/di.dart' show Injector;

/**
 * The [AnnotationMap] maps annotations to [Type]s.
 *
 * The [AnnotationMap] contains all annotated [Type]s provided by the [Injector]
 * given in the constructor argument. Every single annotation maps to only one
 * [Type].
 */
abstract class AnnotationMap<K> {
  final Map<K, Type> _map = {};

  AnnotationMap(Injector injector, MetadataExtractor extractMetadata) {
    injector.types.forEach((type) {
      extractMetadata(type)
          .where((annotation) => annotation is K)
          .forEach((annotation) {
            _map[annotation] = type;
          });
    });
  }

  /// Returns the [Type] annotated with [annotation].
  Type operator[](K annotation) {
    var value = _map[annotation];
    if (value == null) throw 'No $annotation found!';
    return value;
  }

  /// Executes the [function] for all registered annotations.
  void forEach(function(K, Type)) {
    _map.forEach(function);
  }

  /// Returns a list of all the annotations applied to the [Type].
  List<K> annotationsFor(Type type) {
    final res = <K>[];
    forEach((ann, annType) {
      if (annType == type) res.add(ann);
    });
    return res;
  }
}

/**
 * The [AnnotationsMap] maps annotations to [Type]s.
 *
 * The [AnnotationsMap] contains all annotated [Type]s provided by the [Injector]
 * given in the constructor argument. Every single annotation can maps to only
 * multiple [Type]s.
 */
abstract class AnnotationsMap<K> {
  final map = <K, List<Type>>{};

  AnnotationsMap(Injector injector, MetadataExtractor extractMetadata) {
    injector.types.forEach((type) {
      extractMetadata(type)
          .where((annotation) => annotation is K)
          .forEach((annotation) {
            map.putIfAbsent(annotation, () => <Type>[]).add(type);
          });
    });
  }

  /// Returns a list of [Type]s annotated with [annotation].
  List<Type> operator[](K annotation) {
    var value = map[annotation];
    if (value == null) throw 'No $annotation found!';
    return value;
  }

  /// Executes the [function] for all registered (annotation, type) pairs.
  void forEach(function(K, Type)) {
    map.forEach((K annotation, List<Type> types) {
      types.forEach((Type type) {
        function(annotation, type);
      });
    });
  }

  /// Returns a list of all the annotations applied to the [Type].
  List<K> annotationsFor(Type type) {
    var res = <K>[];
    map.forEach((K ann, List<Type> types) {
      if (types.contains(type)) res.add(ann);
    });
    return res;
  }
}

abstract class MetadataExtractor {
  Iterable call(Type type);
}
