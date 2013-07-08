import "_specs.dart";
import "_log.dart";
import "_http.dart";

class LogAttrDirective {
  static var $priority = 0;
  Log log;
  LogAttrDirective(Log this.log, NodeAttrs attrs) {
    log(attrs[this] == "" ? "LOG" : attrs[this]);
  }
}

class SimpleUrlComponent {
  static String $templateUrl = 'simple.html';
}

class HtmlAndCssComponent {
  static String $templateUrl = 'simple.html';
  static String $cssUrl = 'simple.css';
}

class InlineWithCssComponent {
  static String $template = '<div>inline!</div>';
  static String $cssUrl = 'simple.css';
  static TemplateLoader lastTemplateLoader;
  InlineWithCssComponent(TemplateLoader templateLoader) {
    lastTemplateLoader = templateLoader;
  }
}

class OnlyCssComponent {
  static String $cssUrl = 'simple.css';
}

main() {
  describe('async template loading', () {
    beforeEach(module((AngularModule module) {
      var mockHttp = new MockHttp();
      module.value(MockHttp, mockHttp);
      module.value(Http, mockHttp);
      module.directive(LogAttrDirective);
      module.directive(SimpleUrlComponent);
      module.directive(HtmlAndCssComponent);
      module.directive(OnlyCssComponent);
      module.directive(InlineWithCssComponent);
    }));

    it('should replace element with template from url', inject((MockHttp $http, Compiler $compile, Scope $rootScope,  Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</simple-url><div>');
      $compile(element)(injector, element);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('Simple!');
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    }));

    it('should load template from URL once', inject((MockHttp $http, Compiler $compile, Scope $rootScope,  Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</simple-url><simple-url log>ignore</simple-url><div>');
      $compile(element)(injector, element);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('Simple!Simple!');
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
      }));
    }));

    it('should load a CSS file into a style', inject((MockHttp $http, Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element)(injector, element);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('@import "simple.css"Simple!');
        expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
          '<style>@import "simple.css"</style><div log="SIMPLE">Simple!</div>'
        );
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    }));

    it('should load a CSS file with a \$template', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      $compile(element)(injector, element);
      InlineWithCssComponent.lastTemplateLoader.template.then(expectAsync1((_) {
        expect(renderedText(element)).toEqual('@import "simple.css"inline!');
      }));
    }));

    it('should load a CSS with no template', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div><only-css log>ignore</only-css><div>');
      $compile(element)(injector, element);

      expect(renderedText(element)).toEqual('@import "simple.css"');
    }));

    it('should load the CSS before the template is loaded', inject((MockHttp $http, Compiler $compile, Scope $rootScope, Injector injector) {
      $http.expectGET('simple.html', '<div>Simple!</div>');

      var element = $('<html-and-css>ignore</html-and-css>');
      $compile(element)(injector, element);

      // The HTML is not loaded yet, but the CSS @import should be in the DOM.
      expect(renderedText(element)).toEqual('@import "simple.css"');

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('@import "simple.css"Simple!');
      }));
    }));
  });
}

