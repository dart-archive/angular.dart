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

      expect(cursor.current).toEqual(a);
      expect(cursor.moveNext()).toEqual(true);
      expect(cursor.current).toEqual(b);
      expect(cursor.moveNext()).toEqual(false);
    });


    it('should descend and ascend', () {
      var cursor = new NodeCursor([d, c]);

      expect(cursor.descend()).toEqual(true);
      expect(cursor.current).toEqual(a);
      expect(cursor.moveNext()).toEqual(true);
      expect(cursor.current).toEqual(b);
      expect(cursor.moveNext()).toEqual(false);
      cursor.ascend();
      expect(cursor.moveNext()).toEqual(true);
      expect(cursor.current).toEqual(c);
      expect(cursor.moveNext()).toEqual(false);
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

      expect(cursor.descend()).toEqual(true);
      expect(cursor.current).toEqual(l2);
      expect(cursor.descend()).toEqual(true);
      expect(cursor.current).toEqual(g);
      cursor.ascend();
      expect(cursor.moveNext()).toEqual(true);
      expect(cursor.current).toEqual(f);
      expect(cursor.moveNext()).toEqual(false);
      cursor.ascend();
      expect(cursor.moveNext()).toEqual(true);
      expect(cursor.current).toEqual(c);
      expect(cursor.moveNext()).toEqual(false);
    });


    it('should create child cursor upon replace of top level', () {
      var parentCursor = new NodeCursor([a]);
      var childCursor = parentCursor.replaceWithAnchor({'k': 'v'});

      expect(parentCursor.elements.length).toEqual(1);
      expect(STRINGIFY(parentCursor.elements[0]))
          .toEqual('<template class="ng-binding" k="v"></template>');
      expect(childCursor.elements).toEqual([a]);

      var leafCursor = childCursor.replaceWithAnchor({'k2' : 'v2'});

      expect(childCursor.elements.length).toEqual(1);
      expect(STRINGIFY(childCursor.elements[0]))
          .toEqual('<template class="ng-binding" k2="v2"></template>');
      expect(leafCursor.elements).toEqual([a]);
    });


    it('should create child cursor upon replace of mid level', () {
      var dom = es('<div><span>text</span></div>');
      var parentCursor = new NodeCursor(dom);
      parentCursor.descend(); // <span>

      var childCursor = parentCursor.replaceWithAnchor({'k': 'v'});
      expect(STRINGIFY(dom))
          .toEqual('[<div><template class="ng-binding" k="v"></template></div>]');

      expect(STRINGIFY(childCursor.elements.first)).toEqual('<span>text</span>');
    });

    it('should preserve the top-level elements', () {
      var dom = es('<span>text</span>MoreText<div>other</div>');
      var parentCursor = new NodeCursor(dom);

      var childCursor = parentCursor.replaceWithAnchor({'k' : 'v'});
      expect(STRINGIFY(dom))
          .toEqual('[<template class="ng-binding" k="v"></template>, MoreText, <div>other</div>]');

      expect(STRINGIFY(childCursor.elements.first)).toEqual('<span>text</span>');
    });
  });
}



