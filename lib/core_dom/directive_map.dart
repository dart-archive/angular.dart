part of angular.core.dom;

@NgInjectableService()
class DirectiveMap extends AnnotationsMap<NgAnnotation> {
  DirectiveSelector selector;

  DirectiveMap(Injector injector, MetadataExtractor metadataExtractor,
      FieldMetadataExtractor fieldMetadataExtractor)
      : super(injector, metadataExtractor) {
    Map<NgAnnotation, List<Type>> directives = {};
    forEach((NgAnnotation annotation, Type type) {
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
      directives.putIfAbsent(annotation, () => []).add(type);
    });
    map.clear();
    map.addAll(directives);

    selector = directiveSelectorFactory(this);
  }
}

@NgInjectableService()
class FieldMetadataExtractor {
  List<TypeMirror> _fieldAnnotations = [reflectType(NgAttr),
      reflectType(NgOneWay), reflectType(NgOneWayOneTime),
      reflectType(NgTwoWay), reflectType(NgCallback)];

  Map<String, AttrFieldAnnotation> call(Type type) {
    ClassMirror cm = reflectType(type);
    Map<String, AttrFieldAnnotation> fields = <String, AttrFieldAnnotation>{};
    cm.declarations.forEach((Symbol name, DeclarationMirror decl) {
      if (decl is VariableMirror ||
          (decl is MethodMirror && (decl.isGetter || decl.isSetter))) {
        var fieldName = MirrorSystem.getName(name);
        if (decl is MethodMirror && decl.isSetter) {
          // Remove = from the end of the setter.
          fieldName = fieldName.substring(0, fieldName.length - 1);
        }
        decl.metadata.forEach((InstanceMirror meta) {
          if (_fieldAnnotations.contains(meta.type)) {
            if (fields[fieldName] != null) {
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
