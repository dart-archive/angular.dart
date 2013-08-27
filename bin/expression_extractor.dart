library angular.html_expression_extractor;

import 'dart:io';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/io_impl.dart';
import 'package:angular/tools/common.dart';

main() {
  var args = new Options().arguments;
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
  print(htmlExtractor.expressions.join('\n'));
}
