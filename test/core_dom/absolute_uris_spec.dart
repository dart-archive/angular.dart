library angular.test.core_dom.uri_resolver_spec;

import 'package:angular/core_dom/absolute_uris.dart';
import 'package:angular/core_dom/type_to_uri_mapper.dart';
import 'package:angular/core_dom/type_to_uri_mapper_dynamic.dart';
import '../_specs.dart';


_run({useRelativeUrls, staticMode}) {
  describe("url resolution: staticMode=$staticMode, useRelativeUrls=$useRelativeUrls", () {
    var prefix = useRelativeUrls ? "packages/angular/test/core_dom/" : "";
    var container;
    var urlResolver;
  
    beforeEach((ResourceUrlResolver _urlResolver) {
      urlResolver = _urlResolver;
      container = document.createElement('div');
      document.body.append(container);
    });
    
    afterEach(() {
      urlResolver = null;
      container.remove();
    });
    
    beforeEachModule((Module module) {
      module
       ..bind(ResourceResolverConfig, toValue: 
            new ResourceResolverConfig(useRelativeUrls: useRelativeUrls))
       ..bind(TypeToUriMapper, toImplementation: DynamicTypeToUriMapper);
    });
    
    var originalBase = Uri.base;
    var setHttp = true;    
    testResolution(url, expected) {
      var http = setHttp;
      var title = "";
      if (!useRelativeUrls || http) {
        expected = url;
        title += "should not resolve";
      }
      
      var baseUri = originalBase;
      title += staticMode ? " staticMode: true" : " staticMode: false";
      title += useRelativeUrls ? " should go through resolution: true " : " should go through resolution: false";
      it('${title}: resolves attribute URIs $url to $expected', (ResourceUrlResolver resourceResolver) {
        var html = resourceResolver.resolveHtml("<img src='$url'>", baseUri);
        expect(html).toEqual('<img src="$expected">');
      });
    }
    
    // Set originalBase to an http URL type instead of a 'package:' URL (because of
    // the way karma runs the tests) and ensure that after resolution, the result doesn't
    // have a protocol or domain but contains the full path    
    testResolution(Uri.base.resolve('packages/angular/test/core_dom/foo.html').toString(),
        'packages/angular/test/core_dom/foo.html');
    testResolution(Uri.base.resolve('foo.html').toString(),
        'packages/angular/test/core_dom/foo.html');
    testResolution(Uri.base.resolve('./foo.html').toString(),
        'packages/angular/test/core_dom/foo.html');
    testResolution(Uri.base.resolve('/foo.html').toString(),
        '/foo.html');    
    

    originalBase = Uri.parse('package:angular/test/core_dom/absolute_uris_spec.dart');
    setHttp = false;

    testResolution('packages/angular/test/core_dom/foo.html', 'packages/angular/test/core_dom/foo.html');
    testResolution('foo.html', 'packages/angular/test/core_dom/foo.html');
    testResolution('./foo.html', 'packages/angular/test/core_dom/foo.html');
    testResolution('/foo.html', '/foo.html');
    testResolution('http://google.com/foo.html', 'http://google.com/foo.html');
 
    
    
    // Set originalBase back

    templateResolution(url, expected) {
      if (!useRelativeUrls)
        expected = url;
      expect(urlResolver.resolveHtml('''
        <template>
          <img src="$url">
        </template>''', originalBase)).toEqual('''
        <template>
          <img src="$expected">
        </template>''');
    }

    it('resolves template contents', () {
      templateResolution('foo.png', 'packages/angular/test/core_dom/foo.png');
    });

    it('does not change absolute urls when they are resolved', () {
      templateResolution('/foo/foo.png', '/foo/foo.png');
    });

    it('resolves CSS URIs', (ResourceUrlResolver resourceResolver) {
      var html_style = ('''
        <style>
          body {
            background-image: url(foo.png);
          }
        </style>''');

      html_style = resourceResolver.resolveHtml(html_style, originalBase).toString();

      var resolved_style = ('''
        <style>
          body {
            background-image: url('${prefix}foo.png');
          }
        </style>''');
      expect(html_style).toEqual(resolved_style);
    });

    it('resolves @import URIs', (ResourceUrlResolver resourceResolver) {
      var html_style = ('''
        <style>
          @import url("foo.css");
          @import 'bar.css';
        </style>''');

      html_style = resourceResolver.resolveHtml(html_style, originalBase).toString();

      var resolved_style = ('''
        <style>
          @import url('${prefix}foo.css');
          @import '${prefix}bar.css';
        </style>''');
      expect(html_style).toEqual(resolved_style);
    });
  });
}

void main() {
  describe('url_resolver', () {
    _run(useRelativeUrls: true, staticMode: true);
    _run(useRelativeUrls: false, staticMode: true);//TODO get rid of staticMode
  });
}

class NullSanitizer implements NodeValidator {
  bool allowsElement(Element element) => true;
  bool allowsAttribute(Element element, String attributeName, String value) =>
      true;
}