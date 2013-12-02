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
import 'package:angular/core/parser/parser_library.dart';
import 'package:angular/tools/parser_generator/dart_code_gen.dart';
import 'package:angular/tools/parser_generator/generator.dart';

main(args) {
  if (args.length < 6) {
    print('Usage: expression_extractor file_to_scan html_root header_file '
          'footer_file output package_roots+');
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

  var headerFile = args[2];
  var footerFile = args[3];
  var outputFile = args[4];
  SourcePrinter _prt;
  if (outputFile == '--') {
    _prt = new SourcePrinter();
  } else {
    _prt = new FileSourcePrinter(outputFile);
  }

  // Output the header file first.
  if (headerFile != '') {
    _prt.printSrc(_readFile(headerFile));
  }

  _prt.printSrc('// Found ${expressions.length} expressions');
  Module module = new Module()
    ..type(ParserBackend, implementedBy: DartCodeGen)
    ..value(SourcePrinter, _prt);
  Injector injector =
      new DynamicInjector(modules: [module], allowImplicitInjection: true);

  // Run the generator.
  injector.get(ParserGenerator).generateParser(htmlExtractor.expressions);

  // Output footer last.
  if (footerFile != '') {
    _prt.printSrc(_readFile(footerFile));
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
