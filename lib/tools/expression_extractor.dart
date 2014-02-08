library angular.tools.html_expression_extractor;

import 'dart:io';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/io_impl.dart';
import 'package:angular/tools/common.dart';

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/tools/parser_generator/generator.dart';

main(args) {
  if (args.length < 5) {
    print('Usage: expression_extractor file_to_scan html_root header_file '
          'footer_file output [package_roots+]');
    exit(0);
  }
  IoService ioService = new IoServiceImpl();

  var packageRoots =
      (args.length < 6) ? [Platform.packageRoot] : args.sublist(5);
  var sourceCrawler = new SourceCrawlerImpl(packageRoots);
  var sourceMetadataExtractor = new SourceMetadataExtractor(sourceCrawler);
  List<DirectiveInfo> directives =
      sourceMetadataExtractor.gatherDirectiveInfo(args[0]);
  var htmlExtractor = new HtmlExpressionExtractor(directives, ioService);
  htmlExtractor.crawl(args[1]);

  var expressions = htmlExtractor.expressions;
  expressions.add('null');

  var headerFile = args[2];
  var footerFile = args[3];
  var outputFile = args[4];
  SourcePrinter printer;
  if (outputFile == '--') {
    printer = new SourcePrinter();
  } else {
    printer = new FileSourcePrinter(outputFile);
  }

  // Output the header file first.
  if (headerFile != '') {
    printer.printSrc(_readFile(headerFile));
  }

  printer.printSrc('// Found ${expressions.length} expressions');
  Module module = new Module()
      ..type(Parser, implementedBy: DynamicParser)
      ..type(ParserBackend, implementedBy: DynamicParserBackend)
      ..type(FilterMap, implementedBy: NullFilterMap)
      ..value(SourcePrinter, printer);
  Injector injector =
      new DynamicInjector(modules: [module], allowImplicitInjection: true);

  // Run the generator.
  injector.get(ParserGenerator).generateParser(htmlExtractor.expressions);

  // Output footer last.
  if (footerFile != '') {
    printer.printSrc(_readFile(footerFile));
  }
}

String _readFile(String filePath) => new File(filePath).readAsStringSync();

class FileSourcePrinter implements SourcePrinter {
  final File _file;

  FileSourcePrinter(String filePath)
      : _file = new File(filePath) {
    // clear file
    _file.writeAsStringSync('');
  }

  printSrc(src) => _file.writeAsStringSync('$src\n', mode: FileMode.APPEND);
}
