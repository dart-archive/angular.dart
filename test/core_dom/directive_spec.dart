library directive_spec;

import '../_specs.dart';

main() {
  describe('NodeAttrs', () {
    var element;
    NodeAttrs nodeAttrs;
    TestBed _;

    beforeEach((TestBed tb) {
      _ = tb;
      element = _.compile('<div foo="bar" foo-bar="baz" foo-bar-baz="foo" cux></div>');
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
      expect(attrMap).toEqual({'foo': 'bar', 'foo-bar': 'baz', 'foo-bar-baz': 'foo', 'cux': ''});
    });

    it('should provide a contains method', () {
      expect(nodeAttrs.containsKey('foo')).toEqual(true);
      expect(nodeAttrs.containsKey('foo-bar')).toEqual(true);
      expect(nodeAttrs.containsKey('foo-bar-baz')).toEqual(true);
      expect(nodeAttrs.containsKey('bar-foo')).toEqual(false);
    });

    it('should return the attribute names', () {
      expect(nodeAttrs.keys.toList()..sort()).toEqual(['cux', 'foo', 'foo-bar', 'foo-bar-baz']);
    });

    it('should not call function with argument set to null when observing a'
        ' property', () {
      var invoked;
      nodeAttrs.observe("a", (arg) {
        invoked = true;
      });
      expect(invoked).toBeFalsy();
    });

    it('should call function when argument is set when observing a property',
        () {
      var seenValue = '';
      nodeAttrs.observe("foo", (arg) {
        seenValue = arg;
      });
      expect(seenValue).toEqual('bar');
    });

    it('should call function with argument set to \'\' when observing a boolean attribute',
        () {
      var seenValue;
      nodeAttrs.observe("cux", (arg) {
        seenValue = arg;
      });
      expect(seenValue).toEqual('');
    });
  });
}
