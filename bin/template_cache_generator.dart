import 'package:analyzer/src/generated/ast.dart';
import 'package:angular/tools/source_crawler_impl.dart';

import 'dart:io';
import 'dart:async';
import 'dart:collection';

const String PACKAGE_PREFIX = 'package:';
const String DART_PACKAGE_PREFIX = 'dart:';

String fileHeader(String library) => '''// GENERATED, DO NOT EDIT!
library ${library};

import 'package:third_party/dart/angular/lib/angular.dart';

primeTemplateCache(TemplateCache tc) {
''';

const String FILE_FOOTER = '}';

main(args) {
  if (args.length < 4) {
    print('Usage: templace_cache_generator path_to_entry_point output '
        'package_root1,package_root2,... '
        'patternUrl1,rewriteTo1;patternUrl2,rewriteTo2 '
        'blacklistClass1,blacklistClass2');
    exit(1);
  }

  var entryPoint = args[0];
  var output = args[1];
  var outputLibrary = args[2];
  var packageRoots = args[3].split(',');
  Map<RegExp, String> urlRewriters = parseUrlRemapping(args[4]);
  Set<String> blacklistedClassAnnotations = (args.length > 5)
      ? new Set.from(args[5].split(','))
      : new Set();

  print('entryPoint: $entryPoint');
  print('output: $output');
  print('outputLibrary: $outputLibrary');
  print('packageRoots: $packageRoots');
  print('url rewritters: ' + args[4]);
  print('blacklistedClassAnnotations: '
      + blacklistedClassAnnotations.join(', '));


  Map<String, String> templates = {};

  var c = new SourceCrawlerImpl(packageRoots);
  var visitor =
      new TemplateCollectingVisitor(templates, blacklistedClassAnnotations, c);
  c.crawl(entryPoint, (CompilationUnit compilationUnit) =>
      visitor(compilationUnit));

  printTemplateCache(
      templates, urlRewriters, outputLibrary, new File(output).openWrite());
}

Map<RegExp, String> parseUrlRemapping(String argument) {
  Map<RegExp, String> result = new LinkedHashMap();
  argument.split(";").forEach((String pair) {
    List<String> remapping = pair.split(",");
    result[new RegExp(remapping[0])] = remapping[1];
  });
  return result;
}

void printTemplateCache(Map<String, String> templateKeyMap,
                        Map<RegExp, String> urlRewriters,
                        String outputLibrary,
                        IOSink outSink) {

  outSink.write(fileHeader(outputLibrary));

  List<Future> reads = <Future>[];
  templateKeyMap.keys.forEach((uri) {
    String templateFile = templateKeyMap[uri];
    reads.add(new File(templateFile).readAsString().then((fileStr) {
      // TODO(pavelj): implement template HTML minification.
      // Escape block quotes so that value can be wrapped in a
      // multiline dart string.
      fileStr = fileStr.replaceAll('"""', r'\"\"\"');
      String resultUri = uri;
      urlRewriters.forEach((regexp, replacement) {
        resultUri = resultUri.replaceFirst(regexp, replacement);
      });
      outSink.write(
          'tc.put("$resultUri", new HttpResponse(200, r"""$fileStr"""));\n');
    }));
  });

  // Wait until all templates files are processed.
  Future.wait(reads).then((_) {
    outSink.write(FILE_FOOTER);
  });
}

class TemplateCollectingVisitor {
  Map<String, String> templates;
  Set<String> blacklistedClasses;
  SourceCrawlerImpl sourceCrawlerImpl;

  TemplateCollectingVisitor(this.templates, this.blacklistedClasses,
      this.sourceCrawlerImpl);

  call(CompilationUnit cu) {
    cu.declarations.forEach((CompilationUnitMember declaration) {
      // We only care about classes.
      if (declaration is! ClassDeclaration) return;
      ClassDeclaration clazz = declaration;
      List<String> cacheUris = [];
      bool cache = true;
      clazz.metadata.forEach((Annotation ann) {
        if (ann.arguments == null) return; // Ignore non-class annotations.
        // TODO(tsander): Add library name as class name could conflict.
        if (blacklistedClasses.contains(clazz.name.name)) return;

        // TODO(pavelj): this is not a safe check for the type of the
        // annotations, but good enough for now.
        if ((ann.name.name == 'NgComponent')){
          ann.arguments.arguments.forEach((Expression arg) {
            if (arg is NamedExpression) {
              NamedExpression namedArg = arg;
              var paramName = namedArg.name.label.name;
              if (paramName == 'templateUrl' || paramName == 'cssUrl') {
                cacheUris.add(assertString(namedArg.expression).stringValue);
              }
            }
          });
          return;
        }

        if ((ann.name.name == 'NgTemplateCache')){
          ann.arguments.arguments.forEach((Expression arg) {
            if (arg is NamedExpression) {
              NamedExpression namedArg = arg;
              var paramName = namedArg.name.label.name;
              if (paramName == 'preCacheUrls') {
                assertList(namedArg.expression).elements
                    .forEach((expression) =>
                        cacheUris.add(assertString(expression).stringValue));
              }
              if (paramName == 'cache') {
                cache = assertBoolean(namedArg.expression).value;
              }
            }
          });
          return;
        }
      });
      if (cache && cacheUris.isNotEmpty) {
        cacheUris.forEach((uri) => storeUriAsset(uri));
      }
    });
  }

  void storeUriAsset(String uri) {
    String assetFileLocation = sourceCrawlerImpl.resolvePackagePath(uri);
    if (assetFileLocation == null) {
      print("Could not find asset for uri: $uri");
    } else {
      templates[uri] = assetFileLocation;
    }
  }

  BooleanLiteral assertBoolean(Expression key) {
    if (key is! BooleanLiteral) {
        throw 'must be a boolean literal: ${key.runtimeType}';
    }
    return key;
  }

  ListLiteral assertList(Expression key) {
    if (key is! ListLiteral) {
        throw 'must be a list literal: ${key.runtimeType}';
    }
    return key;
  }

  StringLiteral assertString(Expression key) {
    if (key is! StringLiteral) {
        throw 'must be a string literal: ${key.runtimeType}';
    }
    return key;
  }
}