library source_metadata_extractor_spec;

import 'package:analyzer/src/generated/ast.dart';
import 'package:angular/tools/common.dart';
import 'package:angular/tools/source_crawler.dart';
import 'package:angular/tools/source_metadata_extractor.dart';

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';

void main() {
  describe('SourceMetadataExtractor', () {

    it('should extract expressions and attribute names with expressions', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('FooComponent', COMPONENT, 'foo-component', {
              'barVal': '@bar',
              'baz-expr1': '<=>baz1',
              'baz-expr2': '=>baz2',
              'baz-expr3': '=>!baz3',
              'baz-callback': '&aux',
          })
      ]);

      expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
      equals(['baz-expr1',
          'baz-expr2',
          'baz-expr3',
          'baz-callback']));
      expect(flattenList(info, (DirectiveInfo i) => i.expressions),
      equals(['bar',
          'baz1',
          'baz2',
          'baz3',
          'aux']));
    });

    it('should build a component selector if one is not explicitly specified', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooComponent', COMPONENT, 'my-foo', {
              'foo-expr': '=>fooExpr'
          })
      ]);

      expect(info, hasLength(1));
      expect(info[0].selector, equals('my-foo'));
    });

    it('should build an element directive selector if one is not explicitly specified', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooDirective', DIRECTIVE, 'my-foo', {
              'foo-expr': '=>fooExpr'
          })
      ]);

      expect(info, hasLength(1));
      expect(info[0].selector, equals('my-foo'));
    });

    it('should build an attr directive selector if one is not explicitly specified', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooAttrDirective', '[my-foo]', '[my-foo]', {
              'foo-expr': '=>fooExpr'
          })
      ]);

      expect(info, hasLength(1));
      expect(info[0].selector, equals('[my-foo]'));
    });

    it('should figure out attribute name if dot(.) is used', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[my-foo]', {
              '.': '=>fooExpr'
          })
      ]);

      expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
      equals(['my-foo']));
    });

    it('should figure out attribute name from selector if dot(.) is used', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
              '.': '=>fooExpr'
          })
      ]);

      expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
      equals(['foo']));
    });

    it('should include exported expression attributes', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
              '.': '=>fooExpr'
          }, ['baz'])
      ]);

      expect(flattenList(info, (DirectiveInfo i) => i.expressionAttrs),
      equals(['foo', 'baz']));
    });

    it('should include exported expressions', () {
      var info = extractDirectiveInfo([
          new DirectiveMetadata('MyFooAttrDirective', DIRECTIVE, '[blah][foo]', {
              '.': '=>fooExpr'
          }, null, ['ctrl.baz'])
      ]);

      expect(flattenList(info, (DirectiveInfo i) => i.expressions),
      equals(['fooExpr', 'ctrl.baz']));
    });

  });
}

flattenList(list, map) => list.map(map).fold([], (prev, exprs) =>
    new List.from(prev)..addAll(exprs));

List<DirectiveInfo> extractDirectiveInfo(List<DirectiveMetadata> metadata) {
  var sourceCrawler = new MockSourceCrawler();
  var metadataCollector = new MockDirectiveMetadataCollectingVisitor(metadata);
  var extractor = new SourceMetadataExtractor(metadataCollector);
  return extractor.gatherDirectiveInfo('', sourceCrawler);
}

class MockDirectiveMetadataCollectingVisitor
    implements DirectiveMetadataCollectingVisitor {
  List<DirectiveMetadata> metadata;
  List<String> templates = <String>[];

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
