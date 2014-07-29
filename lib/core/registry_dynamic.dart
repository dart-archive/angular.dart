library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';
import 'dart:collection';

export 'package:angular/core/registry.dart' show
    MetadataExtractor;

class DynamicMetadataExtractor implements MetadataExtractor {
  static final _fieldMetadataCache = new HashMap<Type, Map<String, DirectiveAnnotation>>();

  final _fieldAnnotations = [
        reflectType(NgAttr),
        reflectType(NgOneWay),
        reflectType(NgOneWayOneTime),
        reflectType(NgTwoWay),
        reflectType(NgCallback)
  ];

  Iterable call(Type type) {
    if (reflectType(type) is TypedefMirror) return [];
    var metadata = reflectClass(type).metadata;
    if (metadata == null) {
      metadata = [];
    } else {
      metadata =  metadata.map((InstanceMirror im) => _mergeAnnotations(type, im.reflectee));
    }
    return metadata;
  }

  /// Merges the field annotations with the [Directive.map] definitions
  dynamic _mergeAnnotations(Type type, annotation) {
    if (annotation is! Directive) return annotation;
    var match;
    var fieldMetadata = _extractFieldMetadata(type);
    if (fieldMetadata.isNotEmpty) {
      var newMap = annotation.map == null ? new HashMap() : new HashMap.from(annotation.map);
      fieldMetadata.forEach((String fieldName, DirectiveAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
                'processing annotation for field $fieldName of $type)';
        }
        newMap[attrName] = '${mappingSpec(ann)}$fieldName';
      });
      annotation = cloneWithNewMap(annotation, newMap);
    }
    return annotation;
  }

  Map<String, DirectiveAnnotation> _extractFieldMetadata(Type type) =>
      _fieldMetadataCache.putIfAbsent(type, () => _fieldMetadataExtractor(reflectType(type)));

  /// Extract [DirectiveAnnotation] field metadata
  Map<String, DirectiveAnnotation> _fieldMetadataExtractor(ClassMirror cm) {
    var fields = new HashMap<String, DirectiveAnnotation>();
    if(cm.superclass != null) fields.addAll(_fieldMetadataExtractor(cm.superclass));

    Map<Symbol, DeclarationMirror> declarations = cm.declarations;
    declarations.forEach((symbol, dm) {
      if(dm is VariableMirror || dm is MethodMirror && (dm.isGetter || dm.isSetter)) {
        var fieldName = MirrorSystem.getName(symbol);
        if (dm is MethodMirror && dm.isSetter) {
          // Remove "=" from the end of the setter.
          fieldName = fieldName.substring(0, fieldName.length - 1);
        }
        dm.metadata.forEach((InstanceMirror meta) {
          if (_fieldAnnotations.contains(meta.type)) {
            if (fields.containsKey(fieldName)) {
              throw 'Attribute annotation for $fieldName is defined more '
                'than once in ${cm.reflectedType}';
            }
            fields[fieldName] = meta.reflectee as DirectiveAnnotation;
          }
        });
      }
    });
    return fields;
  }
}
