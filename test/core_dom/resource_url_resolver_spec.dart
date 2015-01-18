library angular.test.core_dom.uri_resolver_spec;

import 'dart:html';
import 'package:angular/core_dom/resource_url_resolver.dart';
import 'package:angular/core_dom/type_to_uri_mapper.dart';
import 'package:angular/core_dom/type_to_uri_mapper_dynamic.dart';
import '../_specs.dart';

final bool isBrowserInternetExplorer = window.navigator.userAgent.indexOf(" MSIE ") > 0;

_run_resolver({useRelativeUrls}) {
  describe("resolveUrls=$useRelativeUrls", () {
    var prefix = useRelativeUrls ? "packages/angular/test/core_dom/" : "";
    var container;
    var resourceResolver;

    beforeEach((ResourceUrlResolver _urlResolver) {
      resourceResolver = _urlResolver;
      container = document.createElement('div');
      document.body.append(container);
    });

    afterEach(() {
      resourceResolver = null;
      container.remove();
    });

    beforeEachModule((Module module) {
      module
       ..bind(ResourceResolverConfig, toValue:
            new ResourceResolverConfig.resolveRelativeUrls(useRelativeUrls))
       ..bind(TypeToUriMapper, toImplementation: DynamicTypeToUriMapper);
    });

    // Our tests depend on this to test http:// URL resolution (e.g. when the
    // type's library scheme is http.)
    assert(Uri.base.scheme == "http" || Uri.base.scheme == "https");

    toAppUrl(url) {
      var marker = "HTTP://LOCALHOST/";
      if (url.startsWith(marker)) {
        return "${Uri.base.origin}/${url.substring(marker.length)}";
      } else {
        return url;
      }
    }

    String urlInImport(cssEscapedUrl) => '<style>@import $cssEscapedUrl</style>';
    String urlInBackgroundImg(cssEscapedUrl) => '<style>body { background-image: $cssEscapedUrl }</style>';
    String urlInTemplateImgSrc(htmlEscapedUrl) => '<template><img src=\"$htmlEscapedUrl\"></template>';
    String urlInTemplateHref(htmlEscapedUrl) => '<template><a href=\"$htmlEscapedUrl\"></a></template>';
    String urlInTemplateAction(htmlEscapedUrl) => '<template><form action=\"$htmlEscapedUrl\"></form></template>';
    String urlInImgSrc(htmlEscapedUrl) => '<div><img src=\"$htmlEscapedUrl\"></div>';
    String urlInHref(htmlEscapedUrl) => '<div><a href=\"$htmlEscapedUrl\"></a></div>';
    String urlInAction(htmlEscapedUrl) => '<div><form action=\"$htmlEscapedUrl\"></form></div>';

    escapeUrlForCss(String unEscapedUrl) {
      return unEscapedUrl..replaceAll("\\", "\\\\")
                         ..replaceAll("'", "\'")
                         ..replaceAll("\"", "\\\"");
    }

    testOnCssTemplates(cssEscapedUrl, cssEscapedExpected, typeOrIncludeUri) {
      it('within an @import', () {
        var html = resourceResolver.resolveHtml(urlInImport(cssEscapedUrl), typeOrIncludeUri);
        expect(html).toEqual(urlInImport(cssEscapedExpected));
      });

      it('within a background-image: attribute', () {
        var html = resourceResolver.resolveHtml(urlInBackgroundImg(cssEscapedUrl), typeOrIncludeUri);
        expect(html).toEqual(urlInBackgroundImg(cssEscapedExpected));
      });
    }

    testOnHtmlTemplate(htmlEscapedUrl, htmlEscapedExpected, typeOrIncludeUri) {
     it('should rewrite img[src]', () {
       var html = resourceResolver.resolveHtml(urlInImgSrc(htmlEscapedUrl), typeOrIncludeUri);
       expect(html).toEqual(urlInImgSrc(htmlEscapedExpected));
     });

     it('should rewrite a[href]', () {
       var html = resourceResolver.resolveHtml(urlInHref(htmlEscapedUrl), typeOrIncludeUri);
       expect(html).toEqual(urlInHref(htmlEscapedExpected));
     });

     it('should rewrite form[action]', () {
       var html = resourceResolver.resolveHtml(urlInAction(htmlEscapedUrl), typeOrIncludeUri);
       expect(html).toEqual(urlInAction(htmlEscapedExpected));
     });

     // IE does not support the template tag.
     if (!isBrowserInternetExplorer) {
       it('should rewrite img[src] in template tag', () {
         var html = resourceResolver.resolveHtml(urlInTemplateImgSrc(htmlEscapedUrl), typeOrIncludeUri);
         expect(html).toEqual(urlInTemplateImgSrc(htmlEscapedExpected));
       });

       it('should rewrite a[href] in template tag', () {
         var html = resourceResolver.resolveHtml(urlInTemplateHref(htmlEscapedUrl), typeOrIncludeUri);
         expect(html).toEqual(urlInTemplateHref(htmlEscapedExpected));
       });

       it('should rewrite form[action] in template tag', () {
         var html = resourceResolver.resolveHtml(urlInTemplateAction(htmlEscapedUrl), typeOrIncludeUri);
         expect(html).toEqual(urlInTemplateAction(htmlEscapedExpected));
       });
      }
    }

    // testOnAllTemplates will insert the url to be resolved into three different types
    // of templates, using several different variations of the css 'url()' function call
    // then attempt to resolve that html and the contained url, and check against the expected url
    testOnAllTemplates(url, expected, typeOrIncludeUri) {
      var urlCssEscaped = escapeUrlForCss(url);
      var expectedCssEscaped = escapeUrlForCss(expected);

      testOnCssTemplates("url($urlCssEscaped)",
                         "url($expectedCssEscaped)",
                         typeOrIncludeUri);
      testOnCssTemplates("url('$urlCssEscaped')",
                         "url('$expectedCssEscaped')",
                         typeOrIncludeUri);
      testOnCssTemplates("url(\"$urlCssEscaped\")",
                         "url(\"$expectedCssEscaped\")",
                         typeOrIncludeUri);
      testOnCssTemplates("url(  $urlCssEscaped  )",
                         "url($expectedCssEscaped)",
                         typeOrIncludeUri);
      testOnCssTemplates("url(  '$urlCssEscaped'  )",
                         "url('$expectedCssEscaped')",
                         typeOrIncludeUri);
      testOnCssTemplates("url(  \"$urlCssEscaped\"  )",
                         "url(\"$expectedCssEscaped\")",
                         typeOrIncludeUri);
      testOnHtmlTemplate(Uri.encodeFull(url),
                         Uri.encodeFull(expected),
                         typeOrIncludeUri);
    }

    testResolution(typeOrIncludeUri, urlToResolve, expected) {
      describe('should resolve $urlToResolve to $expected', () {
        // Generic test that we are properly resolving the url
        it('using generic resolution', () {
          expect(resourceResolver.combine(typeOrIncludeUri, urlToResolve))
          .toEqual(expected);
        });
        // More rigorous tests to check that we find the url within various html and css
        // templates, and properly resolve it
        testOnAllTemplates(urlToResolve, expected, typeOrIncludeUri);
      });
    }

    testBothSchemes({urlToResolve, expectedForPackageScheme, expectedForHttpScheme}) {
      assert(urlToResolve != null && expectedForPackageScheme != null && expectedForHttpScheme != null);

      urlToResolve = toAppUrl(urlToResolve);

      // If we're not resolving URLs, then it should be unchanged.
      if (!useRelativeUrls) {
        expectedForPackageScheme = urlToResolve;
        expectedForHttpScheme = urlToResolve;
      }

      describe('scheme=package', () {
        // test the cases where we're resolving URLs for a component/decorator whose
        // type URI looks like
        // package:angular/test/core_dom/uri_resolver_spec.dart.
        var typeOrIncludeUri = Uri.parse('package:angular/test/core_dom/uri_resolver_spec.dart');
        testResolution(typeOrIncludeUri, urlToResolve, expectedForPackageScheme);
      });

      describe('scheme=http', () {
        // A type URI need not always be a package: URI.  This can happen when:
        // • the type was defined in a Dart file that was
        //   imported via a path, e.g. "import 'web/bar.dart'".  (karma does this.)
        // • we are ng-include'ing a file, say, "a/b/foo.html", and we are trying to
        //   resolve paths inside foo.html.  Those should be resolved relative to
        //   something like http://localhost:8765/a/b/foo.html.
        var typeOrIncludeUri = Uri.parse(toAppUrl('HTTP://LOCALHOST/a/b/included_template.html'));
        testResolution(typeOrIncludeUri, urlToResolve, expectedForHttpScheme);
      });
    }

    // These tests check resolving with respect to paths that folks would have
    // typed by hand - either in the component annotation (templateUrl/cssUrl)
    // to ng-include / routing.
    // They also check resolving with respect to paths that were obtained by
    // typeToUri(type) when it returns a non-absolute path.

    // "packages/" paths, though relative, should never be resolved.
    testBothSchemes(
        urlToResolve:             'packages/angular/test/core_dom/foo.html',
        expectedForPackageScheme: 'packages/angular/test/core_dom/foo.html',
        expectedForHttpScheme:    'packages/angular/test/core_dom/foo.html');

    testBothSchemes(
        urlToResolve:             'package:a.b/c/d/foo2.html',
        expectedForPackageScheme: '/packages/a.b/c/d/foo2.html',
        expectedForHttpScheme:    '/packages/a.b/c/d/foo2.html');

    testBothSchemes(
        urlToResolve:             'image.png',
        expectedForPackageScheme: '/packages/angular/test/core_dom/image.png',
        expectedForHttpScheme:    '/a/b/image.png');

    testBothSchemes(
        urlToResolve:             './image2.png',
        expectedForPackageScheme: '/packages/angular/test/core_dom/image2.png',
        expectedForHttpScheme:    '/a/b/image2.png');

    testBothSchemes(
        urlToResolve:             '/image3.png',
        expectedForPackageScheme: '/image3.png',
        expectedForHttpScheme:    '/image3.png');

    testBothSchemes(
        urlToResolve:             'http://www.google.com/something',
        expectedForPackageScheme: 'http://www.google.com/something',
        expectedForHttpScheme:    'http://www.google.com/something');

    testBothSchemes(
        urlToResolve:             '''http://www.google.com/something/foo('bar)''',
        expectedForPackageScheme: '''http://www.google.com/something/foo('bar)''',
        expectedForHttpScheme:    '''http://www.google.com/something/foo('bar)''');

    testBothSchemes(
        urlToResolve:             'HTTP://LOCALHOST/a/b/image4.png',
        expectedForPackageScheme: '/a/b/image4.png',
        expectedForHttpScheme:    '/a/b/image4.png');

    testBothSchemes(
        urlToResolve:             'HTTP://LOCALHOST/packages/angular/test/core_dom/foo3.html',
        expectedForPackageScheme: '/packages/angular/test/core_dom/foo3.html',
        expectedForHttpScheme:    '/packages/angular/test/core_dom/foo3.html');

  });
}

void main() {
  describe('url_resolver', () {
    _run_resolver(useRelativeUrls: true);
    _run_resolver(useRelativeUrls: false);
  });
}

class NullSanitizer implements NodeValidator {
  bool allowsElement(Element element) => true;
  bool allowsAttribute(Element element, String attributeName, String value) =>
      true;
}
