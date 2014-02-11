library templateurl_spec;

import '../_specs.dart';

@NgComponent(
    selector: 'simple-url',
    templateUrl: 'simple.html')
class SimpleUrlComponent {
}

@NgComponent(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: 'simple.css')
class HtmlAndCssComponent {
}

@NgComponent(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: const ['simple.css', 'another.css'])
class HtmlAndMultipleCssComponent {
}

@NgComponent(
    selector: 'inline-with-css',
    template: '<div>inline!</div>',
    cssUrl: 'simple.css')
class InlineWithCssComponent {
}

@NgComponent(
    selector: 'only-css',
    cssUrl: 'simple.css')
class OnlyCssComponent {
}

class PrefixedUrlRewriter extends UrlRewriter {
  call(url) => "PREFIX:$url";
}

main() => describe('template url', () {
  afterEach(inject((MockHttpBackend backend) {
    backend.verifyNoOutstandingRequest();
  }));

  describe('loading with http rewriting', () {
    beforeEach(module((Module module) {
      module
          ..type(HtmlAndCssComponent)
          ..type(UrlRewriter, implementedBy: PrefixedUrlRewriter);
    }));

    it('should use the UrlRewriter for both HTML and CSS URLs', async(inject((Http $http,
          Compiler $compile, Scope $rootScope, Logger log, Injector injector, NgZone zone,
          MockHttpBackend backend, DirectiveMap directives) {

      backend
          ..whenGET('PREFIX:simple.html').respond('<div log="SIMPLE">Simple!</div>')
          ..whenGET('PREFIX:simple.css').respond('.hello{}');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      zone.run(() {
        $compile(element, directives)(injector, element);
      });

      backend.flush();
      microLeap();

      expect(renderedText(element)).toEqual('.hello{}Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
          '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
      );
    })));
  });


  describe('async template loading', () {
    beforeEach(module((Module module) {
      module
          ..type(LogAttrDirective)
          ..type(SimpleUrlComponent)
          ..type(HtmlAndCssComponent)
          ..type(OnlyCssComponent)
          ..type(InlineWithCssComponent);
    }));

    it('should replace element with template from url', async(inject((Http $http,
            Compiler $compile, Scope $rootScope,  Logger log, Injector injector,
            MockHttpBackend backend, DirectiveMap directives) {
      backend.expectGET('simple.html').respond('<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</simple-url><div>');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();

      expect(renderedText(element)).toEqual('Simple!');
      $rootScope.apply();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));

    it('should load template from URL once', async(inject((Http $http,
          Compiler $compile, Scope $rootScope,  Logger log, Injector injector,
          MockHttpBackend backend, DirectiveMap directives) {
      backend.whenGET('simple.html').respond('<div log="SIMPLE">Simple!</div>');

      var element = $(
          '<div>' +
            '<simple-url log>ignore</simple-url>' +
            '<simple-url log>ignore</simple-url>' +
          '<div>');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();

      expect(renderedText(element)).toEqual('Simple!Simple!');
      $rootScope.apply();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
    })));

    it('should load a CSS file into a style', async(inject((Http $http,
          Compiler $compile, Scope $rootScope, Logger log, Injector injector,
          MockHttpBackend backend, DirectiveMap directives) {
      backend
          ..expectGET('simple.css').respond('.hello{}')
          ..expectGET('simple.html').respond('<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();

      expect(renderedText(element)).toEqual('.hello{}Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
        '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
      );
      $rootScope.apply();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));

    it('should load a CSS file with a \$template', async(inject((Http $http,
           Compiler $compile, Scope $rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      backend.expectGET('simple.css').respond('.hello{}');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();
      expect(renderedText(element)).toEqual('.hello{}inline!');
    })));

    it('should ignore CSS load errors ', async(inject((Http $http,
           Compiler $compile, Scope $rootScope, Injector injector,
           MockHttpBackend backend, DirectiveMap directives) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      backend.expectGET('simple.css').respond(500, 'some error');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();
      expect(renderedText(element)).toEqual(
          '/*\n'
          'HTTP 500: some error\n'
          '*/\n'
          'inline!');
    })));

    it('should load a CSS with no template', async(inject((Http $http,
          Compiler $compile, Scope $rootScope, Injector injector,
          MockHttpBackend backend, DirectiveMap directives) {
      var element = $('<div><only-css log>ignore</only-css><div>');
      backend.expectGET('simple.css').respond('.hello{}');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();
      expect(renderedText(element)).toEqual('.hello{}');
    })));

    it('should load the CSS before the template is loaded', async(inject((Http $http,
          Compiler $compile, Scope $rootScope, Injector injector,
          MockHttpBackend backend, DirectiveMap directives) {
      backend
          ..expectGET('simple.css').respond('.hello{}')
          ..expectGET('simple.html').respond('<div>Simple!</div>');

      var element = $('<html-and-css>ignore</html-and-css>');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();
      expect(renderedText(element)).toEqual('.hello{}Simple!');
    })));
  });

  describe('multiple css loading', () {
    beforeEach(module((Module module) {
      module
          ..type(LogAttrDirective)
          ..type(HtmlAndMultipleCssComponent);
    }));

    it('should load multiple CSS files into a style', async(inject((Http $http,
        Compiler $compile, Scope $rootScope, Logger log, Injector injector,
        MockHttpBackend backend, DirectiveMap directives) {
      backend
          ..expectGET('simple.css').respond('.hello{}')
          ..expectGET('another.css').respond('.world{}')
          ..expectGET('simple.html').respond('<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element, directives)(injector, element);

      backend.flush();
      microLeap();

      expect(renderedText(element)).toEqual('.hello{}.world{}Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
        '<style>.hello{}.world{}</style><div log="SIMPLE">Simple!</div>'
      );
      $rootScope.apply();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));
  });
});
