library templateurl_spec;

import '../_specs.dart';

@Component(
    selector: 'simple-url',
    templateUrl: 'simple.html')
class SimpleUrlComponent {
}

@Component(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: 'simple.css')
class HtmlAndCssComponent {
}

@Component(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: const ['simple.css', 'another.css'])
class HtmlAndMultipleCssComponent {
}

@Component(
    selector: 'inline-with-css',
    template: '<div>inline!</div>',
    cssUrl: 'simple.css')
class InlineWithCssComponent {
}

@Component(
    selector: 'only-css',
    cssUrl: 'simple.css')
class OnlyCssComponent {
}

class PrefixedUrlRewriter extends UrlRewriter {
  call(url) => "PREFIX:$url";
}

void main() {
  describe('template url', () {
    afterEach((MockHttpBackend backend) {
      backend.verifyNoOutstandingExpectation();
      backend.verifyNoOutstandingRequest();
    });

    describe('loading with http rewriting', () {
      beforeEachModule((Module module) {
        module
            ..bind(HtmlAndCssComponent)
            ..bind(UrlRewriter, toImplementation: PrefixedUrlRewriter);
      });

      it('should use the UrlRewriter for both HTML and CSS URLs', async(
          (Http http, Compiler compile, Scope rootScope, Logger log,
           Injector injector, VmTurnZone zone, MockHttpBackend backend,
           DirectiveMap directives) {

        var element = e('<div><html-and-css log>ignore</html-and-css><div>');
        zone.run(() {
          compile([element], directives)(rootScope, null, [element]);
        });

        backend
            ..flushGET('PREFIX:simple.css').respond('.hello{}')
            ..flushGET('PREFIX:simple.html').respond('<div log="SIMPLE">Simple!</div>');

        microLeap();

        expect(element).toHaveText('.hello{}Simple!');
        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );
      }));
    });


    describe('async template loading', () {
      beforeEachModule((Module module) {
        module
            ..bind(LogAttrDirective)
            ..bind(SimpleUrlComponent)
            ..bind(HtmlAndCssComponent)
            ..bind(OnlyCssComponent)
            ..bind(InlineWithCssComponent);
      });

      it('should replace element with template from url', async(
          (Http http, Compiler compile, Scope rootScope,  Logger log,
           Injector injector, MockHttpBackend backend, DirectiveMap directives) {

        var element = es('<div><simple-url log>ignore</simple-url><div>');
        compile(element, directives)(rootScope, null, element);

        backend.flushGET('simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element[0]).toHaveText('Simple!');
        rootScope.apply();
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));

      it('should load template from URL once', async(
          (Http http, Compiler compile, Scope rootScope,  Logger log,
           Injector injector, MockHttpBackend backend, DirectiveMap directives) {
        var element = es(
            '<div>'
            '<simple-url log>ignore</simple-url>'
            '<simple-url log>ignore</simple-url>'
            '<div>');
        compile(element, directives)(rootScope, null, element);

        backend.flushGET('simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element.first).toHaveText('Simple!Simple!');
        rootScope.apply();

        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
      }));

      it('should load a CSS file into a style', async(
          (Http http, Compiler compile, Scope rootScope, Logger log,
           Injector injector, MockHttpBackend backend, DirectiveMap directives) {
        var element = e('<div><html-and-css log>ignore</html-and-css><div>');
        compile([element], directives)(rootScope, null, [element]);

        backend
            ..flushGET('simple.css').respond(200, '.hello{}')
            ..flushGET('simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');

        microLeap();

        expect(element).toHaveText('.hello{}Simple!');
        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );
        rootScope.apply();
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));

      it('should load a CSS file with a \$template', async(
          (Http http, Compiler compile, Scope rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
        var element = es('<div><inline-with-css log>ignore</inline-with-css><div>');
        compile(element, directives)(rootScope, null, element);

        backend.flushGET('simple.css').respond(200, '.hello{}');
        microLeap();

        expect(element[0]).toHaveText('.hello{}inline!');
      }));

      it('should ignore CSS load errors ', async(
          (Http http, Compiler compile, Scope rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
        var element = es('<div><inline-with-css log>ignore</inline-with-css><div>');
        compile(element, directives)(rootScope, null, element);

        backend.flushGET('simple.css').respond(500, 'some error');
        microLeap();

        expect(element.first).toHaveText(
            '/*\n'
            'HTTP 500: some error\n'
            '*/\n'
            'inline!');
      }));

      it('should load a CSS with no template', async(
          (Http http, Compiler compile, Scope rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
        var element = es('<div><only-css log>ignore</only-css><div>');
        compile(element, directives)(rootScope, null, element);

        backend.flushGET('simple.css').respond(200, '.hello{}');
        microLeap();

        expect(element[0]).toHaveText('.hello{}');
      }));

      it('should load the CSS before the template is loaded', async(
          (Http http, Compiler compile, Scope rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
        var element = es('<html-and-css>ignore</html-and-css>');
        compile(element, directives)(rootScope, null, element);

        backend
            ..flushGET('simple.css').respond(200, '.hello{}')
            ..flushGET('simple.html').respond(200, '<div>Simple!</div>');
        microLeap();

        expect(element.first).toHaveText('.hello{}Simple!');
      }));
    });

    describe('multiple css loading', () {
      beforeEachModule((Module module) {
        module
            ..bind(LogAttrDirective)
            ..bind(HtmlAndMultipleCssComponent);
      });

      it('should load multiple CSS files into a style', async(
          (Http http, Compiler compile, Scope rootScope, Logger log,
           Injector injector, MockHttpBackend backend, DirectiveMap directives) {
        var element = e('<div><html-and-css log>ignore</html-and-css><div>');
        compile([element], directives)(rootScope, null, [element]);

        backend
            ..flushGET('simple.css').respond(200, '.hello{}')
            ..flushGET('another.css').respond(200, '.world{}')
            ..flushGET('simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element).toHaveText('.hello{}.world{}Simple!');
        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><style>.world{}</style><div log="SIMPLE">Simple!</div>'
        );
        rootScope.apply();
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    });

    describe('style cache', () {
      beforeEachModule((Module module) {
        module
            ..bind(HtmlAndCssComponent)
            ..bind(TemplateCache, toValue: new TemplateCache(capacity: 0));
      });

      it('should load css from the style cache for the second component', async(
          (Http http, Compiler compile, MockHttpBackend backend, RootScope rootScope,
           DirectiveMap directives, Injector injector) {
        var element = e('<div><html-and-css>ignore</html-and-css><div>');
        compile([element], directives)(rootScope, null, [element]);

        backend
            ..flushGET('simple.css').respond(200, '.hello{}')
            ..flushGET('simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );

        var element2 = e('<div><html-and-css>ignore</html-and-css><div>');
        compile([element2], directives)(rootScope, null, [element2]);

        microLeap();

        expect(element2.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );
      }));
    });
  });
}
