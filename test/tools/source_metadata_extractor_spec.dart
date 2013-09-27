library source_metadata_extractor_spec;

import '../_specs.dart' hide Node, Element, Text, Token;

import 'package:analyzer_experimental/src/generated/ast.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import 'package:angular/tools/source_crawler.dart';
import 'package:angular/tools/common.dart';

main() => describe('SourceMetadataExtractor', () {

  it('should extract expressions and attribute names with expressions', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('FooComponent', COMPONENT, null, {
        'fooVal': '@',
        'barVal': '@ctrl.bar',
        'bazVal': '@.baz',
        'fooExpr': '=',
        'barExpr': '=ctrl.bar',
        'bazExpr': '=.baz',
        'fooCallback': '&',
        'barCallback': '&ctrl.bar',
        'bazCallback': '&.baz',
        'oneTime': '!'
      })
    ]);

    expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
        equals(['foo-val',
                'bar-val',
                'baz-val',
                'foo-expr',
                'bar-expr',
                'baz-expr',
                'foo-callback',
                'bar-callback',
                'baz-callback',
                'one-time']));
    expect(flattenList(info, (DirectiveInfo i) => i.expressions),
        equals(['fooVal',
                'ctrl.bar',
                'baz',
                'fooExpr',
                'ctrl.bar',
                'baz',
                'fooCallback',
                'ctrl.bar',
                'baz',
                'oneTime']));
  });

  it('should build a component selector if one is not explicitly specified', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooComponent', COMPONENT, null, {
        'fooExpr': '='
      })
    ]);

    expect(info, hasLength(1));
    expect(info[0].selector, equals('my-foo'));
  });

  it('should build an element directive selector if one is not explicitly specified', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooDirective', DIRECTIVE, null, {
        'fooExpr': '='
      })
    ]);

    expect(info, hasLength(1));
    expect(info[0].selector, equals('my-foo'));
  });

  it('should build an attr directive selector if one is not explicitly specified', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, null, {
        'fooExpr': '='
      })
    ]);

    expect(info, hasLength(1));
    expect(info[0].selector, equals('[my-foo]'));
  });

  it('should figure out attribute name if dot(.) is used', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, null, {
        '.': '='
      })
    ]);

    expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
           equals(['my-foo']));
  });

  it('should figure out attribute name from selector if dot(.) is used', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
        '.': '='
      })
    ]);

    expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
           equals(['foo']));
  });

  it('should include exported expression attributes', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
        '.': '='
      }, ['baz'])
    ]);

    expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
           equals(['foo', 'baz']));
  });

  it('should include exported expressions', () {
    var info = extractDirectiveInfo([
      new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
        '.': '='
      }, null, ['ctrl.baz'])
    ]);

    expect(flattenList(info, (DirectiveInfo i) => i.expressions),
           equals(['ctrl.baz']));
  });

});

flattenList(list, map) => list.map(map).fold([], (prev, exprs) =>
    new List.from(prev)..addAll(exprs));

List<DirectiveInfo> extractDirectiveInfo(List<DirectiveMetadata> metadata) {
  var sourceCrawler = new MockSourceCrawler();
  var metadataCollector = new MockDirectiveMetadataCollectingVisitor(metadata);
  var extractor = new SourceMetadataExtractor(sourceCrawler, metadataCollector);
  return extractor.gatherDirectiveInfo('');
}

class MockDirectiveMetadataCollectingVisitor
    implements DirectiveMetadataCollectingVisitor {
  List<DirectiveMetadata> metadata;

  MockDirectiveMetadataCollectingVisitor(List<DirectiveMetadata> this.metadata);

  call(CompilationUnit cu) {
    // do nothing
  }
}

class MockSourceCrawler implements SourceCrawler {

  void crawl(String entryPoint, visitor(CompilationUnit cu)) {
    // do nothing
  }
}
