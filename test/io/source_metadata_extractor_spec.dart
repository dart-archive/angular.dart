library ng.tool.source_metadata_extractor_spec;

import 'package:angular/tools/common.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/source_metadata_extractor.dart';

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';

void main() {
  describe('source_metadata_extractor', () {
    it('should extract all attribute mappings including annotations', () {
      var sourceCrawler = new SourceCrawlerImpl(['packages/']);
      var sourceMetadataExtractor = new SourceMetadataExtractor();
      List<DirectiveInfo> directives = sourceMetadataExtractor
          .gatherDirectiveInfo('test/io/test_files/main.dart', sourceCrawler);

      expect(directives.map((d) => d.selector),
          unorderedEquals(['[ng-if]', 'my-component']));

      DirectiveInfo info = directives.elementAt(1);
      expect(info.expressionAttrs, unorderedEquals(['expr', 'another-expression',
          'callback', 'two-way-stuff', 'exported-attr']));
      expect(info.expressions, unorderedEquals(['attr', 'expr',
          'anotherExpression', 'callback', 'twoWayStuff', 'exported + expression']));
    });

    it('should extract ngRoute templates from ngRoute viewHtml', () {
      var sourceCrawler = new SourceCrawlerImpl(['packages/']);
      var sourceMetadataExtractor = new SourceMetadataExtractor();
      List<DirectiveInfo> directives = sourceMetadataExtractor
          .gatherDirectiveInfo('test/io/test_files/routing.dart', sourceCrawler);

      var templates = directives
          .where((i) => i.selector == null)
          .map((i) => i.template);
      expect(templates, hasLength(2));
      expect(templates,
          unorderedEquals(['<div ng-if="foo"></div>', '<div ng-if="bar"></div>']));
    });
  });
}
