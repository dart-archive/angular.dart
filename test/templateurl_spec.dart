library templateurl_spec;

import "_specs.dart";
import "_log.dart";
import "_http.dart";

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

main() {
  describe('loading with http rewriting', () {
    var backend;
    beforeEach(module((AngularModule module) {
      backend = new MockHttpBackend();
      module
        ..directive(HtmlAndCssComponent)
        ..value(HttpBackend, backend)
        ..type(UrlRewriter, implementedBy: PrefixedUrlRewriter);
    }));

    it('should use the UrlRewriter for both HTML and CSS URLs', async(inject((Http $http, Compiler $compile, Scope $rootScope, Log log, Injector injector, Zone zone) {

      backend.expectGET('PREFIX:simple.html', '<div log="SIMPLE">Simple!</div>');
      backend.expectGET('PREFIX:simple.css', '.hello{}');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      zone.run(() {
        $compile(element)(injector, element);
      });

      backend.flush();
      nextTurn(true);

      backend.assertAllGetsCalled();

      expect(renderedText(element)).toEqual('.hello{}Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
          '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
      );
    })));
  });


  describe('async template loading', () {
    beforeEach(module((AngularModule module) {
      module.factory(Http, (Injector injector) => injector.get(MockHttp));
      module.directive(LogAttrDirective);
      module.directive(SimpleUrlComponent);
      module.directive(HtmlAndCssComponent);
      module.directive(OnlyCssComponent);
      module.directive(InlineWithCssComponent);
    }));

    afterEach(inject((MockHttp $http) {
      $http.assertAllGetsCalled();
    }));

    it('should replace element with template from url', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope,  Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</simple-url><div>');
      $compile(element)(injector, element);

      $http.flush();
      nextTurn(true);

      expect(renderedText(element)).toEqual('Simple!');
      $rootScope.$digest();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));

    it('should load template from URL once', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope,  Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>', times: 2);

      var element = $('<div><simple-url log>ignore</simple-url><simple-url log>ignore</simple-url><div>');
      $compile(element)(injector, element);

      $http.flush();
      nextTurn(true);

      expect(renderedText(element)).toEqual('Simple!Simple!');
      $rootScope.$digest();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
    })));

    it('should load a CSS file into a style', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');
      $http.expectGET('simple.css', '.hello{}');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element)(injector, element);

      $http.flush();
      nextTurn(true);

      expect(renderedText(element)).toEqual('.hello{}Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
        '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
      );
      $rootScope.$digest();
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));

    it('should load a CSS file with a \$template', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      $http.expectGET('simple.css', '.hello{}');
      $compile(element)(injector, element);

      nextTurn(true);
      expect(renderedText(element)).toEqual('.hello{}inline!');
    })));

    it('should load a CSS with no template', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><only-css log>ignore</only-css><div>');
      $http.expectGET('simple.css', '.hello{}');
      $compile(element)(injector, element);

      nextTurn(true);
      expect(renderedText(element)).toEqual('.hello{}');
    })));

    it('should load the CSS before the template is loaded', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Injector injector) {
      $http.expectGET('simple.html', '<div>Simple!</div>');
      $http.expectGET('simple.css', '.hello{}');

      var element = $('<html-and-css>ignore</html-and-css>');
      $compile(element)(injector, element);

      nextTurn(true);
      expect(renderedText(element)).toEqual('.hello{}Simple!');
    })));
  });
}
