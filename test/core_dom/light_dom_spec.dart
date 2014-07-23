library light_dom_spec;

import 'dart:html' as dom;
import '../_specs.dart';
import 'package:angular/core/module.dart';

class DummyContent extends Mock implements Content {
  String select;
  List<Node> nodes = [];
  DummyContent(this.select);
  insert(nodes) => this.nodes = new List.from(nodes);
}

void main() {
  describe("redistribute", () {
    TestBed _;
    final dummyElement = new dom.DivElement();

    beforeEach((TestBed tb) => _ = tb);

    it("should redistribute nodes between two content tags", () {
      var nodes = es(
          '<div class="a">a1</div>'
          '<div class="b">b</div>'
          '<div class="a">a2</div>'
      );
      final contentClassA = new DummyContent('.a');
      final contentClassB = new DummyContent('.b');

      redistributeNodes([contentClassA, contentClassB], nodes);

      expect(contentClassA.nodes).toHaveText('a1a2');
      expect(contentClassB.nodes).toHaveText('b');
    });

    it("should handle text nodes", () {
      var nodes = es('<div class="a">a</div>some text');
      final contentClassA = new DummyContent('.a');

      redistributeNodes([contentClassA], nodes);

      expect(contentClassA.nodes).toHaveText('a');
    });

    it("should support wildcards", () {
      var nodes = es(
          '<div class="a">a1</div>'
          '<div class="b">b</div>'
          'text'
          '<div class="a">a2</div>'
      );
      final contentClassA = new DummyContent('.a');
      final contentWildcard = new DummyContent(null);

      redistributeNodes([contentClassA, contentWildcard], nodes);

      expect(contentClassA.nodes).toHaveText('a1a2');
      expect(contentWildcard.nodes).toHaveText('btext');
    });
  });
}
