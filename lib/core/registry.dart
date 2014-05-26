library angular.core.registry;

import 'package:di/di.dart' show Injector;

/**
 * The [AnnotationMap] maps annotations to [Type]s.
 *
 * The [AnnotationMap] contains all annotated [Type]s provided by the [Injector] passed as a
 * constructor argument. Every single annotation maps to only one [Type].
 */
abstract class AnnotationMap<K> {
  final _map = <K, Type>{};

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
  final _map = <K, List<Type>>{};

  AnnotationsMap(Injector injector, MetadataExtractor extractMetadata) {
    injector.types.forEach((type) {
      extractMetadata(type)
          .where((annotation) => annotation is K)
          .forEach((annotation) {
            _map.putIfAbsent(annotation, () => <Type>[]).add(type);
          });
    });
  }

  /// Returns a list of [Type]s annotated with [annotation].
  List<Type> operator[](K annotation) {
    var value = _map[annotation];
    if (value == null) throw 'No $annotation found!';
    return value;
  }

  /// Executes the [function] for all registered (annotation, type) pairs.
  void forEach(function(K, Type)) {
    _map.forEach((K annotation, List<Type> types) {
      types.forEach((type) {
        function(annotation, type);
      });
    });
  }

  /// Returns a list of all the annotations applied to the [Type].
  List<K> annotationsFor(Type type) {
    var res = <K>[];
    _map.forEach((K annotation, List<Type> types) {
      if (types.contains(type)) res.add(annotation);
    });
    return res;
  }
}

abstract class MetadataExtractor {
  Iterable call(Type type);
}
