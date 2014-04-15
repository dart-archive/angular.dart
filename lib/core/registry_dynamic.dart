library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';

export 'package:angular/core/registry.dart' show MetadataExtractor;

class DynamicMetadataExtractor implements MetadataExtractor {
  final _fieldAnnotations = <TypeMirror>[
      reflectType(NgAttr),
      reflectType(NgOneWay),
      reflectType(NgOneWayOneTime),
      reflectType(NgTwoWay),
      reflectType(NgCallback)
  ];

  static final _fieldMetadataCache =
      <Type, Map<String, AbstractNgFieldAnnotation>>{};

  Iterable call(Type type) {
    if (reflectType(type) is TypedefMirror) return [];
    var metadata = reflectClass(type).metadata;
    return metadata == null ?
        const [] :
        metadata.map((InstanceMirror im) => _merge(type, im.reflectee));
  }

  /// Merges the attribute annotations with the directive definition.
  dynamic _merge(Type type, annotation) {
    if (annotation is NgTemplate) {
      return _mergeTemplateMapping(type, annotation);
    } else if (annotation is AbstractNgAnnotation) {
      return _mergeDirectiveMap(type, annotation);
    }
    return annotation;
  }

  /**
   * Merges the field annotations with the [AbstractNgAttrAnnotation.map]
   * definition from the directive.
   *
   * [_mergeDirectiveMap] throws when the definition for an annotated is
   * duplicated in the [AbstractNgAttrAnnotation.map]
   */
  AbstractNgAttrAnnotation _mergeDirectiveMap(Type type,
      AbstractNgAttrAnnotation annotation) {
    var match;
    var metadata = _fieldMetadataExtractor(type);
    if (metadata.isNotEmpty) {
      var newMap = annotation.map == null ? {} : new Map.from(annotation.map);
      metadata.forEach((String fieldName, AbstractNgFieldAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
                'processing annotation for field $fieldName of $type)';
        }
        newMap[attrName] = mappingSpec(ann) + fieldName;
      });
      annotation = cloneWithNewMap(annotation, newMap);
    }
    return annotation;
  }

  /**
   * Merges the mapping from both the [NgTemplate] annotation and the one
   * defined at the attribute level.
   *
   * The mapping could only be specified once at one of the 2 places. When
   * defined at both the places [_mergeTemplateMapping] will throw.
   */
  NgTemplate _mergeTemplateMapping(Type type, NgTemplate annotation) {
    var match;
    var metadata = _fieldMetadataExtractor(type);
    if (metadata.length > 1) {
      throw 'There could be only one attribute annotation for @NgTemplate '
            'annotated classes, ${metadata.length} found on '
            '${metadata.keys.join(", ")}';
    }
    if (metadata.length == 1) {
      if (annotation.mapping != null) {
        throw 'The mapping must be defined either in the @NgTemplate annotation'
              ' or on an attribute';
      }
      var mapping = mappingSpec(metadata.values[0]) + metadata.keys[0];
      annotation = cloneWithNewMapping(annotation, mapping);
    }
    return annotation;
  }

  /// Extract metadata defined on fields via an [AbstractNgFieldAnnotation]
  Map<String, AbstractNgFieldAnnotation> _fieldMetadataExtractor(Type type) {
    if (!_fieldMetadataCache.containsKey(type)) {
      ClassMirror cm = reflectType(type);
      final fields = <String, AbstractNgFieldAnnotation>{};
      cm.declarations.forEach((Symbol name, DeclarationMirror decl) {
        if (decl is VariableMirror ||
            decl is MethodMirror && (decl.isGetter || decl.isSetter)) {
          var fieldName = MirrorSystem.getName(name);
          if (decl is MethodMirror && decl.isSetter) {
            // Remove "=" from the end of the setter.
            fieldName = fieldName.substring(0, fieldName.length - 1);
          }
          decl.metadata.forEach((InstanceMirror meta) {
            if (_fieldAnnotations.contains(meta.type)) {
              if (fields.containsKey(fieldName)) {
                throw 'Attribute annotation for $fieldName is defined more '
                      'than once in $type';
              }
              fields[fieldName] = meta.reflectee as AbstractNgFieldAnnotation;
            }
          });
        }
      });
      _fieldMetadataCache[type] = fields;
    }
    return _fieldMetadataCache[type];
  }
}
