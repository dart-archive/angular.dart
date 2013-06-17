import '_specs.dart';
import "dart:mirrors";

class InterfaceWithFields {
  int aNumber;
  String aString;
}

class ClassWithFields {
  int aNumber;
  String aString;
  bool somethingElse;
}

class ClassWithDifferentFields {
  int aDifferentNumber;
}

class ClassWithNotFields {
  aNumber(){}
  aString(){}
}

class InterfaceWithMethods {
  method({b}) {}
}

class ClassWithMethods {
  method({b, c}) {}
}

class ClassWithDifferentMethods {
  method({c, d}) {}
}

main() {
  describe('Interface Typing', () {
    it('should recognize built-in objects as an object', () {
      var im = reflect(new Object());
      var cm = reflectClass(Object);
      expect(im.type.qualifiedName).toEqual(cm.qualifiedName);

      expect(isInterface(new Object(), Object)).toBeTruthy();

      expect(isInterface([], Object)).toBeTruthy();
      expect(isInterface({}, Object)).toBeTruthy();
      expect(isInterface(6, Object)).toBeTruthy();
      expect(isInterface('s', Object)).toBeTruthy();
    });

    it('should recognize interfaces with fields', () {
      expect(isInterface(new ClassWithFields(), InterfaceWithFields)).toBeTruthy();
      expect(isInterface(new ClassWithDifferentFields(), InterfaceWithFields)).toBeFalsy();
      expect(isInterface(new ClassWithNotFields(), InterfaceWithFields)).toBeFalsy();
    });

    // waiting on dartbug 11334
    xit('should recognize interfaces with methods', () {
      expect(isInterface(new ClassWithMethods(), InterfaceWithMethods)).toBeTruthy();
      expect(isInterface(new ClassWithDifferentMethods(), InterfaceWithMethods)).toBeFalsy();
    });
  });
}
