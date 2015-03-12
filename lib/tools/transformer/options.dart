library angular.tools.transformer.options;

import 'package:di/transformer.dart' as di show TransformOptions;

/** Options used by Angular transformers */
class TransformOptions {

  /**
   * List of html file paths which may contain Angular expressions.
   * The paths are relative to the package home and are represented using posix
   * style, which matches the representation used in asset ids in barback.
   */
  final List<String> htmlFiles;

  /**
   * Path to the Dart SDK directory, for resolving Dart libraries.
   */
  final String sdkDirectory;

  /**
   * Template cache path modifiers
   */
  final Map<String, String> templateUriRewrites;

  /**
   * Dependency injection options.
   */
  final di.TransformOptions diOptions;

  /// Option to generate the template cache.
  final bool generateTemplateCache;

  TransformOptions({String sdkDirectory, List<String> htmlFiles,
      Map<String, String> templateUriRewrites,
      di.TransformOptions diOptions, bool generateTemplateCache}) :
      sdkDirectory = sdkDirectory,
      htmlFiles = htmlFiles != null ? htmlFiles : [],
      templateUriRewrites = templateUriRewrites != null ?
          templateUriRewrites : {},
      diOptions = diOptions,
      generateTemplateCache = generateTemplateCache != null ?
          generateTemplateCache : false {
    if (sdkDirectory == null)
      throw new ArgumentError('sdkDirectory must be provided.');
  }
}
