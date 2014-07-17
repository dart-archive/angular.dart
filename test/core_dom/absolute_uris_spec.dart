library angular.test.core_dom.uri_resolver_spec;

import 'package:angular/core_dom/absolute_uris.dart' as absolute;
import '../_specs.dart';


void main() {
  describe('url_resolver', () {
    var container;

    beforeEach(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    afterEach(() {
      container.remove();
    });

    var local = Uri.base;
    var originalBase = local.resolve('foo/foo.html');

    DocumentFragment fragment(String html) =>
        new DocumentFragment.html(html, validator: new NullSanitizer());

    it('resolves attribute URIs', () {
      var node = new ImageElement()..attributes['src'] = 'foo.png';

      absolute.resolveDom(node, originalBase);
      expect(node.attributes['src']).toEqual(
          originalBase.resolve('foo.png').toString());
    });

    it('resolves template contents', () {
      var dom = fragment('''
        <template>
          <img src='foo.png'>
        </template>''');

      absolute.resolveDom(dom, originalBase);
      var img = dom.children[0].content.children[0];
      container.append(img);
      expect(img.src).toEqual(originalBase.resolve('foo.png').toString());
    });

    // NOTE: These two tests currently fail on firefox, but pass on chrome,
    // safari and dartium browsers. Add back into the list of tests when firefox
    // pushes new version(s).
    xit('resolves CSS URIs', () {
      var dom = fragment('''
        <style>
          body {
            background-image: url(foo.png);
          }
        </style>''');

      absolute.resolveDom(dom, originalBase);
      var style = dom.children[0];
      container.append(style);
      expect(style.sheet.rules[0].style.backgroundImage).toEqual(
          'url(${originalBase.resolve('foo.png')})');
    });

    xit('resolves @import URIs', () {
      var dom = fragment('''
        <style>
          @import url("foo.css");
          @import 'bar.css';
        </style>''');

      absolute.resolveDom(dom, originalBase);
      var style = dom.children[0];
      document.body.append(style);
      CssImportRule import1 = style.sheet.rules[0];
      expect(import1.href).toEqual(originalBase.resolve('foo.css').toString());
      CssImportRule import2 = style.sheet.rules[1];
      expect(import2.href).toEqual(originalBase.resolve('bar.css').toString());
    });
  });
}

class NullSanitizer implements NodeValidator {
  bool allowsElement(Element element) => true;
  bool allowsAttribute(Element element, String attributeName, String value) =>
      true;
}
