library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/module.dart';

@NgInjectableService()
class DynamicMetadataExtractor implements MetadataExtractor {
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
      metadata =  metadata.map((InstanceMirror im) => map(type, im.reflectee));
    }
    return metadata;
  }

  map(Type type, obj) {
    if (obj is NgAnnotation) {
      return mapDirectiveAnnotation(type, obj);
    } else {
      return obj;
    }
  }

  NgAnnotation mapDirectiveAnnotation(Type type, NgAnnotation annotation) {
    var match;
    var fieldMetadata = fieldMetadataExtractor(type);
    if (fieldMetadata.isNotEmpty) {
      var newMap = annotation.map == null ? {} : new Map.from(annotation.map);
      fieldMetadata.forEach((String fieldName, AttrFieldAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
          'processing annottation for field $fieldName of $type)';
        }
        newMap[attrName] = '${ann.mappingSpec}$fieldName';
      });
      annotation = annotation.cloneWithNewMap(newMap);
    }
    return annotation;
  }


  Map<String, AttrFieldAnnotation> fieldMetadataExtractor(Type type) {
    ClassMirror cm = reflectType(type);
    final fields = <String, AttrFieldAnnotation>{};
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
            fields[fieldName] = meta.reflectee as AttrFieldAnnotation;
          }
        });
      }
    });
    return fields;
  }
}
