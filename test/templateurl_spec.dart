import "_specs.dart";
import "_log.dart";
import "_http.dart";

class LogAttrDirective {
  static var $priority = 0;
  Log log;
  LogAttrDirective(Log this.log, DirectiveValue value) {
    log(value.value == "" ? "LOG" : value.value);
  }
  attach(Scope scope) {}
}

class SimpleUrlComponent {
  static String $templateUrl = 'simple.html';
  attach(Scope scope) {}
}

class HtmlAndCssComponent {
  static String $templateUrl = 'simple.html';
  static String $cssUrl = 'simple.css';
  attach(Scope scope) {}
}

class InlineWithCssComponent {
  static String $template = '<div>inline!</div>';
  static String $cssUrl = 'simple.css';
  attach(Scope scope) {}
}

class OnlyCssComponent {
  static String $cssUrl = 'simple.css';
  attach(Scope scope) {}
}

main() {
  describe('async template loading', () {
    beforeEach(module((module) {
      var mockHttp = new MockHttp();
      module.value(MockHttp, mockHttp);
      module.value(Http, mockHttp);
      module.directive(LogAttrDirective);
      module.directive(SimpleUrlComponent);
      module.directive(HtmlAndCssComponent);
      module.directive(OnlyCssComponent);
      module.directive(InlineWithCssComponent);
    }));

    it('should replace element with template from url', inject((MockHttp $http, Compiler $compile, Scope $rootScope,  Log log) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</replace><div>');
      $compile(element)(element)..attach($rootScope);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('Simple!');
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    }));

    it('should load a CSS file into a style', inject((MockHttp $http, Compiler $compile, Scope $rootScope, Log log) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><html-and-css log>ignore</html-and-css><div>');
      $compile(element)(element)..attach($rootScope);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('@import "simple.css"Simple!');
        expect(element[0].nodes[0].shadowRoot.innerHtml).toEqual(
          '<style>@import "simple.css"</style><div log="SIMPLE">Simple!</div>'
        );
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    }));

    it('should load a CSS file with a \$template', inject((Compiler $compile, Scope $rootScope) {
      var element = $('<div><inline-with-css log>ignore</inline-with-css><div>');
      $compile(element)(element)..attach($rootScope);
      expect(renderedText(element)).toEqual('@import "simple.css"inline!');
    }));

    it('should load a CSS with no template', inject((Compiler $compile, Scope $rootScope) {
      var element = $('<div><only-css log>ignore</only-css><div>');
      $compile(element)(element)..attach($rootScope);

      expect(renderedText(element)).toEqual('@import "simple.css"');
    }));
  });
}

