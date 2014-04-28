library simple_library;

// A library for the symbol inspector test

class A {
  A(ConsParamType b) {}

  FieldType field;
  GetterType get getter => null;

  MethodReturnType method(ParamType p) => null;

  void methodWithFunc(ClosureReturn closure(ClosureParam parm)) {}

  static StaticFieldType staticField = null;
}

class _PrivateClass {} // Should not be exported.
typedef _PrivateTypedef(int a); // Also should not be exported.

typedef TypedefReturnType TypedefType(TypedefParam a);

class ConsParamType {}
class FieldType {}
class GetterType {}
class MethodReturnType {}
class ParamType {}
class StaticFieldType {}

class ClosureReturn {}
class ClosureParam {}

class TypedefReturnType {}
class TypedefParam {}


class Generic<K> { // Generic should be exported, but not K.
  K get method => null;
}
