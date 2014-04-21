library angular.tools.transformer.relative_uri_generator;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:angular/tools/transformer/options.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:path/path.dart' as path;


class TypeRelativeUriGenerator extends Transformer with ResolverTransformer {
  final TransformOptions options;

  static const String componentAnnotationName =
      'angular.core.annotation_src.Component';

  TypeRelativeUriGenerator(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  void applyResolver(Transform transform, Resolver resolver) {
    var asset = transform.primaryInput;
    var id = asset.id;
    var outputFilename = '${path.url.basenameWithoutExtension(id.path)}'
        '_type_relative_uris.dart';
    var outputPath = path.url.join(path.url.dirname(id.path), outputFilename);
    var outputId = new AssetId(id.package, outputPath);

    var componentAnnotationType = resolver.getType(componentAnnotationName);
    ConstructorElement componentAnnotation;
    if (componentAnnotationType != null &&
        componentAnnotationType.unnamedConstructor != null) {
      componentAnnotation = componentAnnotationType.unnamedConstructor;
    } else {
      transform.logger.warning('Unable to resolve $componentAnnotationName.');
    }

    var annotatedTypes = resolver.libraries
        .expand((lib) => lib.units)
        .expand((unit) => unit.types)
        .where((type) => type.node != null)
        .expand(_AnnotatedElement.fromElement)
        .where((e) => e.annotation.element == componentAnnotation)
        .map((e) => e.element);

    var outputBuffer = new StringBuffer();
    _writeHeader(asset.id, outputBuffer);

    var libs = annotatedTypes.map((type) => type.library)
        .toSet();

    var importPrefixes = <LibraryElement, String>{};
    var index = 0;
    for (var lib in libs) {
      if (lib.isDartCore) {
        importPrefixes[lib] = '';
        continue;
      }

      var prefix = 'import_${index++}';
      var url = resolver.getImportUri(lib, from: outputId);
      outputBuffer.write('import \'$url\' as $prefix;\n');
      importPrefixes[lib] = '$prefix.';
    }

    _writePreamble(outputBuffer);

    for (var type in annotatedTypes) {
      outputBuffer.write('  ${importPrefixes[type.library]}${type.name}: ');

      var uri = resolver.getImportUri(type.library,
          from: transform.primaryInput.id);

      outputBuffer.write('Uri.parse(\'$uri\'),\n');
    }
    _writeFooter(outputBuffer);

    transform.addOutput(
          new Asset.fromString(outputId, outputBuffer.toString()));
    transform.addOutput(asset);
  }
}

void _writeHeader(AssetId id, StringSink sink) {
  var libPath = path.withoutExtension(id.path).replaceAll('/', '.');
  sink.write('''
library ${id.package}.$libPath.generated_type_uris;

import 'package:angular/core_dom/annotation_uri_resolver.dart';
''');
}

void _writePreamble(StringSink sink) {
  sink.write('''

/// Used when URIs have been converted to be page-relative at build time.
class _StaticAnnotationUriResolver implements AnnotationUriResolver {
  String resolve(String path, Type type) {
    var uri = _uriMapping[type];
    if (uri == null) {
      throw new StateError('Unable to find URI mapping for \$type');
    }
    return AnnotationUriResolver.combine(uri, path);
  }
}

final uriResolver = new _StaticAnnotationUriResolver();

final Map<Type, Uri> _uriMapping = <Type, Uri> {
''');
}

void _writeFooter(StringSink sink) {
  sink.write('''
};
''');
}

/// Wrapper for annotation AST nodes to track the element they were declared on.
class _AnnotatedElement {
  /// The annotation node.
  final Annotation annotation;
  /// The element which the annotation was declared on.
  final Element element;

  _AnnotatedElement(this.annotation, this.element);

  static Iterable<_AnnotatedElement> fromElement(Element element) {
    AnnotatedNode node = element.node;
    return node.metadata.map(
        (annotation) => new _AnnotatedElement(annotation, element));
  }
}
