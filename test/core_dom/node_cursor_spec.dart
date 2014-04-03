library node_cursor_spec;

import '../_specs.dart';

main() {
  describe('NodeCursor', () {
    var a, b, c, d;

    beforeEach(() {
      a = e('<a>A</a>');
      b = e('<b>B</b>');
      c = e('<i>C</i>');
      d = e('<span></span>');
      d.append(a);
      d.append(b);
    });


    it('should allow single level traversal', () {
      var cursor = new NodeCursor([a, b]);

      expect(cursor.current, equals(a));
      expect(cursor.moveNext(), equals(true));
      expect(cursor.current, equals(b));
      expect(cursor.moveNext(), equals(false));
    });


    it('should descend and ascend', () {
      var cursor = new NodeCursor([d, c]);

      expect(cursor.descend(), equals(true));
      expect(cursor.current, equals(a));
      expect(cursor.moveNext(), equals(true));
      expect(cursor.current, equals(b));
      expect(cursor.moveNext(), equals(false));
      cursor.ascend();
      expect(cursor.moveNext(), equals(true));
      expect(cursor.current, equals(c));
      expect(cursor.moveNext(), equals(false));
    });

    it('should descend and ascend two levels', () {
      var l1 = e('<span></span>');
      var l2 = e('<span></span>');
      var g = e('<g>G</g>');
      var f = e('<f>F</f>');
      l1.append(l2);
      l1.append(f);
      l2.append(g);
      var cursor = new NodeCursor([l1, c]);

      expect(cursor.descend(), equals(true));
      expect(cursor.current, equals(l2));
      expect(cursor.descend(), equals(true));
      expect(cursor.current, equals(g));
      cursor.ascend();
      expect(cursor.moveNext(), equals(true));
      expect(cursor.current, equals(f));
      expect(cursor.moveNext(), equals(false));
      cursor.ascend();
      expect(cursor.moveNext(), equals(true));
      expect(cursor.current, equals(c));
      expect(cursor.moveNext(), equals(false));
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
      var dom = es('<div><span>text</span></div>');
      var parentCursor = new NodeCursor(dom);
      parentCursor.descend(); // <span>

      var childCursor = parentCursor.replaceWithAnchor('child');
      expect(STRINGIFY(dom), equals('[<div><!--ANCHOR: child--></div>]'));

      expect(STRINGIFY(childCursor.elements.first), equals('<span>text</span>'));
    });

    it('should preserve the top-level elements', () {
      var dom = es('<span>text</span>MoreText<div>other</div>');
      var parentCursor = new NodeCursor(dom);

      var childCursor = parentCursor.replaceWithAnchor('child');
      expect(STRINGIFY(dom), equals('[<!--ANCHOR: child-->, MoreText, <div>other</div>]'));

      expect(STRINGIFY(childCursor.elements.first), equals('<span>text</span>'));
    });
  });
}



