library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';

export 'package:angular/core/registry.dart' show
    MetadataExtractor;

class DynamicMetadataExtractor implements MetadataExtractor {
  static final _fieldMetadataCache = <Type, Map<String, DirectiveAnnotation>>{};

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
    return metadata == null ?
        [] : metadata.map((InstanceMirror im) => _mergeFieldAnnotations(type, im.reflectee));
  }

  /**
   * Merges the field annotations with the [AbstractNgAttrAnnotation.map] definition from the
   * directive.
   *
   * [_mergeFieldAnnotations] throws when a field annotation has already been defined via
   * [Directive.map]
   */
  dynamic _mergeFieldAnnotations(Type type, annotation) {
    if (annotation is! Directive) return annotation;
    var match;
    var fieldMetadata = _fieldMetadataExtractor(type);
    if (fieldMetadata.isNotEmpty) {
      var newMap = annotation.map == null ? {} : new Map.from(annotation.map);
      fieldMetadata.forEach((String fieldName, DirectiveAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
                'processing annottation for field $fieldName of $type)';
        }
        newMap[attrName] = mappingSpec(ann) + fieldName;
      });
      annotation = cloneWithNewMap(annotation, newMap);
    }
    return annotation;
  }

  /// Extract metadata defined on fields via a [DirectiveAnnotation]
  Map<String, DirectiveAnnotation> _fieldMetadataExtractor(Type type) {
    if (!_fieldMetadataCache.containsKey(type)) {
      var fields = <String, DirectiveAnnotation>{};
      ClassMirror cm = reflectType(type);
      if (cm.superclass != null) {
        fields.addAll(_fieldMetadataExtractor(cm.superclass.reflectedType));
      }
      Map<Symbol, DeclarationMirror> declarations = cm.declarations;
      declarations.forEach((symbol, dm) {
        if (dm is VariableMirror ||
        dm is MethodMirror && (dm.isGetter || dm.isSetter)) {
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
      _fieldMetadataCache[type] = fields;
    }
    return _fieldMetadataCache[type];
  }
}
