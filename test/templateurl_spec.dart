import "_specs.dart";
import "_log.dart";
import "_http.dart";

@NgDirective()
class LogAttrDirective {
  Log log;
  LogAttrDirective(Log this.log, NodeAttrs attrs) {
    log(attrs[this] == "" ? "LOG" : attrs[this]);
  }
}

@NgComponent(templateUrl: 'simple.html')
class SimpleUrlComponent {
}

@NgComponent(templateUrl: 'simple.html', cssUrl: 'simple.css')
class HtmlAndCssComponent {
}

@NgComponent(template: '<div>inline!</div>', cssUrl: 'simple.css')
class InlineWithCssComponent {
}

@NgComponent(cssUrl: 'simple.css')
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
        ..type(UrlRewriter, PrefixedUrlRewriter);
    }));

    it('should use the UrlRewriter for both HTML and CSS URLs', inject((Http $http, Compiler $compile, Scope $rootScope, Log log, Injector injector) {

      backend.expectGET('PREFIX:simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element)(injector, element);

      backend.flush();
      backend.assertAllGetsCalled();

      expect(renderedText(element)).toEqual('@import "PREFIX:simple.css"Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
          '<style>@import "PREFIX:simple.css"</style><div log="SIMPLE">Simple!</div>'
      );
    }));
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
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
    })));

    it('should load a CSS file into a style', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element)(injector, element);

      $http.flush();
      nextTurn(true);

      expect(renderedText(element)).toEqual('@import "simple.css"Simple!');
      expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
        '<style>@import "simple.css"</style><div log="SIMPLE">Simple!</div>'
      );
      // Note: There is no ordering.  It is who ever comes off the wire first!
      expect(log.result()).toEqual('LOG; SIMPLE');
    })));

    it('should load a CSS file with a \$template', async(inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      $compile(element)(injector, element);

      nextTurn(true);
      expect(renderedText(element)).toEqual('@import "simple.css"inline!');
    })));

    it('should load a CSS with no template', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><only-css log>ignore</only-css><div>');
      $compile(element)(injector, element);

      expect(renderedText(element)).toEqual('@import "simple.css"');
    }));

    it('should load the CSS before the template is loaded', async(inject((MockHttp $http, Compiler $compile, Scope $rootScope, Injector injector) {
      $http.expectGET('simple.html', '<div>Simple!</div>');

      var element = $('<html-and-css>ignore</html-and-css>');
      $compile(element)(injector, element);

      // The HTML is not loaded yet, but the CSS @import should be in the DOM.
      expect(renderedText(element)).toEqual('@import "simple.css"');

      nextTurn(true);
      expect(renderedText(element)).toEqual('@import "simple.css"Simple!');
    })));
  });
}
