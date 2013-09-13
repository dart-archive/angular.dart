library angular.module;

class ControllerRegistry {
  Map<String, Type> controllerMap = {};

  register(String name, Type controllerType) {
    controllerMap[name] = controllerType;
  }

  Type operator[](String name) {
    if (controllerMap.containsKey(name)){
      return controllerMap[name];
    } else {
      throw new ArgumentError('Unknown controller: $name');
    }
  }
}

