library ng.tool.source_metadata_extractor_spec;

import 'package:angular/tools/common.dart';
import 'package:angular/tools/source_crawler_impl.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import '../jasmine_syntax.dart';
import 'package:unittest/unittest.dart';

main() => describe('source_metadata_extractor', () {
  it('should extract all attribute mappings including annotations', () {
    var sourceCrawler = new SourceCrawlerImpl(['packages/']);
    var sourceMetadataExtractor = new SourceMetadataExtractor();
    List<DirectiveInfo> directives =
        sourceMetadataExtractor
            .gatherDirectiveInfo('test/io/test_files/main.dart', sourceCrawler);

    expect(directives, hasLength(2));

    DirectiveInfo info = directives.elementAt(1);
    expect(info.expressionAttrs, unorderedEquals(['expr', 'another-expression',
        'callback', 'two-way-stuff', 'exported-attr']));
    expect(info.expressions, unorderedEquals(['attr', 'expr',
        'anotherExpression', 'callback', 'twoWayStuff',
        'exported + expression']));
  });
});
