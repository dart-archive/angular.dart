library angular_transformers.template_cache_generator;

import 'dart:async';

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/referenced_uris.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:path/path.dart' as path;

/// Transformer which gathers all templates from the Angular application and
/// adds to the Template Cache.
class TemplateCacheGenerator extends Transformer with ResolverTransformer {
  static const String generatedFilename = '_generated_template_cache.dart';

  final TransformOptions options;

  TemplateCacheGenerator(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future applyResolver(Transform transform, Resolver resolver) {
    if (!options.generateTemplateCache) return new Future.value();

    var asset = transform.primaryInput;
    var id = asset.id;
    var outputFilename = '${path.url.basenameWithoutExtension(id.path)}'
        '$generatedFilename';
    var outputPath = path.url.join(path.url.dirname(id.path), outputFilename);
    var outputId = new AssetId(id.package, outputPath);
    var outputBuffer = new StringBuffer();

    return gatherReferencedUris(transform, resolver, options,
            templatesOnly: false).then((templates) {
      _writeTemplateCacheHeader(asset.id, outputBuffer);
      templates.forEach((uri, contents) {
        contents = contents.replaceAll("'''", r"\'\'\'");
        outputBuffer.write("  r'$uri' : r'''\n$contents''',\n");
      });
      _writeTemplateCacheFooter(outputBuffer);
      transform.addOutput(
          new Asset.fromString(outputId, outputBuffer.toString()));
    });
  }

  void _writeTemplateCacheHeader(AssetId id, StringSink sink) {
    var libPath = path.url.withoutExtension(id.path).replaceAll('/', '.');
    sink.write('''
library ${id.package}.$libPath.generated_template_cache;

import 'package:angular/angular.dart';
import 'package:di/di.dart' show Module;

Module get templateCacheModule =>
    new Module()..bind(TemplateCache, toFactory: () {
      var templateCache = new TemplateCache();
      _cache.forEach((key, value) {
        templateCache.put(key, new HttpResponse(200, value));
      });
      return templateCache;
    });

const Map<String, String> _cache = const <String, String> {
''');
  }

  void _writeTemplateCacheFooter(StringSink sink) {
    sink.write('''};
''');
  }
}
