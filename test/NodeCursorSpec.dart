import 'package:unittest/unittest.dart';
import 'jasmineSyntax.dart';
import '../src/angular.dart';
import 'dart:html';

$(html) {
  var body = new BodyElement();
  body.innerHtml = html;

  return body.nodes;
}

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
  });
}


