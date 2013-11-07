library angular.html_expression_extractor;

import 'dart:io';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/io_impl.dart';
import 'package:angular/tools/common.dart';

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:angular/core/parser/parser_library.dart';
import 'package:angular/tools/parser_generator/dart_code_gen.dart';
import 'package:angular/tools/parser_generator/generator.dart';

main(args) {
  Module module = new Module()
    ..type(ParserBackend, implementedBy: DartCodeGen);

  Injector injector = new DynamicInjector(modules: [module], allowImplicitInjection: true);

  if (args.length < 3) {
    print('Usage: expression_extractor file_to_scan html_root package_roots+');
    exit(0);
  }
  IoService ioService = new IoServiceImpl();

  var sourceCrawler = new SourceCrawlerImpl(args.sublist(2));
  var sourceMetadataExtractor = new SourceMetadataExtractor(sourceCrawler);
  List<DirectiveInfo> directives =
      sourceMetadataExtractor.gatherDirectiveInfo(args[0]);
  var htmlExtractor = new HtmlExpressionExtractor(directives, ioService);
  htmlExtractor.crawl(args[1]);

  var expressions = htmlExtractor.expressions;
  expressions.add('null');

  print ('// Found ${expressions.length} expressions');

  injector.get(ParserGenerator).generateParser(htmlExtractor.expressions);
}
