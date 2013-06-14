import "_specs.dart";
import "_log.dart";
import "dart:mirrors";



class MainAttrDirective {
  static var $priority = 2;

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

  Log log;
  Controller controller;
  DepAttrDirective(Log this.log, MainAttrDirective this.controller);

  attach(Scope scope) {
    log('dep:${controller.name}:${controller.calledFromMainDirective}');
  }
}

class InheritDepAttrDirective {
  Log log;
  Controller controller;
  InheritDepAttrDirective(Log this.log, MainAttrDirective this.controller) { }

  attach(Scope scope) {
    log('inheritDep:${controller.name}:${controller.calledFromMainDirective}');
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
  module(fn) {
    return () {};
  }

  // TODO(misko): These tests are wrong since they assume that a directive
  // will have additional controller is in JS version of angular, but
  // this is based on DTE branch and the directive is the controller
  // so no need for this. Disabling for now until we need it and will
  // rewrite then.
  xdescribe('controller', () {
    Compiler $compile;
    Scope $rootScope;
    Log $log;

    beforeEach(inject((Injector injector) {
      injector.get(DirectiveRegistry)
      ..register(MainAttrDirective)
      ..register(DepAttrDirective)
      ..register(InheritDepAttrDirective)
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

    it('should get a required controller from the parent element', () {
      var element = $('<div main><div inherit-dep></div></div>');
      var template = $compile(element);
      template(element).attach($rootScope);

      expect($log.result()).toEqual('main; inheritDep:main:true');
    });

    it('should get a required controller from an ancestor', () {
      var element = $('<div main><div><div inherit-dep></div></div></div>');
      var template = $compile(element);
      template(element).attach($rootScope);

      expect($log.result()).toEqual('main; inheritDep:main:true');
    });

    xit('should error nicely on missing controller', () {});

  });
}
