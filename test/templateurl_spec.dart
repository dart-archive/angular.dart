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

main() {
  describe('templateUrl', () {
    beforeEach(module((module) {
      var mockHttp = new MockHttp();
      module.value(MockHttp, mockHttp);
      module.value(Http, mockHttp);
      module.directive(LogAttrDirective);
      module.directive(SimpleUrlComponent);
    }));

    it('should replace element with template from url', inject((MockHttp $http, Compiler $compile, Scope $rootScope, Log log) {
      $http.expectGET('simple.html', '<div log="SIMPLE">Simple!</div>');

      var element = $('<div><simple-url log>ignore</replace><div>');
      $compile(element)(element)..attach($rootScope);

      $http.flush().then(expectAsync1((data) {
        expect(renderedText(element)).toEqual('Simple!');
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));

    }));
  });
}

