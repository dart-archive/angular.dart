library node_cursor_spec;

import '../_specs.dart';

main() {
  describe('NodeCursor', () {
    var a, b, c, d;

    beforeEach(() {
      a = $('<a>A</a>')[0];
      b = $('<b>B</b>')[0];
      c = $('<i>C</i>')[0];
      d = $('<span></span>')[0];
      d.append(a);
      d.append(b);
    });


    it('should allow single level traversal', () {
      var cursor = new NodeCursor([a, b]);

      expect(cursor.nodeList(), equals([a]));
      expect(cursor.microNext(), equals(true));
      expect(cursor.nodeList(), equals([b]));
      expect(cursor.microNext(), equals(false));
    });


    it('should descend and ascend', () {
      var cursor = new NodeCursor([d, c]);

      expect(cursor.descend(), equals(true));
      expect(cursor.nodeList(), equals([a]));
      expect(cursor.microNext(), equals(true));
      expect(cursor.nodeList(), equals([b]));
      expect(cursor.microNext(), equals(false));
      cursor.ascend();
      expect(cursor.microNext(), equals(true));
      expect(cursor.nodeList(), equals([c]));
      expect(cursor.microNext(), equals(false));
    });

    it('should descend and ascend two levels', () {
      var l1 = $('<span></span>')[0];
      var l2 = $('<span></span>')[0];
      var e = $('<e>E</e>')[0];
      var f = $('<f>F</f>')[0];
      l1.append(l2);
      l1.append(f);
      l2.append(e);
      var cursor = new NodeCursor([l1, c]);

      expect(cursor.descend(), equals(true));
      expect(cursor.nodeList(), equals([l2]));
      expect(cursor.descend(), equals(true));
      expect(cursor.nodeList(), equals([e]));
      cursor.ascend();
      expect(cursor.microNext(), equals(true));
      expect(cursor.nodeList(), equals([f]));
      expect(cursor.microNext(), equals(false));
      cursor.ascend();
      expect(cursor.microNext(), equals(true));
      expect(cursor.nodeList(), equals([c]));
      expect(cursor.microNext(), equals(false));
    });


    it('should create child cursor upon replace of top level', () {
      var parentCursor = new NodeCursor([a]);
      var childCursor = parentCursor.replaceWithAnchor('child');

      expect(parentCursor.elements.length, equals(1));
      expect(STRINGIFY(parentCursor.elements[0]), equals('<!--ANCHOR: child-->'));
      expect(childCursor.elements, equals([a]));

      var leafCursor = childCursor.replaceWithAnchor('leaf');

      expect(childCursor.elements.length, equals(1));
      expect(STRINGIFY(childCursor.elements[0]), equals('<!--ANCHOR: leaf-->'));
      expect(leafCursor.elements, equals([a]));
    });


    it('should create child cursor upon replace of mid level', () {
      var dom = $('<div><span>text</span></div>');
      var parentCursor = new NodeCursor(dom);
      parentCursor.descend(); // <span>

      var childCursor = parentCursor.replaceWithAnchor('child');
      expect(STRINGIFY(dom), equals('[<div><!--ANCHOR: child--></div>]'));

      expect(STRINGIFY(childCursor.elements[0]), equals('<span>text</span>'));
    });

    it('should preserve the top-level elements', () {
      var dom = $('<span>text</span>MoreText<div>other</div>');
      var parentCursor = new NodeCursor(dom);

      var childCursor = parentCursor.replaceWithAnchor('child');
      expect(STRINGIFY(dom), equals('[<!--ANCHOR: child-->, MoreText, <div>other</div>]'));

      expect(STRINGIFY(childCursor.elements[0]), equals('<span>text</span>'));
    });
  });
}


