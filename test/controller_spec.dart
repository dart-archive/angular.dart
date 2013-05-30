import "_specs.dart";
import "dart:mirrors";


class Log {
  List<String> output = [];
  call(s) { output.add(s); }
  String result() => output.join('; ');
}

class MainController implements Controller {
  var name;
  var calledFromMainDirective = false;
  MainController() { name = "main"; }
}

class MainAttrDirective {
  static var $priority = 2;
  static var $controller = MainController;

  Log log;
  Controller controller;

  MainAttrDirective(Log this.log, Controller this.controller);

  attach(Scope scope) {
    controller.calledFromMainDirective = true;
    log(controller.name);
  }
}

class DepAttrDirective {
  static var $priority = 2;
  static var $require = '[main]';

  Log log;
  Controller controller;
  DepAttrDirective(Log this.log, Controller this.controller);

  attach(Scope scope) {
    log('dep:${controller.name}:${controller.calledFromMainDirective}');
  }
}

class OtherAttrDirective {
  Log log;
  Controller controller;

  OtherAttrDirective(Log this.log, Controller this.controller);
  attach(Scope scope) {
    log('other:${controller != null}');
  }
}

main() {

  var specInjector = new SpecInjector();
  var inject = specInjector.inject;

  module(fn) {
    return () {};
  }

  beforeEach(() {
    specInjector.reset();
  });

  afterEach(() {
    specInjector.reset();
  });

  describe('controller', () {
    Compiler $compile;
    Scope $rootScope;
    Log $log;

    beforeEach(inject((Injector injector) {
      injector.get(Directives)
      ..register(MainAttrDirective)
      ..register(DepAttrDirective)
      ..register(OtherAttrDirective);

      $compile = injector.get(Compiler);
      $rootScope = injector.get(Scope);
      $log = injector.get(Log);
    }));

    it('should create a controller', () {
      var element = $('<div main></div>');
      var template = $compile(element);
      template(element).attach($rootScope);

      expect($log.result()).toEqual('main');
    });

    it('should get required controller', () {
      var element = $('<div main dep other></div>');
      var template = $compile(element);
      template(element).attach($rootScope);

       expect($log.result()).toEqual('main; dep:main:true; other:false');
    });

  });
}
