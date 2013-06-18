part of angular;

var OBJECT_QUAL_NAME = fastReflectClass(Object).qualifiedName;

_equalTypes(ClassMirror a, ClassMirror b) => a.qualifiedName == b.qualifiedName;

_isType(obj, type) {
  InstanceMirror instanceMirror = reflect(obj);
  ClassMirror classM = instanceMirror.type;

  if (type is Type) {
    type = fastReflectClass(type);
  }

  if (classM.superinterfaces.any((si) {return _equalTypes(si, type);})) return true;

  while (classM != null) {
    if (_equalTypes(classM, type)) return true;
    if (classM.qualifiedName == OBJECT_QUAL_NAME) classM = null; // dart bug 5794
    else classM = classM.superclass;

  }
  return false;
}

isInterface(obj, Type type) {
  if (_isType(obj, type)) return true;

  var objMembers = reflect(obj).type.members;

  bool allPresent = true;
  fastReflectClass(type).members.forEach((symbol, mirror) {
    if (!objMembers.containsKey(symbol)) allPresent = false;
    var objMirror = objMembers[symbol];
    if (!_isType(objMirror, reflect(mirror).type)) allPresent = false;

    // TODO(deboer): Check that the method signatures match.  Waiting on dartbug 11334
    /*if (mirror is MethodMirror) {
      // are the paremeters the same?
      var sameParameters = true;
      var interfaceParams = mirror.parameters;
      var objParams = objMirror.parameters;

      Map<Symbol, ParameterMirror> namedParams;
      int minParams = 0;
      int maxParams = 0;
      mirror.parameters.forEach((ParameterMirror param) {
        if (param.isNamed) namedParams[param.qualifiedName] = param;
        if (param.isOptional) maxParams++;
        else { minParams++; minParams++; }
      });

      objMirror.parameters.forEach((param) {
        if (param.isNamed) namedParams.remove(param.qualifiedName);
        if (param.isOptional) maxParams--;
        else { minParams--; maxParams--; }
      });

      if (minParams > 0) return false;
      if (maxParams < 0) return false;
    }*/
  });
  return allPresent;
}
