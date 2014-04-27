library html_extractor_spec;

import 'package:angular/tools/common.dart';
import 'package:angular/tools/html_extractor.dart';

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';
import 'mock_io_service.dart';

void main() {
  describe('html_extractor', () {

    it('should extract text mustache expressions', () {
      var ioService = new MockIoService({
          'foo.html': r'''
        <div>foo {{ctrl.bar}} baz {{aux}}</div>
      '''
      });

      var extractor = new HtmlExpressionExtractor([]);
      extractor.crawl('/', ioService);
      expect(extractor.expressions.toList()..sort(),
      equals(['aux', 'ctrl.bar']));
    });

    it('should extract attribute mustache expressions', () {
      var ioService = new MockIoService({
          'foo.html': r'''
        <div foo="foo-{{ctrl.bar}}" baz="{{aux}}-baz"></div>
      '''
      });

      var extractor = new HtmlExpressionExtractor([]);
      extractor.crawl('/', ioService);
      expect(extractor.expressions.toList()..sort(),
      equals(['aux', 'ctrl.bar']));
    });

    it('should extract ng-repeat expressions', () {
      var ioService = new MockIoService({
          'foo.html': r'''
        <div ng-repeat="foo in ctrl.bar"></div>
      '''
      });

      var extractor = new HtmlExpressionExtractor([]);
      extractor.crawl('/', ioService);
      expect(extractor.expressions.toList()..sort(),
      equals(['ctrl.bar']));
    });

    it('should extract expressions provided in the directive info', () {
      var ioService = new MockIoService({});

      var extractor = new HtmlExpressionExtractor([
          new DirectiveInfo('', [], ['foo', 'bar'])
      ]);
      extractor.crawl('/', ioService);
      expect(extractor.expressions.toList()..sort(),
      equals(['bar', 'foo']));
    });

    it('should extract expressions from expression attributes', () {
      var ioService = new MockIoService({
          'foo.html': r'''
        <foo bar="ctrl.baz"></foo>
      '''
      });

      var extractor = new HtmlExpressionExtractor([
          new DirectiveInfo('foo', ['bar'])
      ]);
      extractor.crawl('/', ioService);
      expect(extractor.expressions.toList()..sort(),
      equals(['ctrl.baz']));
    });

    it('should ignore ng-repeat while extracting attribute expressions', () {
      var ioService = new MockIoService({
          'foo.html': r'''
        <div ng-repeat="foo in ctrl.bar"></div>
      '''
      });

      var extractor = new HtmlExpressionExtractor([
          new DirectiveInfo('[ng-repeat]', ['ng-repeat'])
      ]);
      extractor.crawl('/', ioService);
      // Basically we don't want to extract "foo in ctrl.bar".
      expect(extractor.expressions.toList()..sort(),
      equals(['ctrl.bar']));
    });
  });
}
