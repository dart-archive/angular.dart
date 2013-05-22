part of angular;

/**
 * A set of functions which build on top of dart:mirrors making them
 * easier to use.
 */

// Return the value of a type's static field or null if it is not defined.
reflectStaticField(Type type, String field) {
  Symbol fieldSym = new Symbol(field);
  var reflection = reflectClass(type);
  if (!reflection.members.containsKey(fieldSym)) return null;
  if (!reflection.members[fieldSym].isStatic) return null;

  var fieldReflection = reflection.getField(fieldSym);
  if (fieldReflection == null) return null;
  return fieldReflection.reflectee;
}
