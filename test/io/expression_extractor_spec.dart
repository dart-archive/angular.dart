library ng.tool.expression_extractor_spec;

import 'package:di/di.dart';
import 'package:angular/tools/common.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/io_impl.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/source_metadata_extractor.dart';

import 'package:test/test.dart' hide expect;
import 'package:guinness2/guinness2.dart';

void main() {
  describe('expression_extractor', () {

    Iterable<String> _extractExpressions(file) {
      Module module = new Module();
      Injector injector = new ModuleInjector([module]);

      IoService ioService = new IoServiceImpl();
      var sourceCrawler = new SourceCrawlerImpl(['packages/']);
      var sourceMetadataExtractor = new SourceMetadataExtractor();
      List<DirectiveInfo> directives =
          sourceMetadataExtractor.gatherDirectiveInfo(file, sourceCrawler);
      var htmlExtractor = new HtmlExpressionExtractor(directives);
      htmlExtractor.crawl('test/io/test_files/', ioService);

      return htmlExtractor.expressions;
    }

    it('should extract all expressions from source and templates', () {
      var expressions = _extractExpressions('test/io/test_files/main.dart');

      expect(expressions, unorderedEquals([
          'attr',
          'expr',
          'anotherExpression',
          'callback',
          'twoWayStuff',
          'exported + expression',
          'inline.template.expression',
          'ngIfCondition',
          'if'
      ]));
    });

    it('should extract expressions from ngRoute viewHtml', () {
      var expressions = _extractExpressions('test/io/test_files/routing.dart');
      expect(expressions, contains('foo'));
      expect(expressions, contains('bar'));
    });
  });
}
