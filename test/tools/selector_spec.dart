library angular.selector_spec;

import 'package:angular/tools/selector.dart';
import 'package:html5lib/dom.dart';

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';

void main() {
  describe('selector', () {

    it('should match directive on element', () {
      var node = new Element.html('<b></b>');
      expect(matchesNode(node, 'b'), isTrue);
      expect(matchesNode(node, 'em'), isFalse);
    });

    it('should match directive on class', () {
      var node = new Element.html('<div class="b"></div>');
      expect(matchesNode(node, '.b'), isTrue);
      expect(matchesNode(node, '.c'), isFalse);
    });


    it('should match directive on [attribute]', () {
      var node = new Element.html('<div directive></div>');
      expect(matchesNode(node, '[directive]'), isTrue);
      expect(matchesNode(node, '[directiff]'), isFalse);

      node = new Element.html('<div directive="abc"></div>');
      expect(matchesNode(node, '[directive=abc]'), isTrue);
      expect(matchesNode(node, '[directive=bcd]'), isFalse);
    });


    it('should match directive on element[attribute]', () {
      var node = new Element.html('<b directive=abc></b>');
      expect(matchesNode(node, 'b[directive]'), isTrue);
      expect(matchesNode(node, 'c[directive]'), isFalse);
    });


    it('should match directive on [attribute=value]', () {
      var node = new Element.html('<div directive=value></div>');
      expect(matchesNode(node, '[directive=value]'), isTrue);
    });


    it('should match directive on element[attribute=value]', () {
      var node = new Element.html('<b directive=value></b>');
      expect(matchesNode(node, 'b[directive=value]'), isTrue);
      expect(matchesNode(node, 'b[directive=wrongvalue]'), isFalse);
    });

    it('should match attributes', () {
      var node = new Element.html('<div attr="before-xyz-after"></div>');
      expect(matchesNode(node, '[*=/xyz/]'), isTrue);
      expect(matchesNode(node, '[*=/xyzz/]'), isFalse);
    });

    it('should match whildcard attributes', () {
      var node = new Element.html('<div attr-foo="blah"></div>');
      expect(matchesNode(node, '[attr-*]'), isTrue);
      expect(matchesNode(node, '[attr-*=blah]'), isTrue);
      expect(matchesNode(node, '[attr-*=halb]'), isFalse);
      expect(matchesNode(node, '[foo-*]'), isFalse);
      expect(matchesNode(node, '[foo-*=blah]'), isFalse);
      expect(matchesNode(node, '[foo-*=halb]'), isFalse);
    });

    it('should match text', () {
      var node = new Text('before-abc-after');
      expect(matchesNode(node, ':contains(/abc/)'), isTrue);
      expect(matchesNode(node, ':contains(/cde/)'), isFalse);
    });

    it('should match on multiple directives', () {
      var node = new Element.html('<div directive="d" foo="f"></div>');
      expect(matchesNode(node, '[directive=d][foo=f]'), isTrue);
      expect(matchesNode(node, '[directive=d][bar=baz]'), isFalse);
    });

  });
}
