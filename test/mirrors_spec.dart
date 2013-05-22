import "_specs.dart";

class NoStatic { }
class Static {
  static var name = "deboer";
}
class NotStatic {
  var name = "misko";
}
class NotAField {
  name() => "deboer";
}

main() {
  describe('reflectStaticField', () {
    it('should return null for missing field', () {
      expect(reflectStaticField(NoStatic, 'name')).toEqual(null);
    });

    it('should return value for static field', () {
      expect(reflectStaticField(Static, 'name')).toEqual('deboer');
    });

    // TODO(deboer): Perhaps this test should throw an exception instead.
    // Seems like an error to me..
    it('should return null for non static fields', () {
      expect(reflectStaticField(NotStatic, 'name')).toEqual(null);
    });

    it('should return null for non fields', () {
      expect(reflectStaticField(NotAField, 'name')).toEqual(null);
    });
  });
}
