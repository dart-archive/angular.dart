library ng.tool.expression_extractor_spec;

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:angular/tools/common.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/io_impl.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import '../jasmine_syntax.dart';
import 'package:unittest/unittest.dart';

main() => describe('expression_extractor', () {
  it('should extract all expressions from source and templates', () {
    Module module = new Module();

    Injector injector = new DynamicInjector(modules: [module],
        allowImplicitInjection: true);

    IoService ioService = new IoServiceImpl();
    var sourceCrawler = new SourceCrawlerImpl(['packages/']);
    var sourceMetadataExtractor = new SourceMetadataExtractor();
    List<DirectiveInfo> directives =
        sourceMetadataExtractor
            .gatherDirectiveInfo('test/io/test_files/main.dart', sourceCrawler);
    var htmlExtractor = new HtmlExpressionExtractor(directives);
    htmlExtractor.crawl('test/io/test_files/', ioService);

    var expressions = htmlExtractor.expressions;
    expect(expressions, unorderedEquals([
      'ctrl.expr',
      'ctrl.anotherExpression',
      'ctrl.callback',
      'ctrl.twoWayStuff',
      'attr',
      'expr',
      'anotherExpression',
      'callback',
      'twoWayStuff',
      'exported + expression',
      'ctrl.inline.template.expression',
      'ngIfCondition',
      'ctrl.if'
    ]));
  });
});
