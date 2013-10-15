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


  dom.Element rootElement;
  List<dom.Node> rootElements;
  Block rootBlock;

  TestBed(
      Injector this.injector,
      Scope this.rootScope,
      Compiler this.compiler,
      Parser this.parser);


  dom.Element compile(html) {
    if (html is String) {
      rootElements = toNodeList(html);
    } else if (html is dom.Node) {
      rootElements = [html];
    } else if (html is List<dom.Node>) {
      rootElements = html;
    } else {
      throw 'Expecting: String, Node, or List<Node> got $html.';
    }
    rootElement = rootElements[0];
    rootBlock = compiler(rootElements)(injector, rootElements);
    return rootElement;
  }

  List<dom.Element> toNodeList(html) {
    var div = new DivElement();
    div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
    var nodes = [];
    for(var node in div.nodes) {
      nodes.add(node);
    }
    return nodes;
  }

  triggerEvent(element, name, [type='MouseEvent']) {
    element.dispatchEvent(new dom.Event.eventType(type, name));
  }

  selectOption(element, text) {
    element.queryAll('option').forEach((o) => o.selected = o.text == text);
    triggerEvent(element, 'change');
  }
}

beforeEachTestBed(assign) {
  return module((AngularModule module) {
    module.type(TestBed);
    module.type(Probe);

    var httpBackend = new MockHttpBackend();
    module.value(MockHttpBackend, httpBackend);
    module.value(HttpBackend, httpBackend);

    return inject((TestBed tb) => assign(tb));
  });
}

main() {}
