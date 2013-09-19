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
    return inject((TestBed tb) => assign(tb));
  });
}

/*
 * Use Probe directive to capture the Scope, Injector, Element from any DOM
 * location into root-scope. This is useful for testing to get a hold of
 * any directive.
 *
 *  <pre>
 *    <div some-directive probe="myProbje">..</div>
 *
 *    rootScope.myProbe.directive(SomeAttrDirective);
 */
@NgDirective(selector: '[probe]')
class Probe {
  Scope scope;
  Injector injector;
  Element element;

  Probe(Scope this.scope, Injector this.injector, Element this.element, NodeAttrs attrs) {
    scope.$root[attrs['probe']] = this;
  }

  directive(Type type) => injector.get(type);
}

main() {}
