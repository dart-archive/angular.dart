library _test_bed;

import 'dart:html' as dom;
import '_specs.dart';


/**
 * Class which simplifies bootstraping angular for tests.
 */
class TestBed {
  Injector injector;
  Scope rootScope;
  Compiler compiler;
  Parser parser;


  JQuery rootElement;
  Block rootBlock;

  TestBed(
      Injector this.injector,
      Scope this.rootScope,
      Compiler this.compiler,
      Parser this.parser);


  compile(html) {
    rootElement = $(html);
    rootBlock = compiler(rootElement)(injector, rootElement);
    return rootElement;
  }

  triggerEvent(elementWrapper, name, [type='MouseEvent']) {
    elementWrapper[0].dispatchEvent(new dom.Event.eventType(type, name));
  }
}

beforeEachTestBed(assign) {
  return module((AngularModule module) {
    module.type(TestBed);
    module.directive(Probe);

    var httpBackend = new MockHttpBackend();
    module.value(MockHttpBackend, httpBackend);
    module.value(HttpBackend, httpBackend);

    return inject((TestBed tb) => assign(tb));
  });
}

main() {}
