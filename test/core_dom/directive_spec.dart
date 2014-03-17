library directive_spec;

import '../_specs.dart';

main() {
  describe('NodeAttrs', () {
    var element;
    var nodeAttrs;
    TestBed _;

    beforeEach((TestBed tb) {
      _ = tb;
      element = _.compile('<div foo="bar" foo-bar="baz" foo-bar-baz="foo"></div>');
      nodeAttrs = new NodeAttrs(element);
    });

    it('should transform names to camel case', () {
      expect(nodeAttrs['foo']).toEqual('bar');
      expect(nodeAttrs['foo-bar']).toEqual('baz');
      expect(nodeAttrs['foo-bar-baz']).toEqual('foo');
    });

    it('should return null for unexistent attributes', () {
      expect(nodeAttrs['baz']).toBeNull();
    });

    it('should provide a forEach function to iterate over attributes', () {
      Map<String, String> attrMap = new Map();
      nodeAttrs.forEach((k, v) => attrMap[k] = v);
      expect(attrMap).toEqual({'foo': 'bar', 'foo-bar': 'baz', 'foo-bar-baz': 'foo'});
    });

    it('should provide a contains method', () {
      expect(nodeAttrs.containsKey('foo')).toEqual(true);
      expect(nodeAttrs.containsKey('foo-bar')).toEqual(true);
      expect(nodeAttrs.containsKey('foo-bar-baz')).toEqual(true);
      expect(nodeAttrs.containsKey('bar-foo')).toEqual(false);
    });

    it('should return the attribute names', () {
      expect(nodeAttrs.keys.toList()..sort()).toEqual(['foo', 'foo-bar', 'foo-bar-baz']);
    });
  });
}
